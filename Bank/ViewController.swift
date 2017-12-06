//
//  ViewController.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-11-29.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class ViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, AccountViewControllerDelegate, NoAccountsViewControllerDelegate {
    static let shouldRefreshDataNotification = Notification.Name(rawValue: "ViewControllerShouldRefreshDataNotificationName")
    static let finishedRefreshingDataNotification = Notification.Name(rawValue: "ViewControllerFinishedRefreshingDataNotificationName")
    var statusViewController: StatusViewController?
    var statusBarOverlayView: StatusBarOverlayView!
    var isExchanging = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        appearance.pageIndicatorTintColor = UIColor(white: 0.8, alpha: 1)
        appearance.currentPageIndicatorTintColor = view.tintColor
        
        // Add gradient view as background
        view.insertSubview(BackgroundGradientView(frame: view.bounds), at: 0)
        
        // Create status bar overlay view
        statusBarOverlayView = StatusBarOverlayView()
        view.addSubview(statusBarOverlayView)
        statusBarOverlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        statusBarOverlayView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        statusBarOverlayView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        statusBarOverlayView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        statusBarOverlayView.viewHeightAnchor = view.heightAnchor
        
        // Listen for and reload on fetched bank account changes
        NotificationCenter.default.addObserver(self, selector: #selector(reloadViewControllers), name: SessionDataStorage.accountsChangedNotification, object: nil)
        
        // Listen for others wanting data refresh
        NotificationCenter.default.addObserver(self, selector: #selector(startLoading), name: ViewController.shouldRefreshDataNotification, object: nil)
        
        setupStatus()
    }
    
    /// Called when we're ready to start finding out about the linked accounts.
    @objc func startLoading() {
        PlaidManager.shared.api.getTransactions { (transactions, accounts, error) in
            let alreadyHasData = SessionDataStorage.shared.accounts != nil
            if alreadyHasData {
                // Notify others we finished refreshing
                NotificationCenter.default.post(name: ViewController.finishedRefreshingDataNotification, object: nil)
            }
            guard error == nil, let transactions = transactions, let accounts = accounts else {
                print("Couldn't load bank accounts:", error?.localizedDescription ?? "no error")
                func handleRetry(_ action: UIAlertAction) {
                    self.startLoading()
                }
                let actions: [UIAlertAction] = alreadyHasData ?  [.normal("Retry", handler: handleRetry), .cancel] : [.cancel("Retry", handler: handleRetry), .normal("Unlink Bank") { _ in
                    PlaidManager.shared.accessToken = nil
                    self.determineStatus()
                }]
                (self.statusViewController ?? self).showAlert(title: "Couldn't Load Bank Accounts", message: error?.localizedDescription ?? "An unknown error occurred while attempting to load your bank accounts.", actions: actions)
                return
            }
            print("Got accounts from server")
            SessionDataStorage.shared.accounts = accounts
            SessionDataStorage.shared.transactions = transactions
        }
    }
    
    @objc func reloadViewControllers() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { self.reloadViewControllers() }
            return
        }
        setViewControllers((SessionDataStorage.shared.accounts?.count ?? 0) > 0 ? [getViewController(for: 0)] : [getNoAccountsViewController()], direction: .forward, animated: false, completion: nil)
        dataSource = nil
        // Only re-enable data source if we have more than one item (as no data source means no horizontal scrolling)
        if SessionDataStorage.shared.accounts?.count ?? 0 > 1 && movementEnabled {
            dataSource = self
        }
        determineStatus()
    }
    
    var movementEnabled = true {
        didSet {
            if oldValue == movementEnabled { return }
            dataSource = movementEnabled && SessionDataStorage.shared.accounts?.count ?? 0 > 1 ? self : nil
        }
    }
    
    var currentIndex: Int? {
        guard let account = currentViewController?.account else { return nil }
        return SessionDataStorage.shared.accounts?.index(of: account)
    }
    
    var currentViewController: AccountViewController? {
        return viewControllers?.first as? AccountViewController
    }
    
    func getViewController(for index: Int) -> AccountViewController {
        let vc = AccountViewController.get()
        vc.account = SessionDataStorage.shared.accounts?[index]
        let pageCount = SessionDataStorage.shared.accounts?.count ?? 0
        vc.index = pageCount > 1 ? (index, pageCount) : nil
        vc.delegate = self
        return vc
    }
    
    func getNoAccountsViewController() -> NoAccountsViewController {
        let vc = NoAccountsViewController.get()
        vc.delegate = self
        return vc
    }
    
    var status = Status.initialLoading {
        didSet {
            if oldValue == status { return }
            handleStatusChange(to: status)
        }
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let account = (viewController as? AccountViewController)?.account, let index = SessionDataStorage.shared.accounts?.index(of: account) else { return nil }
        let newIndex = index + 1
        guard newIndex >= 0 && newIndex < SessionDataStorage.shared.accounts!.count else { return nil }
        return getViewController(for: newIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let account = (viewController as? AccountViewController)?.account, let index = SessionDataStorage.shared.accounts?.index(of: account) else { return nil }
        let newIndex = index - 1
        guard newIndex >= 0 && newIndex < SessionDataStorage.shared.accounts!.count else { return nil }
        return getViewController(for: newIndex)
    }
    
    // MARK: - Page View Controller Delegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        statusBarOverlayView.isHairlineVisible = currentViewController?.shouldShowStatusBarHairline ?? false
    }
    
    // MARK: - No Accounts View Controller Delegate
    
    func didTapUnlink() {
        PlaidManager.shared.accessToken = nil
        determineStatus()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowStatus", let vc = segue.destination as? StatusViewController {
            vc.update(with: status)
            vc.delegate = self
            statusViewController = vc
        }
    }
    
    // MARK: - Account View Controller Delegate
    
    func accountViewController(_ viewController: AccountViewController, shouldMoveTo index: Int) {
        guard let currentIndex = self.currentIndex, currentIndex != index else { return }
        setViewControllers([getViewController(for: index)], direction: index > currentIndex ? .forward : .reverse, animated: true, completion: nil)
    }

    func accountViewController(_ viewController: AccountViewController, shouldShowStatusBarHairlineChangedTo shouldShow: Bool) {
        statusBarOverlayView.isHairlineVisible = shouldShow
    }
    
    func accountViewController(_ viewController: AccountViewController, setMovementEnabledTo enabled: Bool) {
        movementEnabled = enabled
    }
}

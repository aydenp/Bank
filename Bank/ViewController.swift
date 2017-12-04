//
//  ViewController.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-11-29.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class ViewController: UIPageViewController, UIPageViewControllerDataSource, NoAccountsViewControllerDelegate {
    var statusViewController: StatusViewController?
    var isExchanging = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        appearance.pageIndicatorTintColor = UIColor(white: 0.8, alpha: 1)
        appearance.currentPageIndicatorTintColor = view.tintColor
        
        // Add gradient view as background
        view.insertSubview(BackgroundGradientView(frame: view.bounds), at: 0)
        
        // Listen for and reload on fetched bank account changes
        NotificationCenter.default.addObserver(self, selector: #selector(reloadViewControllers), name: SessionDataStorage.accountsChangedNotification, object: nil)
        
        setupStatus()
    }
    
    /// Called when we're ready to start finding out about the linked accounts.
    func startLoading() {
        PlaidManager.shared.api.getTransactions { (transactions, accounts, error) in
            guard error == nil, let transactions = transactions, let accounts = accounts else {
                print("Couldn't load bank accounts:", error?.localizedDescription ?? "no error")
                (self.statusViewController ?? self).showAlert(title: "Couldn't Load Bank Accounts", message: error?.localizedDescription ?? "An unknown error occurred while attempting to load your bank accounts.", actions: [.cancel("Retry") { _ in self.startLoading() }, .normal("Unlink Bank") { _ in
                    PlaidManager.shared.accessToken = nil
                    self.determineStatus()
                }])
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
        dataSource = self
        isSwipingEnabled = SessionDataStorage.shared.accounts?.count ?? 0 > 1
        determineStatus()
    }
    
    func getViewController(for index: Int) -> AccountViewController {
        let vc = AccountViewController.get()
        vc.account = SessionDataStorage.shared.accounts?[index]
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
    
    /// Whether or not swiping to go to the previous/next page is enabled.
    var isSwipingEnabled = true {
        didSet {
            view.subviews.forEach { view in
                if let scrollView = view as? UIScrollView { scrollView.isScrollEnabled = isSwipingEnabled }
            }
        }
    }
    
    // MARK: - Page View Controller Data Source
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        let count = SessionDataStorage.shared.accounts?.count ?? 0
        return count > 1 ? count : 0
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let account = ((pageViewController.viewControllers?.first) as? AccountViewController)?.account else { return 0 }
        return SessionDataStorage.shared.accounts?.index(of: account) ?? 0
    }
    
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
}

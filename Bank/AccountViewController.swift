//
//  AccountViewController.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class AccountViewController: UITableViewController, AccountHeaderViewDelegate {
    weak var delegate: AccountViewControllerDelegate?
    var account: Account!, index: (Int, Int)?, tapGestureRecognizer: UITapGestureRecognizer!, firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add refresh control
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(shouldRefresh), for: .valueChanged)
        // Listen for when refreshes finish
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDidFinish), name: ViewController.finishedRefreshingDataNotification, object: nil)
        // Setup header view
        headerView.account = account
        headerView.accountIndex = index
        headerView.delegate = self
        // Setup chart escape tap gesture recognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGestureRecognizer.isEnabled = false
        tableView.addGestureRecognizer(tapGestureRecognizer)
        // Populate with initial transaction data
        populateData()
        // Listen for transaction data changes
        NotificationCenter.default.addObserver(self, selector: #selector(populateData), name: SessionDataStorage.transactionsChangedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !firstAppear {
            headerView.reselectCorrectChartViewRange()
        }
        firstAppear = false
    }
    
    var headerView: AccountHeaderView {
        return tableView.tableHeaderView as! AccountHeaderView
    }
    
    var shouldShowStatusBarHairline = false {
        didSet {
            if oldValue == shouldShowStatusBarHairline { return }
            delegate?.accountViewController(self, shouldShowStatusBarHairlineChangedTo: shouldShowStatusBarHairline)
        }
    }
    
    var movementEnabled = true {
        didSet {
            if oldValue == movementEnabled { return }
            // Hide scroll indicators, because we lock scrolling in elsewhere and they still show when dragging
            tableView.showsVerticalScrollIndicator = movementEnabled
            // Fade out cells
            UIView.animate(withDuration: 0.25) {
                self.tableView.visibleCells.forEach { cell in
                    cell.alpha = self.movementEnabled ? 1 : 0.2
                    cell.isUserInteractionEnabled = self.movementEnabled
                }
            }
            // We need this to escape the chart, enable if movement disabled
            tapGestureRecognizer.isEnabled = !movementEnabled
            // Scroll to the top if disabled
            if !movementEnabled {
                tableView.setContentOffset(CGPoint(x: -tableView.contentInset.left, y: -tableView.adjustedContentInset.top), animated: true)
            }
        }
    }
    
    // MARK: - Refresh Control Handling
    
    @objc func shouldRefresh() {
        NotificationCenter.default.post(name: ViewController.shouldRefreshDataNotification, object: nil)
    }
    
    @objc func refreshDidFinish() {
        DispatchQueue.main.async {
            self.refreshControl!.endRefreshing()
        }
    }
    
    // MARK: - Tap Handling
    
    @objc func tapped(with gestureRecognizer: UITapGestureRecognizer) {
        guard !movementEnabled, gestureRecognizer.state == .recognized else { return }
        let chartFrame = headerView.chart.convert(headerView.chart.bounds, to: gestureRecognizer.view!)
        if !chartFrame.contains(gestureRecognizer.location(in: gestureRecognizer.view!)) {
            // Tap isn't in chart, escape chart again
            headerView.chart.finishTouchingChart()
        }
    }
    
    // MARK: - Data Loading
    
    var transactions = [Transaction]() {
        didSet { tableView.reloadData() }
    }
    
    @objc func populateData() {
        print("Populating transaction data for account \(account.id)")
        transactions = account.transactions
    }
    
    // MARK: - Scroll View Delegate
    
    var oldY: CGFloat?
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.scrollIndicatorInsets.top = max(headerView.frame.maxY - scrollView.contentOffset.y - scrollView.adjustedContentInset.top, 0)
        shouldShowStatusBarHairline = scrollView.contentOffset.y > headerView.infoStackView.convert(headerView.infoStackView.bounds, to: scrollView).minY - scrollView.adjustedContentInset.top
        if !movementEnabled && scrollView.isDragging, let oldY = oldY {
            scrollView.setContentOffset(CGPoint(x: 0, y: oldY), animated: false)
        } else {
            oldY = scrollView.contentOffset.y
        }
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Transaction", for: indexPath) as! TransactionCell
        cell.transaction = transactions[indexPath.row]
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = movementEnabled ? 1 : 0.2
        cell.isUserInteractionEnabled = movementEnabled
    }
    
    // MARK: - Easy Initialization
    
    static func get() -> AccountViewController {
        return UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "Account") as! AccountViewController
    }
    
    // MARK: - Account Header View Delegate
    
    func shouldMove(to index: Int) {
        delegate?.accountViewController(self, shouldMoveTo: index)
    }
    
    func setMovementEnabled(to enabled: Bool) {
        delegate?.accountViewController(self, setMovementEnabledTo: enabled)
        movementEnabled = enabled
    }
}

protocol AccountViewControllerDelegate: class {
    func accountViewController(_ viewController: AccountViewController, shouldMoveTo index: Int)
    func accountViewController(_ viewController: AccountViewController, shouldShowStatusBarHairlineChangedTo shouldShow: Bool)
    func accountViewController(_ viewController: AccountViewController, setMovementEnabledTo enabled: Bool)
}

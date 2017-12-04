//
//  AccountViewController.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class AccountViewController: UITableViewController {
    var account: Account!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup header view
        headerView.account = account
        // Populate with initial transaction data
        populateData()
        // Listen for transaction data changes
        NotificationCenter.default.addObserver(self, selector: #selector(populateData), name: SessionDataStorage.transactionsChangedNotification, object: nil)
    }
    
    var headerView: AccountHeaderView {
        return tableView.tableHeaderView as! AccountHeaderView
    }
    
    // MARK: - Data Loading
    
    var transactions = [Transaction]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    @objc func populateData() {
        print("Populating transaction data for account \(account.id)")
        transactions = account.transactions
    }
    
    // MARK: - Scroll View Delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.scrollIndicatorInsets.top = max(headerView.frame.maxY - scrollView.contentOffset.y - scrollView.adjustedContentInset.top, 0)
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
    
    // MARK: - Easy Initialization
    
    static func get() -> AccountViewController {
        return UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "Account") as! AccountViewController
    }
}

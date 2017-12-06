//
//  SessionDataStorage.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-03.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

class SessionDataStorage {
    static let shared = SessionDataStorage()
    static let accountsChangedNotification = Notification.Name(rawValue: "BankSessionDataStorageAccountsChangedNotificationName")
    static let transactionsChangedNotification = Notification.Name(rawValue: "BankSessionDataStorageTransactionsChangedNotificationName")
    
    private init() {}
    
    var accounts: [Account]? {
        didSet {
            if oldValue ?? [] == accounts ?? [] { return }
            NotificationCenter.default.post(name: SessionDataStorage.accountsChangedNotification, object: nil)
        }
    }
    
    var transactions: [Transaction]? {
        didSet {
            if oldValue ?? [] == transactions ?? [] { return }
            NotificationCenter.default.post(name: SessionDataStorage.transactionsChangedNotification, object: nil)
        }
    }
    
    var selectedChartRange: AccountHeaderView.ChartViewRange = .defaultOption
    
    func transactions(for account: Account) -> [Transaction] {
        return transactions?.filter { $0.accountID == account.id } ?? []
    }
}

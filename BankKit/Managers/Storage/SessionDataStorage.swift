//
//  SessionDataStorage.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-03.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

public class SessionDataStorage {
    public static let shared = SessionDataStorage()
    public static let accountsChangedNotification = Notification.Name(rawValue: "BankSessionDataStorageAccountsChangedNotificationName")
    public static let transactionsChangedNotification = Notification.Name(rawValue: "BankSessionDataStorageTransactionsChangedNotificationName")
    
    private init() {}
    
    public var item: Item?
    
    public var accounts: [Account]? {
        didSet {
            if oldValue ?? [] == accounts ?? [] { return }
            NotificationCenter.default.post(name: SessionDataStorage.accountsChangedNotification, object: nil)
        }
    }
    
    public var transactions: [Transaction]? {
        didSet {
            if oldValue ?? [] == transactions ?? [] { return }
            NotificationCenter.default.post(name: SessionDataStorage.transactionsChangedNotification, object: nil)
        }
    }
    
    public var selectedChartRange: ChartViewRange = .defaultOption
    
    public enum ChartViewRange: TimeInterval, CaseIterable {
        public static let defaultOption = ChartViewRange.month
        case week = 7, twoWeeks = 14, month = 30, threeMonths = 90, sixMonths = 180, year = 365, all = 0
        
        public var startDate: Date? {
            guard days > 0 else { return nil }
            return Date().addingTimeInterval(-60 * 60 * 24 * days)
        }
        
        public var days: TimeInterval {
            return rawValue
        }
        
        public var displayText: String {
            switch self {
            case .week: return "1W"
            case .twoWeeks: return "2W"
            case .month: return "1M"
            case .threeMonths: return "3M"
            case .sixMonths: return "6M"
            case .year: return "1Y"
            case .all: return "All"
            }
        }
    }
    
    public func transactions(for account: Account) -> [Transaction] {
        return transactions?.filter { $0.accountID == account.id } ?? []
    }
}

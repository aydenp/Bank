//
//  Account+Transactions.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-03.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

extension Account {
    var transactions: [Transaction] {
        return SessionDataStorage.shared.transactions(for: self)
    }
    
    func getBalanceHistoricalData(from startDate: Date? = nil, completionHandler: @escaping ([(Date, Double)]) -> Void) {
        OperationQueue().addOperation {
            // Get transactions, oldest first
            let transactions = self.transactions.sorted { $0.date < $1.date }
            var values = [(Date, Double)]()
            let now = Date()
            var currentDate = startDate ?? transactions.first?.date ?? now
            var currentBalance = self.displayBalance
            // Loop through all dates between the start date and now
            while currentDate <= now {
                // Find all the transactions that occurred on this day
                let dayTransactions = transactions.filter { Calendar.current.isDate(currentDate, inSameDayAs: $0.date) }
                // Offset our current balance by how much the balance changed that day
                currentBalance += dayTransactions.map { -$0.amount }.reduce(0, +)
                // Append this data set to the array
                values.append((currentDate, currentBalance))
                // Move our current date to the next day
                currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
            }
            completionHandler(values)
        }
    }
}

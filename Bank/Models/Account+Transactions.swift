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
            var transactionsByDate = [Date: [Transaction]]()
            transactions.forEach {
                let day = Calendar.current.startOfDay(for: $0.date)
                if transactionsByDate[day] == nil {
                    transactionsByDate[day] = [$0]
                } else {
                    transactionsByDate[day]!.append($0)
                }
            }
            var values = [(Date, Double)]()
            var currentDate = Calendar.current.startOfDay(for: Date())
            let start = Calendar.current.startOfDay(for: startDate ?? transactions.first?.date ?? Date())
            var currentBalance = self.displayBalance
            // Loop through all dates between the start date and now
            while start <= currentDate {
                // Find all the transactions that occurred on this day
                let dayTransactions = transactionsByDate[currentDate] ?? []
                // Offset our current balance by how much the balance changed that day
                currentBalance += dayTransactions.map { -$0.amount }.reduce(0, +)
                // Append this data set to the array
                values.append((currentDate, currentBalance))
                // Move our current date to the next day
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            }
            completionHandler(values)
        }
    }
}

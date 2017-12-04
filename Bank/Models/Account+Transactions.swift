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
    
    func balanceHistoricalData(from startDate: Date) -> [Double] {
        return [0, 302, 306, 381, 599, 230, 402]
    }
}

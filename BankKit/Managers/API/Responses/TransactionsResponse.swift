//
//  TransactionsResponse.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

public struct TransactionsResponse: PlaidResponse {
    let item: Item
    let accounts: [Account]
    let transactions: [Transaction] 
}

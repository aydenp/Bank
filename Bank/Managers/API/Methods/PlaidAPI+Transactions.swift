//
//  PlaidAPI+Transactions.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

extension PlaidAPI {
    func getTransactions(completionHandler: @escaping ([Transaction]?, [Account]?, Error?) -> Void) {
        makeAuthedRequest(to: "transactions/get", body: ["start_date": "2000-01-01", "end_date": "9999-12-31", "options": ["count": 500]], type: TransactionsResponse.self) { (response, error) in
            completionHandler(response?.transactions, response?.accounts, error)
        }
    }
}

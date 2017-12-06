//
//  PlaidAPI+ExchangeTokens.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

extension PlaidAPI {
    func getAccessToken(from publicToken: String, completionHandler: @escaping (String?, Error?) -> Void) {
        makeRequest(to: "item/public_token/exchange", body: ["client_id": clientID, "secret": secret, "public_token": publicToken], type: AccessTokenExchangeResponse.self) { (response, error) in
            completionHandler(response?.accessToken, error)
        }
    }
}

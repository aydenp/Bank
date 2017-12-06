//
//  ServerError.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

struct PlaidError: LocalizedError {
    var response: ErrorResponse?
    
    var errorDescription: String? { return response?.message }
    var failureReason: String? { return response?.message }
}

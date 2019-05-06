//
//  ServerError.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

public struct PlaidError: LocalizedError {
    var response: ErrorResponse?
    
    public var errorDescription: String? { return response?.message }
    public var failureReason: String? { return response?.message }
}

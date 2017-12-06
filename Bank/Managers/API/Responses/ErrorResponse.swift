//
//  ErrorResponse.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

struct ErrorResponse: PlaidResponse {
    let errorType: String, code: String, message: String, displayMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case errorType = "error_type"
        case code = "error_code"
        case message = "error_message"
        case displayMessage = "display_message"
    }
}

//
//  ServerResponse.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

protocol PlaidResponse: Codable {}

extension PlaidResponse {
    static func decode(from data: Data) -> Self? {
        return try? JSONDecoder().decode(self, from: data)
    }
    
    func encode() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

//
//  Institution.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-03.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

public struct Institution: Codable, Equatable {
    /// The unique identifier of this institution
    public let id: String
    /// The name of this institution
    public let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "institution_id"
        case name
    }
    
    public static func ==(lhs: Institution, rhs: Institution) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

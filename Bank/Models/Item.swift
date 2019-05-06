//
//  Item.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2019-05-06.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import Foundation

struct Item: Codable {
    /// The identifier of this item.
    let id: String
    
    /// The ID of the financial institution for this item.
    let institutionID: String?
    
    /// The name of the financial institution for this item.
    var institutionName: String? {
        guard let id = institutionID else { return nil }
        return PeriodicFetchDataStorage.shared.institutions.value(for: id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "item_id"
        case institutionID = "institution_id"
    }
}

//
//  Transaction.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-11-29.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation
import CoreLocation

struct Transaction: Codable {
    /// The unique identifier of this transaction.
    let id: String
    /// The transaction store's name.
    let name: String
    /// Whether or not the transaction is still pending.
    let pending: Bool
    /// The type of transaction that took place.
    let variety: Variety
    /// The amount of money moved in/out of the account.
    let amount: Double
    /// The date the transaction occurred on, as provided by the server (YYYY-MM-DD).
    let serverDate: String
    /// Applicable categories for this transaction (such as Computers or Food)
    let categories: [String]?
    /// The unique identifier of the account that this transaction occurred on.
    let accountID: String
    /// The location this transaction occurred at.
    let location: Location?
    
    /// Whether or not this transaction increased the account balance or not.
    var didIncreaseBalance: Bool {
        // Positive amount values mean the balance decreased (like a purchase), while negative mean it increased (like a refund or payment), so we check if amount is negative.
        return amount < 0
    }
    
    /// The date the transaction occurred on.
    var date: Date {
        return Transaction.dateFormatter.date(from: serverDate)!
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "transaction_id"
        case variety = "transaction_type"
        case categories = "category"
        case accountID = "account_id"
        case serverDate = "date"
        case name, amount, pending, location
    }
    
    /// Date formatter for use later, decoding server dates
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

// MARK: - Equatable
extension Transaction: Equatable {
    static func ==(lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.pending == rhs.pending && lhs.variety == rhs.variety && lhs.amount == rhs.amount && lhs.serverDate == rhs.serverDate && lhs.categories ?? [] == rhs.categories ?? [] && lhs.accountID == rhs.accountID && lhs.location == rhs.location
    }
}

// MARK: - Models
extension Transaction {
    /// Enum describing the type of transaction that took place.
    enum Variety: String, Codable {
        case place, digital, special, unresolved
    }
    
    /// An object describing the location of a transaction
    struct Location: Codable, Equatable {
        let address: String?, city: String?, state: String?, zipCode: String?
        let latitude: CLLocationDegrees?, longitude: CLLocationDegrees?
        
        enum CodingKeys: String, CodingKey {
            case address, city, state
            case zipCode = "zip"
            case latitude = "lat"
            case longitude = "lon"
        }
        
        var location: CLLocation? {
            guard let latitude = latitude, let longitude = longitude else { return nil }
            return CLLocation(latitude: latitude, longitude: longitude)
        }
        
        static func ==(lhs: Location, rhs: Location) -> Bool {
            return lhs.address == rhs.address && lhs.city == rhs.city && lhs.state == rhs.state && lhs.zipCode == rhs.zipCode && lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
        }
    }
}

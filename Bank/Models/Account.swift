//
//  Account.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import Foundation

struct Account: Codable, Equatable {
    /// The unique ID of the account.
    let id: String
    /// The ID of the financial institution for this account.
    let institutionID: String?
    /// This account's balances.
    let balances: Balances
    /// The account's name.
    let name: String
    /// The last four digit's of the account number.
    let mask: String?
    /// The official account name, given by the institution.
    let officialName: String
    /// The type of the account.
    let type: AccountType
    
    /// The balance to display to the user.
    var displayBalance: Double {
        return balances.available ?? balances.current ?? 0
    }
    
    /// The name of the financial institution for this account.
    var institutionName: String? {
        guard let id = institutionID else { return nil }
        return PeriodicFetchDataStorage.shared.institutions.value(for: id)
    }
    
    /// The name of the financial instutition, if known, followed by the type.
    var institutionDescription: String {
        let parts = [institutionName, type.rawValue].filter { $0 != nil && $0!.lowercased() != "other" } as! [String]
        if parts.count == 0 {
            // Have no institution name and account description was other. Just return Other at this point.
            return "OTHER"
        }
        return parts.joined(separator: " ").uppercased()
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "account_id"
        case institutionID = "institution_id"
        case officialName = "official_name"
        case balances, name, mask, type
    }
    
    /**
     Check whether or not two account objects represent the same bank account. Use this over == when you need to ignore balances.
     - returns: Whether or not the two accounts are the same, ignoring balances.
     */
    func representsSameAccount(as otherAccount: Account) -> Bool {
        return id == otherAccount.id && institutionID == otherAccount.institutionID && name == otherAccount.name && mask == otherAccount.mask && officialName == otherAccount.officialName && type == otherAccount.type
    }
    
    static func ==(lhs: Account, rhs: Account) -> Bool {
        return lhs.representsSameAccount(as: rhs) && lhs.balances == rhs.balances
    }
}

extension Account {
    enum AccountType: String, Codable, Equatable {
        case brokerage, credit, depository, loan, mortgage, other
    }
}

extension Account {
    /// A struct holding difference account balances.
    struct Balances: Codable, Equatable {
        /// The total amount of funds in the account.
        let current: Double?
        /// The current balance, minus any outstanding holds or debits not yet posted.
        let available: Double?
        /// The account's balance limit.
        let limit: Double?
        
        static func ==(lhs: Balances, rhs: Balances) -> Bool {
            return lhs.current == rhs.current && lhs.available == rhs.available && lhs.limit == rhs.limit
        }
    }
}

//
//  AccountHeaderView.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-03.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class AccountHeaderView: UIView {
    @IBOutlet weak var amountLabel: AmountLabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var institutionLabel: UILabel!
    var hasAwaken = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupData()
        hasAwaken = true
        // Listen for changes to periodic institution data store
        NotificationCenter.default.addObserver(self, selector: #selector(setupData), name: PeriodicFetchDataStorage.shared.institutions.dataChangedNotification, object: nil)
    }
    
    var account: Account? {
        didSet {
            if hasAwaken { setupData() }
        }
    }
    
    @objc func setupData() {
        amountLabel.amount = account?.balances.available ?? account?.balances.current ?? 0
        nameLabel.text = account?.name ?? "Account Name"
        institutionLabel.text = account?.institutionDescription ?? "Institution Name" // this is really bad but how it'll be for now
    }
}

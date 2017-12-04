//
//  TransactionCell.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-03.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountLabel: TransactionAmountLabel!
    var hasAwaken = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
        setupData()
        hasAwaken = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        transaction = nil
    }
    
    var transaction: Transaction? {
        didSet {
            if hasAwaken { setupData() }
        }
    }

    func setupData() {
        titleLabel.text = transaction?.name
        if let date = transaction?.date {
            subtitleLabel.text = TransactionCell.dateFormatter.string(from: date)
        } else {
            subtitleLabel.text = nil
        }
        amountLabel.amount = -(transaction?.amount ?? 0)
    }
    
    /// Date formatter for use later, decoding server dates
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
}

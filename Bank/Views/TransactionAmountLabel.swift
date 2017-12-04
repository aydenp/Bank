//
//  TransactionAmountLabel.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-03.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class TransactionAmountLabel: AmountLabel {
    override var colourToUse: UIColor {
        if amount > 0 {
            // Positive number
            return Colours.positiveAmount
        } else if amount < 0 {
            // Negative number
            return Colours.negativeAmount
        }
        return Colours.neutralAmount
    }
    
    // We don't need sub-info to be smaller than it already is
    override var subInfoRatio: CGFloat {
        return 1
    }
}

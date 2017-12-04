//
//  AmountLabel.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-03.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class AmountLabel: UILabel {
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        setAmountText()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        setAmountText()
    }
    
    var amount: Double = 0 {
        didSet { setAmountText() }
    }
    
    private func setAmountText() {
        attributedText = format(amount: amount)
    }
    
    /// The attributes to use when making the attributed string (for the main number)
    private var attributes: [NSAttributedStringKey: Any] {
        return [.foregroundColor: colourToUse, .font: font]
    }
    
    /// The colour to use for the amount.
    var colourToUse: UIColor {
        return .gradientColor(from: Colours.lighterMain, to: Colours.main, height: bounds.size.height)
    }
    
    /// The ratio of size when comparing the main number, to decimals, numbers after decimals, and the dollar sign. Represented as a float that the font size of the main number will be multiplied to get the size of the sub info.
    var subInfoRatio: CGFloat {
        return 0.8276
    }
    
    func format(amount: Double) -> NSAttributedString {
        guard let formatted = AmountLabel.numberFormatter.string(from: NSNumber(value: abs(amount))) else { return NSAttributedString() }
        let normalFont = font.withSize(attributedText?.largestFontSize ?? font.pointSize)
        // Get the normal attributes used for fonts, and make its font smaller for use by sub info
        var attributes = self.attributes
        attributes[.font] = normalFont
        var subInfoAttributes = attributes
        subInfoAttributes[.font] = normalFont.withSize(normalFont.pointSize * subInfoRatio)
        
        let result = NSMutableAttributedString(string: "", attributes: attributes)
        // Add negative prefix, if applicable for this locale and amount is below zero
        if amount < 0 { result.append(NSAttributedString(string: AmountLabel.numberFormatter.negativePrefix, attributes: subInfoAttributes)) }
        result.append(NSAttributedString(string: "$", attributes: subInfoAttributes))
        
        // Split parts of formatted number by formatter's decimal symbol
        let numberParts = formatted.components(separatedBy: AmountLabel.numberFormatter.currencyDecimalSeparator)
        // The first part, if existant, should be added as the normal size text
        if let mainNumber = numberParts.first { result.append(NSAttributedString(string: mainNumber, attributes: attributes)) }
        // Then we can add the rest, as smaller text
        numberParts.dropFirst().forEach { result.append(NSAttributedString(string: AmountLabel.numberFormatter.currencyDecimalSeparator + $0, attributes: subInfoAttributes)) }
        
        // Add negative suffix, if applicable for this locale and amount is below zero
        if amount < 0 { result.append(NSAttributedString(string: AmountLabel.numberFormatter.negativeSuffix, attributes: subInfoAttributes)) }
        return result
    }
    
    static var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "" // we'll add in our own dollar sign
        return formatter
    }()
    
}

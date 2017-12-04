//
//  APButton.swift
//
//  Created by Ayden Panhuyzen on 2016-07-29.
//  Copyright © 2016 Ayden Panhuyzen. All rights reserved.
//

import UIKit

/// A quick and basic button class giving it a rounded look with it's tint colour and white text.
class APButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.borderWidth = 0
        layer.masksToBounds = true
        adjustsImageWhenHighlighted = false
        
        setColours()
        layer.cornerRadius = 10
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        contentEdgeInsets = UIEdgeInsets(top: 13, left: 15, bottom: 13, right: 15)
    }

    override var isHighlighted: Bool {
        didSet {
            self.alpha = isHighlighted ? 0.8 : 1
        }
    }
    
    override var isEnabled: Bool {
        didSet { setColours() }
    }
    
    override func tintColorDidChange() {
        setColours()
    }
    
    var textTintColor = UIColor.white {
        didSet { setColours() }
    }
    
    var disabledTintColor: UIColor? = .lightGray {
        didSet { setColours() }
    }
    
    var disabledTextTintColor: UIColor? {
        didSet { setColours() }
    }
    
    func setColours() {
        self.backgroundColor = isEnabled || disabledTintColor == nil ? tintColor : disabledTintColor
        let textColour = isEnabled || disabledTextTintColor == nil ? textTintColor : disabledTextTintColor
        self.imageView?.tintColor = textColour
        self.setTitleColor(textColour, for: [.normal])
    }
    
}

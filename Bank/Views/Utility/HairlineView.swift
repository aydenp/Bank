//
//  HairlineView.swift
//
//  Created by Ayden Panhuyzen on 2017-08-21.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class HairlineView: UIView {
    private var heightConstraint: NSLayoutConstraint?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint?.isActive = false
        heightConstraint = heightAnchor.constraint(equalToConstant: 1 / (window?.screen.scale ?? 1))
        heightConstraint!.isActive = true
    }
}


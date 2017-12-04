//
//  StatusBarOverlayView.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-04.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class StatusBarOverlayView: UIView {
    private var gradientView: BackgroundGradientView!, gradientViewHeightAnchor: NSLayoutConstraint?, hairlineView: HairlineView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        
        gradientView = BackgroundGradientView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientView)
        gradientView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        gradientView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        gradientView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        hairlineView = HairlineView()
        hairlineView.translatesAutoresizingMaskIntoConstraints = false
        hairlineView.backgroundColor = UIColor(white: 0, alpha: 0.15)
        hairlineView.alpha = 0
        addSubview(hairlineView)
        hairlineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        hairlineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        hairlineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The height anchor to use to layout the gradient view (to match the background of the view controller)
    var viewHeightAnchor: NSLayoutDimension? {
        didSet {
            gradientViewHeightAnchor?.isActive = false
            guard let anchor = viewHeightAnchor else { return }
            gradientViewHeightAnchor = gradientView.heightAnchor.constraint(equalTo: anchor)
            gradientViewHeightAnchor!.isActive = true
        }
    }
    
    /// Whether or not the hairline view should be shown.
    var isHairlineVisible = false {
        didSet {
            if isHairlineVisible == oldValue { return }
            func doAnimate() {
                UIView.animate(withDuration: 0.15) { self.hairlineView.alpha = self.isHairlineVisible ? 1 : 0 }
            }
            if !Thread.isMainThread {
                DispatchQueue.main.async { doAnimate() }
            } else { doAnimate() }
        }
    }
}

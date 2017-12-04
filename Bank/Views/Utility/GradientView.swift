//
//  GradientView.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-02.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = false
    }
    
    private var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
    override static var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var colours = [UIColor]() {
        didSet { gradientLayer.colors = colours.map({ $0.cgColor }) }
    }
    
    var angle: CGFloat = 0 {
        didSet {
            let fraction = angle / 360
            let a = CGFloat(pow(sinf((2 * Float.pi * Float((fraction + 0.75) / 2))), 2))
            let b = CGFloat(pow(sinf((2 * Float.pi * Float(fraction / 2))), 2))
            gradientLayer.startPoint = CGPoint(x: a, y: b)
            let c = CGFloat(pow(sinf((2 * Float.pi * Float((fraction + 0.25) / 2))), 2))
            let d = CGFloat(pow(sinf((2 * Float.pi * Float((fraction + 0.5) / 2))), 2))
            gradientLayer.endPoint = CGPoint(x: c, y: d)
        }
    }
    
}

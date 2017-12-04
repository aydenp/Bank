//
//  UIColor+Gradient.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-03.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

// Inspired by https://stackoverflow.com/a/19368096
extension UIColor {
    /// Get a vertical linear gradient colour from the provided two colours, made with the requested height.
    static func gradientColor(from colour1: UIColor, to colour2: UIColor, height: CGFloat) -> UIColor {
        let size = CGSize(width: 1, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        let colours = [colour1.cgColor, colour2.cgColor]
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colours as CFArray, locations: nil) {
            context?.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return UIColor(patternImage: image)
    }
}

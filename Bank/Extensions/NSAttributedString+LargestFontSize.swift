//
//  NSAttributedString+LargestFontSize.swift
//  Bank
//
//  Created by Ayden Panhuyzen on 2017-12-03.
//  Copyright © 2017 Ayden Panhuyzen. All rights reserved.
//

import UIKit

extension NSAttributedString {
    var largestFontSize: CGFloat? {
        var size: CGFloat?
        self.enumerateAttribute(.font, in: NSMakeRange(0, length), options: []) { (value, range, stop) in
            let font = value as! UIFont
            if size == nil || font.pointSize > size! {
                size = font.pointSize
            }
        }
        return size
    }
}

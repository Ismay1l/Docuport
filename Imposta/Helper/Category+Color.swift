//
//  Category+Color.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 8/29/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat) {
        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: 1.0)
    }
    
    convenience init(netHex: Int, colorAlpha: CGFloat) {
        self.init(red:(netHex >> 16) & 0xff,
                  green:(netHex >> 8) & 0xff,
                  blue:netHex & 0xff,
                  a: colorAlpha)
    }
    
    convenience init(hexStr: String, colorAlpha: CGFloat) {
        var rgbHexInt: UInt64 = 0
        
        let scanner = Scanner(string: hexStr)
        scanner.scanLocation = 0
        scanner.scanHexInt64(&rgbHexInt)
        
        self.init(red: CGFloat((rgbHexInt & 0xff0000) >> 16) / 0xff,
                  green: CGFloat((rgbHexInt & 0xff00) >> 8) / 0xff,
                  blue: CGFloat(rgbHexInt & 0xff) / 0xff,
                  alpha: colorAlpha)
    }
}

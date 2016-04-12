//
//  UIColorExtensions.swift
//  Launchify
//
//  Created by Clay Ellis on 4/8/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

// MARK: - Color
extension UIColor {
    public convenience init?(hexString: String, alpha: Float) {
        var hex = hexString
        
        // Check for hash and remove the hash
        if hex.hasPrefix("#") {
            hex = hex.substringFromIndex(hex.startIndex.advancedBy(1))
        }
        
        if (hex.rangeOfString("(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .RegularExpressionSearch) != nil) {
            
            // Deal with 3 character Hex strings
            if hex.characters.count == 3 {
                let redHex   = hex.substringToIndex(hex.startIndex.advancedBy(1))
                let greenHex = hex.substringWithRange(hex.startIndex.advancedBy(1) ..< hex.startIndex.advancedBy(2))
                let blueHex  = hex.substringFromIndex(hex.startIndex.advancedBy(2))
                
                hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex
            }
            
            let redHex = hex.substringToIndex(hex.startIndex.advancedBy(2))
            let greenHex = hex.substringWithRange(hex.startIndex.advancedBy(2) ..< hex.startIndex.advancedBy(4))
            let blueHex = hex.substringWithRange(hex.startIndex.advancedBy(4) ..< hex.startIndex.advancedBy(6))
            
            var redInt:   CUnsignedInt = 0
            var greenInt: CUnsignedInt = 0
            var blueInt:  CUnsignedInt = 0
            
            NSScanner(string: redHex).scanHexInt(&redInt)
            NSScanner(string: greenHex).scanHexInt(&greenInt)
            NSScanner(string: blueHex).scanHexInt(&blueInt)
            
            self.init(red: CGFloat(redInt) / 255.0, green: CGFloat(greenInt) / 255.0, blue: CGFloat(blueInt) / 255.0, alpha: CGFloat(alpha))
        }
        else {
            // Note:
            // The swift 1.1 compiler is currently unable to destroy partially initialized classes in all cases,
            // so it disallows formation of a situation where it would have to.  We consider this a bug to be fixed
            // in future releases, not a feature. -- Apple Forum
            self.init()
            return nil
        }
    }
    
    public convenience init?(hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }
    
    class func lfDarkestGray() -> UIColor { return UIColor(hexString: "2B2B2B")! }
    class func lfDarkGray() -> UIColor { return UIColor(hexString: "2E302E")! }    
    class func lfMediumGray() -> UIColor { return UIColor(hexString: "373937")! }
    class func lfSeparatorGray() -> UIColor { return UIColor(hexString: "696969")! }
    class func lfLightGray() -> UIColor { return UIColor(hexString: "A4A4A4")! }
    class func lfGreen() -> UIColor { return UIColor(hexString: "1ED760")! }
}

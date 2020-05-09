//
//  UIFontExt.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/10.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UIKit.UIFont {
    
    class func setCustomFont(style fontFamily: String, fontSize size: CGFloat) -> UIFont {
        
        if fontFamily == "Monospaced" {
            return UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
            
        } else if fontFamily == "System-Font" {
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }
        
        return UIFont(name: fontFamily, size: size)!
    }
}

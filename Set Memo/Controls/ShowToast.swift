//
//  ShowToast.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/29.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import SmartToast

class ShowToast {
    
    static func toast(message: String?, duration: Double) {
        
        let defaults = UserDefaults.standard
        var style = ToastStyle()
        
        if defaults.bool(forKey: Resource.Defaults.useDarkMode) == true {
            style.backgroundColor = UIColor.darkGray
            
        } else {
            style.backgroundColor = UIColor.black
        }
        
        ToastManager.shared.showToast(message!, duration: duration, position: .center, style: style)
    }
}

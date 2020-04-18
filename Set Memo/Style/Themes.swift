//
//  Themes.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/24.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

struct InterfaceColors {
    static var viewBackgroundColor = UIColor()
    static var secondaryBackgroundColor = UIColor()
    static var navigationBarColor = UIColor()
    static var cellColor = UIColor()
    static var fontColor = UIColor()
    static var iconColor = UIColor()
    static var actionSheetColor = UIColor()
    static var separatorColor = UIColor()
    static var textViewColor = UIColor()
}

class Themes {
    
    func setupDefaultTheme() {
        InterfaceColors.viewBackgroundColor = .white
        InterfaceColors.secondaryBackgroundColor = UIColor.secondaryColor
        InterfaceColors.navigationBarColor = .white
        InterfaceColors.cellColor = .white
        InterfaceColors.fontColor = .black
        InterfaceColors.iconColor = Colors.shared.accentColor
        InterfaceColors.separatorColor = .lightGray
    }
    
    func setupPureDarkTheme() {
        InterfaceColors.viewBackgroundColor = .black
        InterfaceColors.textViewColor = .black
        InterfaceColors.secondaryBackgroundColor = .black
        InterfaceColors.cellColor = UIColor(hexString: "#232323")
        InterfaceColors.fontColor = .white
        InterfaceColors.navigationBarColor = .black
        InterfaceColors.actionSheetColor = .black
        InterfaceColors.separatorColor = .white
    }
    
    func triggerSystemMode(mode: UITraitCollection) {
        if mode.userInterfaceStyle == .light {
            setupDefaultTheme()
            UserDefaults.standard.set(false, forKey: "useDarkMode")
        } else {
            setupPureDarkTheme()
            UserDefaults.standard.set(true, forKey: "useDarkMode")
        }
    }
}

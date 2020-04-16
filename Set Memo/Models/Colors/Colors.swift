//
//  Colors.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/06.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

public class Colors {
    
    public static var shared = Colors()
    
    private init() {}
    
    // MARK: Colors
    static let cellLight = UIColor(hexString: "#f6f6f6")
    static let cellDark = UIColor(hexString: "#232323")
    
    static let redColor = UIColor.red
    
    static let whiteColor = UIColor.white
    
    static let darkgrayColor = UIColor.darkGray
    
    var defaultTintColor: UIColor {
        return UIColor.colorFromString(from: UserDefaults.standard.integer(forKey: Resource.Defaults.defaultTintColor))
    }
    
    public var primaryColor: UIColor {
        return #colorLiteral(red: 0, green: 0.3313085437, blue: 0.7222445011, alpha: 1)
    }
    
    var secondaryColor: UIColor {
        return #colorLiteral(red: 0, green: 0.7506982088, blue: 0.6462552547, alpha: 1)
    }
    
    var accentColor: UIColor {
        return UIColor.systemIndigo
    }
    
    var subColor: UIColor {
        return UIColor(hexString: "#AFABAE")
    }
    
    var reminderBtn: UIColor {
        return UIColor(hexString: "#59C3AC")
    }
    
    var importantBtn: UIColor {
        return UIColor(hexString: "#ffa534")
    }
    
    var mainTextColor: UIColor {
        return UIColor(hexString: "#121212")
    }
    
    var systemGrayColor: UIColor {
        return UIColor.systemGray
    }
    
    var darkColor: UIColor {
        return UIColor(hexString: "#2c302d")
    }
}

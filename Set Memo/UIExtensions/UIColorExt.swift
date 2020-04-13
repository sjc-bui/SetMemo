//
//  UIColorExt.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/29.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let lightRed = UIColor(hexString: "#fe8176")
    static let lightRedBack = UIColor(hexString: "#dd564b")
    static let medRed = UIColor(hexString: "#fe9772")
    static let lightOrange = UIColor(hexString: "#feab6d")
    static let medOrange = UIColor(hexString: "#fdc168")
    static let lightYellow = UIColor(hexString: "#fed777")
    static let medYellow = UIColor(hexString: "#fde077")
    static let lightGreen = UIColor(hexString: "#c0df81")
    static let medGreen = UIColor(hexString: "#9bd770")
    static let heavyGreen = UIColor(hexString: "#79bea8")
    static let lightBlue = UIColor(hexString: "#609ce1")
    static let medBlue = UIColor(hexString: "#678ffe")
    static let lightPurple = UIColor(hexString: "#8a8aef")
    static let medPurple = UIColor(hexString: "#905bec")
    static let azDarkPink = UIColor(hexString: "#c06c84")
    static let azGold = UIColor(hexString: "#e8bc76")
    static let darkBlue = UIColor(hexString: "#2b589b")
    
    static var defaultColors = ["lightRed", "lightRedBack", "medRed", "lightOrange", "medOrange", "lightYellow", "medYellow", "lightGreen", "medGreen", "heavyGreen", "lightBlue", "medBlue", "lightPurple", "medPurple", "azDarkPink", "azGold", "darkBlue"]
    
    static func getRandomColor() -> String {
        let random = UIColor.defaultColors.randomElement() ?? "white"
        return random
    }
    
    static func getRandomColorFromString(color: String) -> UIColor {
        
        switch color {
        case "lightRed":
            return .lightRed
        case "lightRedBack":
            return .lightRedBack
        case "medRed":
            return .medRed
        case "lightOrange":
            return .lightOrange
        case "medOrange":
            return .medOrange
        case "lightYellow":
            return .lightYellow
        case "medYellow":
            return .medYellow
        case "lightGreen":
            return .lightGreen
        case "medGreen":
            return .medGreen
        case "heavyGreen":
            return .heavyGreen
        case "lightBlue":
            return .lightBlue
        case "medBlue":
            return .medBlue
        case "lightPurple":
            return .lightPurple
        case "medPurple":
            return .medPurple
        case "azDarkPink":
            return .azDarkPink
        case "azGold":
            return .azGold
        default:
            return .darkBlue
        }
    }
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    static func random(from colors: [UIColor]) -> UIColor? {
        return colors.randomElement()
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        }
        return nil
    }
    
    static func colorFromString(from indexTintColor: Int) -> UIColor {
        
        switch indexTintColor {
        case 1:
            return UIColor.systemRed
        case 2:
            return UIColor.systemOrange
        case 3:
            return UIColor.systemPink
        case 4:
            return UIColor.systemBlue
        case 5:
            return UIColor.systemGreen
        case 6:
            return UIColor(hexString: "#E5B104")
        default:
            return UIColor.systemIndigo
        }
    }
}

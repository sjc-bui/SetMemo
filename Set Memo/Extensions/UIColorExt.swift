//
//  UIColorExt.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/29.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let red = UIColor(hexString: "#f44336")
    static let pink = UIColor(hexString: "#e91e63")
    static let purple = UIColor(hexString: "#9c27b0")
    static let purple2 = UIColor(hexString: "#7c5475")
    static let deepPurple = UIColor(hexString: "#673ab7")
    static let indigo = UIColor(hexString: "#3f51b5")
    static let blue = UIColor(hexString: "#2196f3")
    static let lightBlue = UIColor(hexString: "#03a9f4")
    static let cyan = UIColor(hexString: "#00bcd4")
    static let teal = UIColor(hexString: "#009688")
    static let green = UIColor(hexString: "#4caf50")
    static let lightGreen = UIColor(hexString: "#8bc34a")
    static let amber = UIColor(hexString: "#ffc107")
    static let orange = UIColor(hexString: "#ff9800")
    static let deepOrange = UIColor(hexString: "#ff5722")
    static let brown = UIColor(hexString: "#795548")
    static let blueGrey = UIColor(hexString: "#607d8b")
    
    static let secondaryColor = UIColor(hexString: "#EDEDED")
    static let secondaryBlackColor = UIColor(hexString: "#242426")
    
    static let primaryText = UIColor(hexString: "#FFFFFF")
    static let secondaryText = UIColor(hexString: "#EBEBF5")
    
    static let pureCellBackground = UIColor(hexString: "#191919")
    
    static var defaultColors = ["red", "pink", "purple", "purple2", "deepPurple", "indigo", "blue", "lightBlue", "cyan", "teal", "green", "lightGreen", "amber", "orange", "deepOrange", "brown", "blueGrey"]
    
    static func getRandomColor() -> String {
        let random = UIColor.defaultColors.randomElement() ?? "white"
        return random
    }
    
    static func getRandomColorFromString(color: String) -> UIColor {
        
        switch color {
        case "red":
            return .red
        case "pink":
            return .pink
        case "purple":
            return .purple
        case "purple2":
            return .purple2
        case "deepPurple":
            return .deepPurple
        case "indigo":
            return .indigo
        case "blue":
            return .blue
        case "lightBlue":
            return .lightBlue
        case "cyan":
            return .cyan
        case "teal":
            return .teal
        case "green":
            return .green
        case "lightGreen":
            return .lightGreen
        case "amber":
            return .amber
        case "orange":
            return .orange
        case "deepOrange":
            return .deepOrange
        case "blueGrey":
            return .blueGrey
        default:
            return .brown
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

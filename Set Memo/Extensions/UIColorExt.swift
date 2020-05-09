//
//  UIColorExt.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/29.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UIColor {
    
    // material color
    static let red = UIColor(hexString: "#f44336")
    static let pink = UIColor(hexString: "#e91e63")
    static let deepPurple = UIColor(hexString: "#673ab7")
    static let indigo = UIColor(hexString: "#3f51b5")
    static let blue = UIColor(hexString: "#2196f3")
    static let teal = UIColor(hexString: "#009688")
    static let green = UIColor(hexString: "#4caf50")
    static let amber = UIColor(hexString: "#ffc107")
    static let deepOrange = UIColor(hexString: "#ff5722")
    
    // soft color
    static let appleValley = UIColor(hexString: "#ea8685")
    static let brewedMustard = UIColor(hexString: "#e77f67")
    static let creamyPeach = UIColor(hexString: "#f3a683")
    static let oldGeranium = UIColor(hexString: "#cf6a87")
    static let purpleMountain = UIColor(hexString: "#786fa6")
    static let rosyHighLight = UIColor(hexString: "#f7d794")
    static let roguePink = UIColor(hexString: "#f8a5c2")
    static let softBlue = UIColor(hexString: "#778beb")
    static let squeaky = UIColor(hexString: "#63cdda")
    
    // soft color 2
    static let forceLainRose = UIColor(hexString: "#e66767")
    static let tigerLily = UIColor(hexString: "#e15f41")
    static let sawtooth = UIColor(hexString: "#f19066")
    static let deepRose = UIColor(hexString: "#c44569")
    static let purpleCorallite = UIColor(hexString: "#574b90")
    static let summerTime = UIColor(hexString: "#f5cd79")
    static let flamingoPink = UIColor(hexString: "#f78fb3")
    static let cornFlower = UIColor(hexString: "#546de5")
    static let blueCuracao = UIColor(hexString: "#3dc1d3")
    
    // color 3
    static let richGardenia = UIColor(hexString: "#F97F51")
    static let clearChill = UIColor(hexString: "#1B9CFC")
    static let honeyGlow = UIColor(hexString: "#EAB543")
    static let keppel = UIColor(hexString: "#58B19F")
    static let pineGlade = UIColor(hexString: "#BDC581")
    static let blueBell = UIColor(hexString: "#3B3B98")
    static let fieryFuchsia = UIColor(hexString: "#B33771")
    static let socks = UIColor(hexString: "#FC427B")
    static let highlighterLavender = UIColor(hexString: "#82589F")
    
    static let secondaryColor = UIColor(hexString: "#EDEDED")
    static let secondaryBlackColor = UIColor(hexString: "#242426")
    static let primaryText = UIColor(hexString: "#FFFFFF")
    static let secondaryText = UIColor(hexString: "#EBEBF5")
    
    static let pureCellBackground = UIColor(hexString: "#191919")
    
    static var defaultColors = ["a", "b", "c", "d", "e", "f", "g", "h", "i"]
    
    static func getRandomColor() -> String {
        let random = UIColor.defaultColors.randomElement() ?? "white"
        return random
    }
    
    static func getRandomColorFromString(color: String) -> UIColor {
        
        if UserDefaults.standard.integer(forKey: Resource.Defaults.defaultCellColor) == 0 {
            switch color {
            case "a":
                return .red
            case "b":
                return .deepOrange
            case "c":
                return .amber
            case "d":
                return .pink
            case "e":
                return .deepPurple
            case "f":
                return .indigo
            case "g":
                return .blue
            case "h":
                return .green
            default:
                return .teal
            }
            
        } else if UserDefaults.standard.integer(forKey: Resource.Defaults.defaultCellColor) == 1 {
            
            switch color {
            case "a":
                return .richGardenia
            case "b":
                return .clearChill
            case "c":
                return .honeyGlow
            case "d":
                return .keppel
            case "e":
                return .pineGlade
            case "f":
                return .blueBell
            case "g":
                return .fieryFuchsia
            case "h":
                return .socks
            default:
                return .highlighterLavender
            }
            
        } else if UserDefaults.standard.integer(forKey: Resource.Defaults.defaultCellColor) == 2 {
            
            switch color {
            case "a":
                return .forceLainRose
            case "b":
                return .tigerLily
            case "c":
                return .sawtooth
            case "d":
                return .deepRose
            case "e":
                return .purpleCorallite
            case "f":
                return .summerTime
            case "g":
                return .flamingoPink
            case "h":
                return .cornFlower
            default:
                return .blueCuracao
            }
            
        } else {
            
            switch color {
            case "a":
                return .appleValley
            case "b":
                return .brewedMustard
            case "c":
                return .creamyPeach
            case "d":
                return .oldGeranium
            case "e":
                return .purpleMountain
            case "f":
                return .rosyHighLight
            case "g":
                return .roguePink
            case "h":
                return .softBlue
            default:
                return .squeaky
            }
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
            return UIColor.systemIndigo
        default:
            return UIColor(hexString: "#E5B104")
        }
    }
}

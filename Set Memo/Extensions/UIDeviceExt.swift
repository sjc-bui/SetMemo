//
//  UIDeviceExt.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/04.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UIDevice {
    
    enum DevicePlatform: String {
        case other = "Old Device"
        case iPhone6S = "iPhone 6S"
        case iPhone6SPlus = "iPhone 6S Plus"
        case iPhone7 = "iPhone 7"
        case iPhone7Plus = "iPhone 7 Plus"
    }
    
    var platform: DevicePlatform {
        var sysinfo = utsname()
        uname(&sysinfo)
        let platform = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        switch platform {
        case "iPhone9,2", "iPhone9,4":
            return .iPhone7Plus
        case "iPhone9,1", "iPhone9,3":
            return .iPhone7
        case "iPhone8,2":
            return .iPhone6SPlus
        case "iPhone8,1":
            return .iPhone6S
        default:
            return .other
        }
    }
    
    var hasHapticFeedback: Bool {
        return platform == .iPhone7 || platform == .iPhone7Plus
    }
}

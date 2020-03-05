//
//  DeviceControl.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/05.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class DeviceControl {
    
    func feedbackOnPress() {
        if UIDevice.current.hasHapticFeedback == true {
            // iPhone 7 and newer
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }
}

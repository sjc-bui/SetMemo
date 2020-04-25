//
//  Dimension.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/03.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

public class Dimension {
    
    public static var shared = Dimension()
    
    let small: CGFloat = 13
    let medium: CGFloat = 17
    let large: CGFloat = 23
    let maximum: CGFloat = 27
        
    var widthScale: CGFloat = 1.0
    var heightScale: CGFloat = 1.0
    
    private init() {
        widthScale = 1
        heightScale = 1
    }
    
    var fontSmallSize: CGFloat {
        return small * heightScale
    }
    
    var fontMediumSize: CGFloat {
        return medium * heightScale
    }
    
    var subLabelSize: CGFloat {
        return 14 * heightScale
    }
    
    var fontLargeSize: CGFloat {
        return large * heightScale
    }
    
    var fontMaxSize: CGFloat {
        return maximum * heightScale
    }
    
    var iconSize: CGFloat {
        return 18 * heightScale
    }
    
    var showTutorialLabelSize: CGFloat {
        return 15 * heightScale
    }
    
    var reminderBoundHeight: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 310 * heightScale
        } else {
            return 210
        }
    }
    
    var datePickerBottomAnchor: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 120
        } else {
            return 70
        }
    }
}

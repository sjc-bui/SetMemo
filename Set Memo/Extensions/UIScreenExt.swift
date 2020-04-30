//
//  UIScreenExt.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/09.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UIScreen {
    
    static let screenSize = UIScreen.main.bounds.size
    
    class var width: CGFloat {
        return screenSize.width
    }
    
    class var height: CGFloat {
        return screenSize.height
    }
}

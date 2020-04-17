//
//  UILabelExt.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/02.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UILabel {
    
    func textDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}

//
//  UITableViewExt.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    func selectedBackground() {
        let customColorView = UIView()
        customColorView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        self.selectedBackgroundView = customColorView
        self.isSelected = false
    }
}

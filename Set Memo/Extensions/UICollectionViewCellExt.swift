//
//  UICollectionViewCellExt.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    
    func setCellStyle(background: UIColor, radius: CGFloat = 12) {
        self.clipsToBounds = true
        self.layer.roundCorner(radius: radius)
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.backgroundColor = background
    }
}

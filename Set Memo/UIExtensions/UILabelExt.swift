//
//  UILabelExt.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/02.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class paddingLabel: UILabel {
    var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 5)
    
    func labelPadding(rect: CGRect) {
        let insets: UIEdgeInsets = padding
        super.draw(rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += padding.top + padding.bottom
        intrinsicSuperViewContentSize.width += padding.left + padding.right
        return intrinsicSuperViewContentSize
    }
}

extension UILabel {
    func textDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}

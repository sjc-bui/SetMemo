//
//  UIAlertControllerExt.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/01.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}

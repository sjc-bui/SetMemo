//
//  UINavigationItemExt.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/27.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UINavigationItem {
    func rightBarButtonEnable(isEnabled: Bool) {
        self.rightBarButtonItem?.isEnabled = isEnabled
    }
}

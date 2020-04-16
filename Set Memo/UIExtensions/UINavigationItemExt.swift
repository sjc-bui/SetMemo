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
    
    func setBackButtonTitle(title: String?) {
        let backBarButton = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        self.backBarButtonItem = backBarButton
    }
    
    func removeBarButtonItem(item: UIBarButtonItem) {
        guard let itemIndex = self.rightBarButtonItems?.firstIndex(of: item) else { return }
        self.rightBarButtonItems?.remove(at: itemIndex)
    }
    
    func addToRightBar(item: UIBarButtonItem) {
        guard ((self.rightBarButtonItems?.firstIndex(of: item)) == nil) else { return }
        self.rightBarButtonItems?.append(item)
    }
}

extension UINavigationBar {
    
    func setColors(background: UIColor, text: UIColor) {
        isTranslucent = false
        backgroundColor = background
        barTintColor = background
        tintColor = text
        setBackgroundImage(UIImage(), for: .default)
        //titleTextAttributes = [.foregroundColor: text]
        prefersLargeTitles = false
        shadowImage = UIImage()
    }
}

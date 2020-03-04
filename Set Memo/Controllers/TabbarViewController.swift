//
//  TabbarViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class TabbarViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let memoView = MemoViewController()
        memoView.title = NSLocalizedString("Memo", comment: "")
        memoView.tabBarItem.image = UIImage(named: "memo")
        let navMemoView = UINavigationController(rootViewController: memoView)
        
        let settingView = SettingViewController()
        settingView.title = NSLocalizedString("Setting", comment: "")
        settingView.tabBarItem.image = UIImage(named: "setting")
        let navSetting = UINavigationController(rootViewController: settingView)
        
        UITabBar.appearance().barTintColor = UIColor(hexString: "#4d5650")
        UITabBar.appearance().tintColor = UIColor.white
        // Create tab bar.
        self.viewControllers = [navMemoView, navSetting]
    }
}

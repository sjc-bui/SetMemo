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
//    
//    override func viewWillAppear(_ animated: Bool) {
//        let memoView = MemoViewController()
//        memoView.tabBarItem.image = UIImage(named: "memo")
//        memoView.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        let navMemoView = UINavigationController(rootViewController: memoView)
//        
//        let settingView = SettingViewController()
//        settingView.tabBarItem.image = UIImage(named: "setting")
//        settingView.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        let navSetting = UINavigationController(rootViewController: settingView)
//        
//        UITabBar.appearance().tintColor = Colors.red2
//        
//        self.viewControllers = [navMemoView, navSetting]
//    }
}

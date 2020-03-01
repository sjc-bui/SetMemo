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
        memoView.tabBarController?.tabBar.tintColor = UIColor.white
        memoView.tabBarController?.tabBar.backgroundColor = UIColor.black
        let navMemoView = UINavigationController(rootViewController: memoView)
        
        let todoView = RemindViewController()
        todoView.title = NSLocalizedString("Remind", comment: "")
        todoView.tabBarItem.image = UIImage(named: "remind")
        todoView.tabBarController?.tabBar.tintColor = UIColor.white
        todoView.tabBarController?.tabBar.backgroundColor = UIColor.black
        let navTodoView = UINavigationController(rootViewController: todoView)
        
        let settingView = SettingViewController()
        settingView.title = NSLocalizedString("Setting", comment: "")
        settingView.tabBarItem.image = UIImage(named: "setting")
        settingView.tabBarController?.tabBar.tintColor = UIColor.white
        settingView.tabBarController?.tabBar.backgroundColor = UIColor.black
        let navSetting = UINavigationController(rootViewController: settingView)
        
        // Create tab bar.
        self.viewControllers = [navMemoView, navTodoView, navSetting]
    }
}

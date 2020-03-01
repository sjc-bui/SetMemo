//
//  AppDelegate.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create window container
        window = UIWindow(frame: UIScreen.main.bounds)
        let tabBarViewController = TabbarViewController()
        window!.rootViewController = tabBarViewController
        window!.makeKeyAndVisible()
        return true
    }
}


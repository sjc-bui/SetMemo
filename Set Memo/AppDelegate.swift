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
        
        UserDefaults.standard.register(defaults: [
            Defaults.vibrationOnTouch: true,
            Defaults.randomColor: false,
            Defaults.displayDateTime: true,
            Defaults.showAlertOnDelete: true,
            Defaults.writeNotePlaceholder: "Write something...",
            Defaults.useBiometrics: false
        ])
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        let privacyController = PrivacyController()
        privacyController.removeBlurView(window: window!)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if UserDefaults.standard.bool(forKey: Defaults.useBiometrics) == true {
            let privacyController = PrivacyController()
            privacyController.setupBiometricsView(window: window!)
            privacyController.unlockButton.addTarget(self, action: #selector(unlockApp(sender:)), for: .touchUpInside)
            privacyController.authenticateUserWithBioMetrics(window: window!)
        }
    }
    
    @objc func unlockApp(sender: UIButton) {
        // Call authenticateUserWithBiometrics method when user click unlock button
        let privacyController = PrivacyController()
        privacyController.authenticateUserWithBioMetrics(window: window!)
    }
}


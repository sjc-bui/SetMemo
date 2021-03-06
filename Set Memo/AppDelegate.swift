//
//  AppDelegate.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let themes = Themes()
    let notificationCenter = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UserDefaults.standard.register(defaults: [
            Resource.Defaults.theme: 0,
            Resource.Defaults.iconType: "light",
            Resource.Defaults.vibrationOnTouch: true,
            Resource.Defaults.showAlertOnDelete: false,
            Resource.Defaults.displayDateTime: true,
            Resource.Defaults.useBiometrics: false,
            Resource.Defaults.sortBy: "dateCreated",
            Resource.Defaults.remindEveryDay: false,
            Resource.Defaults.useDarkMode: false,
            Resource.Defaults.firstTimeDeleted: true,
            Resource.Defaults.defaultFontStyle: "HelveticaNeue-Medium",
            Resource.Defaults.defaultTextViewFontSize: 18,
            Resource.Defaults.defaultTintColor: 0,
            Resource.Defaults.defaultCellColor: 0,
            Resource.Defaults.remindEverydayContent: "What happening today?",
            Resource.Defaults.passwordForBiometricIsSet: false,
            Resource.Defaults.useCellColor: true,
            Resource.Defaults.sortByAsc: false,
            Resource.Defaults.unlockTemporarily: false
        ])
        
        if UserDefaults.standard.bool(forKey: Resource.Defaults.useDarkMode) {
            themes.setupPureDarkTheme()
            
        } else {
            themes.setupDefaultTheme()
        }
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) { (allow, error) in
            if !allow {
                print("user didn't allow")
            }
        }
        notificationCenter.delegate = self
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.set(false, forKey: Resource.Defaults.unlockTemporarily)
        self.saveContext()
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Memo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

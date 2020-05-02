//
//  PrivacyController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/07.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import LocalAuthentication
import SwiftKeychainWrapper

class PrivacyController: UITableViewController {
    let sections: Array = ["Biometrics".localized]
    let biometrics: Array = ["UseTouchOrFaceId".localized]
    let defaults = UserDefaults.standard
    let keychain = KeychainWrapper.standard
    
    let service: String = "authService"
    let account: String = "userAccount"
    
    private let reuseIdentifier = "CellId"
    private let reuseSwitchCell = "SettingSwitchCell"
    let theme = ThemesViewController()
    let themes = Themes()
    let setting = SettingViewController()
    
    let blurEffectView = UIVisualEffectView()
    let unlockImage: UIImageView = {
        let img = UIImageView()
        img.image = Resource.Images.unlockButton
        img.frame = CGRect(x: 0, y: 0, width: 62, height: 62)
        img.contentMode = .scaleAspectFill
        img.tintColor = UIColor.white
        img.tag = 101
        return img
    }()
    
    // Call this method when app enter foreground. and biometrics is enabled.
    func setupBiometricsView(window: UIWindow) {
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView.effect = blurEffect
        blurEffectView.frame = window.frame
        blurEffectView.alpha = 1
        blurEffectView.tag = 100
        
        unlockImage.center = window.center
        unlockImage.alpha = 0
        
        window.addSubviews([blurEffectView, unlockImage])
    }
    
    func authenticateUserWithBioMetrics(window: UIWindow) {
        // using Local Authentication.
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Reason".localized
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evaluateError in
                DispatchQueue.main.async {
                    
                    if success {
                        
                        // remove unlock button
                        window.viewWithTag(101)?.removeFromSuperview()
                        // remove blur view with animation
                        UIView.animate(withDuration: 0.3, animations: {
                            window.viewWithTag(100)?.alpha = 0
                        }) { _ in
                            self.blurEffectView.removeFromSuperview()
                        }
                        print("unlock successfully")
                        
                    } else {
                        
                        guard let error = evaluateError else {
                            return
                        }
                        
                        // display unlock button if error with biometric
                        UIView.animate(withDuration: 0.2, animations: {
                            self.unlockImage.alpha = 1
                            
                        }) {_ in
                            let message = self.showErrorMessageForLAErrorCode(errorCode: error._code)
                            print(message)
                        }
                    }
                }
            }
        }
    }
    
    func showErrorMessageForLAErrorCode( errorCode:Int ) -> String{
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"

        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        // check biometrics is available or not
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
                case LAError.biometryNotAvailable.rawValue:
                    message = "Authentication could not start because the device does not support biometric authentication."
                
                case LAError.biometryLockout.rawValue:
                    message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
                case LAError.biometryNotEnrolled.rawValue:
                    message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
                default:
                    message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
                case LAError.touchIDLockout.rawValue:
                    message = "Too many failed attempts."
                
                case LAError.touchIDNotAvailable.rawValue:
                    message = "TouchID is not available on the device"
                
                case LAError.touchIDNotEnrolled.rawValue:
                    message = "TouchID is not enrolled on the device"
                
                default:
                    message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    func removeBlurView(window: UIWindow) {
        // remove blur view when app enter background.
        window.viewWithTag(100)?.removeFromSuperview()
        window.viewWithTag(101)?.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Privacy".localized
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(SettingSwitchCell.self, forCellReuseIdentifier: reuseSwitchCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDynamicElements()
    }
    
    func setupDynamicElements() {
        if theme.darkModeEnabled() == false {
            themes.setupDefaultTheme()
            setupDefaultPersistentNavigationBar()
            
            view.backgroundColor = InterfaceColors.secondaryBackgroundColor
            
        } else if theme.darkModeEnabled() == true {
            themes.setupPureDarkTheme()
            setupDarkPersistentNavigationBar()
            
            view.backgroundColor = InterfaceColors.secondaryBackgroundColor
        }
    }
    
    func setupDefaultPersistentNavigationBar() {
        navigationController?.navigationBar.backgroundColor = InterfaceColors.secondaryBackgroundColor
        navigationController?.navigationBar.barTintColor = InterfaceColors.secondaryBackgroundColor
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setupDarkPersistentNavigationBar() {
        navigationController?.navigationBar.backgroundColor = InterfaceColors.secondaryBackgroundColor
        navigationController?.navigationBar.barTintColor = InterfaceColors.secondaryBackgroundColor
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return biometrics.count
            
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseSwitchCell, for: indexPath) as! SettingSwitchCell
                cell.textLabel?.text = "\(biometrics[indexPath.row])"
                
                cell.selectionStyle = .none
                cell.switchButton.addTarget(self, action: #selector(useBiometric(sender:)), for: .valueChanged)
                
                if defaults.bool(forKey: Resource.Defaults.useBiometrics) == true {
                    cell.switchButton.isOn = true
                    
                } else {
                    cell.switchButton.isOn = false
                }
                setting.setupDynamicCells(cell: cell, arrow: false)
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                return cell
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            
            cell.backgroundColor = .white
            cell.textLabel?.textColor = Colors.shared.darkColor
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "UsePassword".localized
        }
        
        return ""
    }
    
    @objc func useBiometric(sender: UISwitch) {
        
        if sender.isOn == true {
            
            // set password to use for entire app
            if defaults.bool(forKey: Resource.Defaults.passwordForBiometricIsSet) == false {
                
                let alertController = UIAlertController(title: "SetPassword".localized, message: nil, preferredStyle: .alert)
                
                alertController.addTextField { (password) in
                    password.isSecureTextEntry = true
                    password.placeholder = "InputPassword".localized
                }
                alertController.addTextField { (confirmPassword) in
                    confirmPassword.isSecureTextEntry = true
                    confirmPassword.placeholder = "ConfirmPassword".localized
                }
                
                alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { _ in
                    sender.isOn = false
                }))
                alertController.addAction(UIAlertAction(title: "Done".localized, style: .default, handler: { _ in
                    let password = alertController.textFields?.first?.text ?? ""
                    let confirmPassword = alertController.textFields![1].text ?? ""
                    
                    if !password.isNullOrWhiteSpace() && password.elementsEqual(confirmPassword) {
                        // remove keychain if already exist and set new key.
                        self.keychain.removeObject(forKey: Resource.Defaults.passwordToUseBiometric)
                        let saveSuccess = self.keychain.set(password, forKey: Resource.Defaults.passwordToUseBiometric)
                        if saveSuccess {
                            print("save keychain success")
                            self.defaults.set(true, forKey: Resource.Defaults.passwordForBiometricIsSet)
                            self.defaults.set(true, forKey: Resource.Defaults.useBiometrics)
                        }
                        
                    } else {
                        print("Wrong password format.")
                        sender.isOn = false
                    }
                }))
                
                if defaults.bool(forKey: Resource.Defaults.useDarkMode) == true {
                    alertController.overrideUserInterfaceStyle = .dark
                    
                } else {
                    alertController.overrideUserInterfaceStyle = .light
                }
                
                alertController.view.tintColor = Colors.shared.defaultTintColor
                present(alertController, animated: true, completion: nil)
                
            } else {
                defaults.set(true, forKey: Resource.Defaults.useBiometrics)
            }
            
        } else {
//            let removeSuccess = keychain.removeObject(forKey: Resource.Defaults.passwordToUseBiometric)
            defaults.set(false, forKey: Resource.Defaults.useBiometrics)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if theme.darkModeEnabled() == true {
            return .lightContent
            
        } else {
            return .darkContent
        }
    }
}

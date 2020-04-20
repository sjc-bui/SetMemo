//
//  PrivacyController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/07.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import LocalAuthentication
import EMAlertController

class PrivacyController: UITableViewController {
    let sections: Array = ["Biometrics".localized, "Password".localized]
    let biometrics: Array = ["UseTouchOrFaceId".localized]
    let passcode: Array = ["SetPassword".localized]
    let defaults = UserDefaults.standard
    
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
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Reason".localized
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
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
                        print("unlock error !!!!!")
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
        navigationController?.navigationBar.backgroundColor = InterfaceColors.navigationBarColor
        navigationController?.navigationBar.barTintColor = InterfaceColors.navigationBarColor
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setupDarkPersistentNavigationBar() {
        navigationController?.navigationBar.backgroundColor = InterfaceColors.navigationBarColor
        navigationController?.navigationBar.barTintColor = InterfaceColors.navigationBarColor
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
            
        } else if section == 1 {
            return passcode.count
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
                setting.setupDynamicCells(cell: cell)
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 1 {
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(passcode[indexPath.row])"
                setting.setupDynamicCells(cell: cell)
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                return cell
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            
            cell.backgroundColor = Colors.whiteColor
            cell.textLabel?.textColor = Colors.shared.darkColor
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return "UsePassword".localized
        }
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
            
            switch indexPath.row {
            case 0:
                
                let alert = EMAlertController(title: "SetPassword".localized, message: "Set password for your memo")
                alert.addTextField { (password) in
                    password?.isSecureTextEntry = true
                    password?.placeholder = "InputPassword".localized
                }
                alert.addTextField { (confirmPassword) in
                    confirmPassword?.isSecureTextEntry = true
                    confirmPassword?.placeholder = "ConfirmPassword".localized
                }
                
                let cancel = EMAlertAction(title: "Cancel".localized, style: .cancel)
                let done = EMAlertAction(title: "Done".localized, style: .normal) {
                    let password = alert.textFields.first?.text
                    let confirmPassword = alert.textFields[1].text
                    
                    KeychainService.savePasswordToKeychain(service: self.service, account: self.account, data: password!)
                    KeychainService.loadPasswordFromKeychain(service: self.service, account: self.account, data: password!)
                }
                alert.addAction(done)
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
                
            default:
                return
            }
        }
    }
    
    @objc func useBiometric(sender: UISwitch) {
        
        if sender.isOn == true {
            defaults.set(true, forKey: Resource.Defaults.useBiometrics)
            
        } else {
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

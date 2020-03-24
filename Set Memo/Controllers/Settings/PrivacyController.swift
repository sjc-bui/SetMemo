//
//  PrivacyController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/07.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import LocalAuthentication

class PrivacyController: UITableViewController {
    let sections: Array = [NSLocalizedString("Biometrics", comment: "")]
    let biometrics: Array = [NSLocalizedString("UseTouchOrFaceId", comment: "")]
    let defaults = UserDefaults.standard
    
    private let reuseIdentifier = "CellId"
    private let reuseSwitchCell = "SettingSwitchCell"
    
    let blurEffectView = UIVisualEffectView()
    let unlockButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        button.setTitle(NSLocalizedString("UnlockApp", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.isUserInteractionEnabled = true
        button.layer.cornerRadius = 6
        button.tag = 101
        
        return button
    }()
    
    // Call this method when app enter foreground. and biometrics is enabled.
    func setupBiometricsView(window: UIWindow) {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView.effect = blurEffect
        blurEffectView.frame = window.frame
        blurEffectView.alpha = 1
        
        unlockButton.center = window.center
        unlockButton.backgroundColor = Colors.shared.secondaryColor
        blurEffectView.tag = 100
        unlockButton.alpha = 0
        
        window.addSubview(blurEffectView)
        window.addSubview(unlockButton)
    }
    
    func authenticateUserWithBioMetrics(window: UIWindow) {
        // using Local Authentication.
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = NSLocalizedString("Reason", comment: "")
            
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
                    } else {
                        guard let error = evaluateError else {
                            return
                        }
                        
                        // display unlock button if error with biometric
                        UIView.animate(withDuration: 0.2, animations: {
                            self.unlockButton.alpha = 1
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
        self.navigationItem.title = NSLocalizedString("Privacy", comment: "")
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(SettingSwitchCell.self, forCellReuseIdentifier: reuseSwitchCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @objc func useBiometric(sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: Resource.Defaults.useBiometrics)
        } else {
            defaults.set(false, forKey: Resource.Defaults.useBiometrics)
        }
    }
}

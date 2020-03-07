//
//  PrivacyController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/07.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import LocalAuthentication

class PrivacyController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let sections: Array = [NSLocalizedString("Biometrics", comment: "")]
    let biometrics: Array = [NSLocalizedString("UseTouchOrFaceId", comment: "")]
    var tableView: UITableView = UITableView()
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
        unlockButton.backgroundColor = Colors.blue2
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
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
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
                        // display unlock button if error with biometric
                        UIView.animate(withDuration: 0.2, animations: {
                            self.unlockButton.alpha = 1
                        }) {_ in}
                    }
                }
            }
        }
    }
    
    func removeBlurView(window: UIWindow) {
        // remove blur view when app enter background.
        window.viewWithTag(100)?.removeFromSuperview()
        window.viewWithTag(101)?.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = NSLocalizedString("Privacy", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableView()
    }
    
    func configureTableView() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: width, height: height), style: .grouped)
        view.addSubview(tableView)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(SettingSwitchCell.self, forCellReuseIdentifier: reuseSwitchCell)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return biometrics.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseSwitchCell, for: indexPath) as! SettingSwitchCell
                cell.textLabel?.text = "\(biometrics[indexPath.row])"
                
                cell.selectionStyle = .none
                cell.switchButton.addTarget(self, action: #selector(useBiometric(sender:)), for: .valueChanged)
                
                if defaults.bool(forKey: Defaults.useBiometrics) == true {
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
            cell.textLabel?.textColor = Colors.darkColor
            return cell
        }
    }
    
    @objc func useBiometric(sender: UISwitch) {
        if sender.isOn == true {
            print("biometrics enabled")
            defaults.set(true, forKey: Defaults.useBiometrics)
        } else {
            print("biometrics disabled")
            defaults.set(false, forKey: Defaults.useBiometrics)
        }
    }
}

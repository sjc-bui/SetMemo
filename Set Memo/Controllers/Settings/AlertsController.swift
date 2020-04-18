//
//  AlertsController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/05.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class AlertsController: UITableViewController {
    let sections: Array = [""]
    let alertActions: Array = [
        "Vibration".localized,
        "ShowAlertOnDelete".localized
    ]
    
    private let reuseSettingCell = "SettingCell"
    private let reuseSettingSwitchCell = "SettingSwitchCell"
    let defaults = UserDefaults.standard
    let theme = ThemesViewController()
    let themes = Themes()
    let setting = SettingViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Alert".localized
        
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseSettingCell)
        tableView.register(SettingSwitchCell.self, forCellReuseIdentifier: reuseSettingSwitchCell)
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return alertActions.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseSettingCell) as! SettingCell
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseSettingSwitchCell, for: indexPath) as! SettingSwitchCell
                cell.textLabel?.text = "\(alertActions[indexPath.row])"
                cell.selectionStyle = .none
                cell.switchButton.addTarget(self, action: #selector(setupVibrationOnTouch(sender:)), for: .valueChanged)
                
                if defaults.bool(forKey: Resource.Defaults.vibrationOnTouch) == true {
                    cell.switchButton.isOn = true
                } else {
                    cell.switchButton.isOn = false
                }
                setting.setupDynamicCells(cell: cell)
                return cell
                
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseSettingSwitchCell, for: indexPath) as! SettingSwitchCell
                cell.textLabel?.text = "\(alertActions[indexPath.row])"
                cell.selectionStyle = .none
                cell.switchButton.addTarget(self, action: #selector(setupShowAlertOnDelete(sender:)), for: .valueChanged)
                
                if defaults.bool(forKey: Resource.Defaults.showAlertOnDelete) == true {
                    cell.switchButton.isOn = true
                } else {
                    cell.switchButton.isOn = false
                }
                setting.setupDynamicCells(cell: cell)
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseSettingCell, for: indexPath) as! SettingCell
                return cell
            }
        }
        
        return cell
    }
    
    @objc func setupVibrationOnTouch(sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: Resource.Defaults.vibrationOnTouch)
            self.tableView.reloadData()
        } else {
            defaults.set(false, forKey: Resource.Defaults.vibrationOnTouch)
            self.tableView.reloadData()
        }
    }
    
    @objc func setupShowAlertOnDelete(sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: Resource.Defaults.showAlertOnDelete)
            self.tableView.reloadData()
        } else {
            defaults.set(false, forKey: Resource.Defaults.showAlertOnDelete)
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

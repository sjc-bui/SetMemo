//
//  SettingViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import RealmSwift

class SettingViewController: UITableViewController {
    let sections: Array = [
        "General".localized,
        "Advanced".localized,
        "Other".localized]
    
    let general: Array = [
        "Privacy".localized,
        "Alert".localized,
        "FontSize".localized,
        "ChangeAppIcon".localized,
        "PlaceHolderLabel".localized,
        "DisplayUpdateTime".localized,
        "RemindEveryDay".localized,
        "UseDarkMode".localized
    ]
    
    let advanced: Array = ["DeleteLabel".localized]
    let other: Array = ["Version".localized]
    
    //var tableView: UITableView = UITableView()
    let themes = Themes()
    let defaults = UserDefaults.standard
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    private let reuseIdentifier = "Cell"
    private let reuseSettingCell = "SettingCell"
    private let reuseSwitchIdentifier = "SettingSwitchCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Setting".localized
        self.navigationController?.navigationBar.tintColor = Colors.shared.accentColor
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        
        tableView.contentInset = .zero
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(SettingSwitchCell.self, forCellReuseIdentifier: reuseSwitchIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDynamicElement()
        removeExtraHeaderView()
        tableView.reloadData()
    }
    
    func removeExtraHeaderView() {
        var frame = `CGRect`.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return general.count
        } else if section == 1 {
            return advanced.count
        } else if section == 2 {
            return other.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseSwitchIdentifier, for: indexPath) as! SettingSwitchCell
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.selectionStyle = .none
                cell.switchButton.addTarget(self, action: #selector(displayUpdateTime(sender:)), for: .valueChanged)
                
                if defaults.bool(forKey: Resource.Defaults.displayDateTime) == true {
                    cell.switchButton.isOn = true
                } else {
                    cell.switchButton.isOn = false
                }
                
                return cell
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseSwitchIdentifier, for: indexPath) as! SettingSwitchCell
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.selectionStyle = .none
                cell.switchButton.addTarget(self, action: #selector(setupRemindEveryDay(sender:)), for: .valueChanged)
                cell.descriptionText.text = defaults.string(forKey: Resource.Defaults.remindAt) ?? ""
                
                if defaults.bool(forKey: Resource.Defaults.remindEveryDay) == true {
                    cell.switchButton.isOn = true
                } else {
                    cell.switchButton.isOn = false
                }
                
                return cell
            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseSwitchIdentifier, for: indexPath) as! SettingSwitchCell
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.selectionStyle = .none
                cell.switchButton.addTarget(self, action: #selector(setupDarkTheme(sender:)), for: .valueChanged)
                
                if defaults.bool(forKey: Resource.Defaults.useDarkMode) == true {
                    cell.switchButton.isOn = true
                } else {
                    cell.switchButton.isOn = false
                }
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                return cell
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(advanced[indexPath.row])"
                cell.textLabel?.textColor = Colors.shared.accentColor
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                return cell
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                let cell = SettingCell(style: SettingCell.CellStyle.value1, reuseIdentifier: reuseSettingCell)
                cell.textLabel?.text = "\(other[indexPath.row])"
                cell.detailTextLabel?.text = "\(appVersion)"
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            
            cell.backgroundColor = UIColor.systemBackground
            return cell
        }
    }
    
    @objc func setupDarkTheme(sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: Resource.Defaults.useDarkMode)
            viewWillAppear(true)
            themes.setupPureDarkTheme()
        } else {
            defaults.set(false, forKey: Resource.Defaults.useDarkMode)
            viewWillAppear(true)
            themes.setupDefaultTheme()
        }
    }
    
    @objc func setupRemindEveryDay(sender: UISwitch) {
        if sender.isOn == true {
            self.navigationController?.pushViewController(RemindViewController(), animated: true)
        } else {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            defaults.set(false, forKey: Resource.Defaults.remindEveryDay)
            defaults.set("", forKey: Resource.Defaults.remindAt)
            self.tableView.reloadData()
        }
    }
    
    @objc func displayUpdateTime(sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: Resource.Defaults.displayDateTime)
        } else {
            defaults.set(false, forKey: Resource.Defaults.displayDateTime)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
            switch indexPath.row {
            case 0:
                self.navigationController?.pushViewController(PrivacyController(style: .insetGrouped), animated: true)
            case 1:
                self.navigationController?.pushViewController(AlertsController(style: .insetGrouped), animated: true)
            case 2:
                self.navigationController?.pushViewController(FontSizeController(style: .insetGrouped), animated: true)
            case 3:
                self.navigationController?.pushViewController(AppearanceController(style: .insetGrouped), animated: true)
            case 4:
                let alert = UIAlertController(title: "Placeholder".localized, message: "CustomPlaceholder".localized, preferredStyle: .alert)
                
                alert.addTextField { textField in
                    let placeholder = self.defaults.string(forKey: Resource.Defaults.writeMemoPlaceholder)
                    textField.placeholder = placeholder ?? "lalala..."
                    textField.autocorrectionType = .yes
                    textField.autocapitalizationType = .sentences
                }
                
                alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { [weak alert] _ in
                    print(alert?.message ?? "cancel")
                }))
                
                alert.addAction(UIAlertAction(title: "Done".localized, style: .default, handler: { [weak alert] _ in
                    let textField = alert?.textFields![0]
                    let text = textField?.text
                    
                    if text?.isEmpty ?? false {
                    } else {
                        self.defaults.set(text, forKey: Resource.Defaults.writeMemoPlaceholder)
                    }
                }))
                
                present(alert, animated: true, completion: nil)
            default:
                return
            }
        } else if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
            switch indexPath.row {
            case 0:
                let deleteAllAlert = UIAlertController(title: "Sure".localized, message: "DeleteAll".localized, preferredStyle: .alert)
                let delete = UIAlertAction(title: "Delete".localized, style: .destructive, handler: { action in
                    RealmServices.shared.deleteAll()
                })
                let cancel = UIAlertAction(title: "Cancel".localized, style: .default, handler: nil)
                
                deleteAllAlert.addAction(cancel)
                deleteAllAlert.addAction(delete)
                
                present(deleteAllAlert, animated: true, completion: nil)
            default:
                return
            }
        } else if indexPath.section == 2 {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.selectionStyle = .none
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func darkModeIsEnable() -> Bool {
        if defaults.bool(forKey: Resource.Defaults.useDarkMode) == true {
            print("dark")
            return true
        } else {
            print("light")
            return false
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        themes.triggerSystemMode(mode: traitCollection)
        setupDynamicElement()
        tableView.reloadData()
    }
    
    func setupDynamicElement() {
        if darkModeIsEnable() == true {
            tableView.separatorColor = nil
        } else {
            tableView.separatorColor = Colors.whiteColor
        }
    }
}

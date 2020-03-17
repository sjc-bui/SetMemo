//
//  SettingViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import RealmSwift

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let sections: Array = [
        NSLocalizedString("General", comment: ""),
        NSLocalizedString("Advanced", comment: ""),
        NSLocalizedString("Other", comment: "")]
    
    let general: Array = [
        NSLocalizedString("Privacy", comment: ""),
        NSLocalizedString("FontSize", comment: ""),
        NSLocalizedString("ChangeAppIcon", comment: ""),
        NSLocalizedString("Alert", comment: ""),
        NSLocalizedString("PlaceHolderLabel", comment: ""),
        NSLocalizedString("DisplayUpdateTime", comment: ""),
        NSLocalizedString("RemindEveryDay", comment: "")
    ]
    
    let advanced: Array = [NSLocalizedString("DeleteLabel", comment: "")]
    let other: Array = [NSLocalizedString("Version", comment: "")]
    
    var tableView: UITableView!
    let defaults = UserDefaults.standard
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    private let reuseIdentifier = "Cell"
    private let reuseSettingCell = "SettingCell"
    private let reuseSwitchIdentifier = "SettingSwitchCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Setting", comment: "")
        self.navigationController?.navigationBar.tintColor = Colors.shared.accentColor
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
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
        tableView.pin(to: view)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(SettingSwitchCell.self, forCellReuseIdentifier: reuseSwitchIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return general.count
        } else if section == 1 {
            return advanced.count
        } else if section == 2 {
            return other.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
                cell.descriptionText.text = defaults.string(forKey: Resource.Defaults.remindAt)
                
                if defaults.bool(forKey: Resource.Defaults.remindEveryDay) == true {
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
            
            cell.backgroundColor = Colors.whiteColor
            return cell
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
            viewWillAppear(true)
            self.tableView.reloadData()
        } else {
            defaults.set(false, forKey: Resource.Defaults.displayDateTime)
            viewWillAppear(true)
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
            switch indexPath.row {
            case 0:
                self.navigationController?.pushViewController(PrivacyController(), animated: true)
            case 1:
                self.navigationController?.pushViewController(FontSizeController(), animated: true)
            case 2:
                self.navigationController?.pushViewController(AppearanceController(), animated: true)
            case 3:
                self.navigationController?.pushViewController(AlertsController(), animated: true)
            case 4:
                let alert = UIAlertController(title: NSLocalizedString("Placeholder", comment: ""), message: NSLocalizedString("CustomPlaceholder", comment: ""), preferredStyle: .alert)
                
                alert.addTextField { textField in
                    let placeholder = self.defaults.string(forKey: Resource.Defaults.writeNotePlaceholder)
                    textField.placeholder = placeholder ?? "lalala..."
                    textField.autocorrectionType = .yes
                    textField.autocapitalizationType = .sentences
                }
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { [weak alert] _ in
                    print(alert?.message ?? "cancel")
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { [weak alert] _ in
                    let textField = alert?.textFields![0]
                    let text = textField?.text
                    
                    if text?.isEmpty ?? false {
                    } else {
                        self.defaults.set(text, forKey: Resource.Defaults.writeNotePlaceholder)
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
                let deleteAllAlert = UIAlertController(title: NSLocalizedString("Sure", comment: ""), message: NSLocalizedString("DeleteAll", comment: ""), preferredStyle: .alert)
                let delete = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { action in
                    RealmServices.shared.deleteAll()
                })
                let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
                
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

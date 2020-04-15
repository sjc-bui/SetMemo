//
//  SettingViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import CoreData
import WhatsNewKit

class SettingViewController: UITableViewController {
    
    let sections: Array = [
        "General".localized,
        "Advanced".localized,
        "Other".localized]
    
    let general: Array = [
        "Privacy".localized,
        "Alert".localized,
        "AppIcon".localized,
        "DisplayUpdateTime".localized,
        "RemindEveryDay".localized,
        "Font".localized,
        "Themes".localized
    ]
    
    let advancedDelete: Array = [
        "DeleteLabel".localized
    ]
    
    let advanced: Array = [
        "DeleteLabel".localized,
        "RecentlyDeleted".localized
    ]
    
    let other: Array = ["Version".localized]
    
    let defaults = UserDefaults.standard
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    
    private let reuseIdentifier = "Cell"
    private let reuseSettingCell = "SettingCell"
    private let reuseSwitchIdentifier = "SettingSwitchCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Setting".localized
        self.navigationItem.setBackButtonTitle(title: "")
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(SettingSwitchCell.self, forCellReuseIdentifier: reuseSwitchIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
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
            if getRecentlyDeletedCount() == 0 {
                return advancedDelete.count
                
            } else {
                return advanced.count
                
            }
            
        } else if section == 2 {
            return other.count
            
        }
        return 0
    }
    
    func getRecentlyDeletedCount() -> Int {
        var deleteCount: Int = 0
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Memo")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "temporarilyDelete = %d", true)
        
        do {
            deleteCount = try! managedContext!.count(for: fetchRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return deleteCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let recentlyDeleteTotal = getRecentlyDeletedCount()
        
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
                
            case 4:
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
                
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                return cell
                
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 1 && recentlyDeleteTotal != 0 {
            // When recently delete item != 0
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(advanced[indexPath.row])"
                cell.textLabel?.textColor = Colors.shared.defaultTintColor
                return cell
                
            case 1:
                let cell = SettingCell(style: SettingCell.CellStyle.value1, reuseIdentifier: reuseSettingCell)
                cell.textLabel?.text = "\(advanced[indexPath.row])"
                cell.textLabel?.textColor = Colors.shared.defaultTintColor
                
                cell.detailTextLabel?.text = "\(recentlyDeleteTotal)"
                cell.accessoryType = .disclosureIndicator
                
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 1 && recentlyDeleteTotal == 0 {
            // When recently delete item = 0
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(advanced[indexPath.row])"
                cell.textLabel?.textColor = Colors.shared.defaultTintColor
                
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
    
    @objc func setupRemindEveryDay(sender: UISwitch) {
        if sender.isOn == true {
            self.navigationController?.pushViewController(RemindViewController(style: .insetGrouped), animated: true)
            
        } else {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
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
                self.navigationController?.pushViewController(AppearanceController(style: .insetGrouped), animated: true)
                
            case 5:
                self.navigationController?.pushViewController(FontStyleViewController(style: .insetGrouped), animated: true)
                
            case 6:
                self.navigationController?.pushViewController(ThemesViewController(style: .insetGrouped), animated: true)
                
            default:
                return
            }
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
            
            switch indexPath.row {
            case 0:
                self.showAlert(title: "Sure".localized, message: "DeleteAllMessage".localized, alertStyle: .alert, actionTitles: ["Cancel".localized, "DeleteLabel".localized], actionStyles: [.cancel, .destructive], actions: [
                    { _ in
                        print("Cancel delete")
                    },
                    { _ in
                        let appDelegate = UIApplication.shared.delegate as? AppDelegate
                        let managedContext = appDelegate?.persistentContainer.viewContext
                        
                        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Memo")
                        
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                        
                        do {
                            try managedContext?.execute(deleteRequest)
                            try managedContext?.save()
                            
                        } catch let error as NSError {
                            print("Could not fetch. \(error), \(error.userInfo)")
                        }
                        
                        tableView.reloadData()
                    }
                ])
                
            case 1:
                self.navigationController?.pushViewController(RecentlyDeletedController(), animated: true)
                
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
            return true
        } else {
            return false
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        tableView.reloadData()
    }
}

extension SettingViewController {
    
    func presentTutorial(view: UIViewController, tintColor: UIColor) {
        
        let whatsNew = WhatsNew(
            title: Bundle.main.localizedInfoDictionary!["CFBundleDisplayName"] as! String,
            items: [
                WhatsNew.Item (
                    title: "Riêng tư", subtitle: "Sử dụng dấu vân tay hoặc mật khẩu để truy cập vào ứng dụng.", image: UIImage(systemName: "hand.raised")
                ),
                WhatsNew.Item (
                    title: "Ghi chú", subtitle: "Viết mọi thứ bạn muốn, ghi chú công việc, ý tưởng.", image: UIImage(systemName: "pencil")
                ),
                WhatsNew.Item (
                    title: "Thông báo", subtitle: "Bạn có thể đặt thông báo cho từng ghi chú theo thời gian cài đặt.", image: Resource.Images.alarmButton
                ),
                WhatsNew.Item (
                    title: "Chia sẻ", subtitle: "Chia sẻ ghi chú hoặc ý tưởng cho mọi người.", image: Resource.Images.shareButton
                ),
                WhatsNew.Item (
                    title: "Khóa ghi chú", subtitle: "Để bảo vệ nội dung riêng tư, bạn có thể khóa riêng từng ghi chú.", image: Resource.Images.setLockButton
                ),
                WhatsNew.Item (
                    title: "Tùy chỉnh ghi chú", subtitle: "Lựa chọn kiểu phông chữ và kích thước theo ý thích của bạn", image: UIImage(systemName: "textformat.size")
                ),
                WhatsNew.Item (
                    title: "Tùy chọn màu sắc", subtitle: "Chọn màu sắc ưa thích cho nút và chữ", image: UIImage(systemName: "sparkles")
                )
            ]
        )
        
        var configuration = WhatsNewViewController.Configuration()
        configuration.titleView.insets = UIEdgeInsets(top: 40, left: 20, bottom: 15, right: 15)
        configuration.itemsView.layout = .left
        configuration.itemsView.imageSize = .fixed(height: 40)
        configuration.itemsView.contentMode = .center
        configuration.apply(animation: .fade)
        configuration.completionButton.insets.bottom = 20
        configuration.completionButton.title = "Done".localized
        configuration.titleView.titleColor = tintColor
        configuration.detailButton?.titleColor = tintColor
        configuration.completionButton.backgroundColor = tintColor
        
        let whatsNewViewController = WhatsNewViewController(
            whatsNew: whatsNew,
            configuration: configuration
        )
        
        DispatchQueue.main.async {
            view.present(whatsNewViewController, animated: true)
        }
    }
}

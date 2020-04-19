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
        "Restore purchases",
        "DeleteLabel".localized
    ]
    
    let advanced: Array = [
        "Restore purchases",
        "DeleteLabel".localized,
        "RecentlyDeleted".localized
    ]
    
    let other: Array = ["Version".localized]
    
    let themes = Themes()
    let theme = ThemesViewController()
    let defaults = UserDefaults.standard
    let appVersion = Bundle().appVersion
    
    private let reuseIdentifier = "Cell"
    private let reuseSettingCell = "SettingCell"
    private let reuseSwitchIdentifier = "SettingSwitchCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Setting".localized
        self.navigationItem.setBackButtonTitle(title: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(SettingSwitchCell.self, forCellReuseIdentifier: reuseSwitchIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        setupDynamicElements()
    }
    
    func setupDynamicElements() {
        
        if theme.darkModeEnabled() == false {
            themes.setupDefaultTheme()
            setupDefaultPersistentNavigationBar()
            
            view.backgroundColor = InterfaceColors.secondaryBackgroundColor
            
        } else {
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
                cell.selectedBackground()
                setupDynamicCells(cell: cell)
                return cell
                
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                cell.selectedBackground()
                setupDynamicCells(cell: cell)
                return cell
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                cell.selectedBackground()
                setupDynamicCells(cell: cell)
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
                setupDynamicCells(cell: cell)
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
                setupDynamicCells(cell: cell)
                return cell
                
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                cell.selectedBackground()
                setupDynamicCells(cell: cell)
                return cell
                
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                cell.selectedBackground()
                setupDynamicCells(cell: cell)
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
                cell.backgroundColor = UIColor.white
                cell.backgroundColor = InterfaceColors.cellColor
                cell.selectedBackground()
                return cell
                
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(advanced[indexPath.row])"
                cell.textLabel?.textColor = Colors.shared.defaultTintColor
                cell.backgroundColor = UIColor.white
                cell.backgroundColor = InterfaceColors.cellColor
                cell.selectedBackground()
                return cell
                
            case 2:
                let cell = SettingCell(style: SettingCell.CellStyle.value1, reuseIdentifier: reuseSettingCell)
                cell.textLabel?.text = "\(advanced[indexPath.row])"
                cell.textLabel?.textColor = Colors.shared.defaultTintColor
                cell.backgroundColor = UIColor.white
                cell.backgroundColor = InterfaceColors.cellColor
                
                cell.detailTextLabel?.text = "\(recentlyDeleteTotal)"
                cell.accessoryType = .disclosureIndicator
                cell.selectedBackground()
                
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
                cell.textLabel?.text = "\(advancedDelete[indexPath.row])"
                cell.textLabel?.textColor = Colors.shared.defaultTintColor
                cell.backgroundColor = UIColor.white
                cell.backgroundColor = InterfaceColors.cellColor
                cell.selectedBackground()
                return cell
                
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(advancedDelete[indexPath.row])"
                cell.textLabel?.textColor = Colors.shared.defaultTintColor
                cell.backgroundColor = UIColor.white
                cell.backgroundColor = InterfaceColors.cellColor
                cell.selectedBackground()
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
                setupDynamicCells(cell: cell)
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
    
    func setupDynamicCells(cell: UITableViewCell) {
        cell.backgroundColor = UIColor.white
        cell.backgroundColor = InterfaceColors.cellColor
        
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.textColor = InterfaceColors.fontColor
    }
    
    @objc func setupRemindEveryDay(sender: UISwitch) {
        if sender.isOn == true {
            self.push(viewController: RemindViewController(style: .insetGrouped))
            
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
                self.push(viewController: PrivacyController(style: .insetGrouped))
                
            case 1:
                self.push(viewController: AlertsController(style: .insetGrouped))
                
            case 2:
                self.push(viewController: AppearanceController(style: .insetGrouped))
                
            case 5:
                self.push(viewController: FontStyleViewController(style: .insetGrouped))
                
            case 6:
                self.push(viewController: ThemesViewController(style: .insetGrouped))
                
            default:
                return
            }
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
            
            switch indexPath.row {
            case 0:
                print("Restore purchase")
            case 1:
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
                
            case 2:
                let layout = UICollectionViewFlowLayout()
                self.push(viewController: RecentlyDeletedController(collectionViewLayout: layout))
                
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if theme.darkModeEnabled() == true {
            return .lightContent
            
        } else {
            return .darkContent
        }
    }
}

extension SettingViewController {
    
    func presentTutorial(view: UIViewController, tintColor: UIColor) {
        
        let whatsNew = WhatsNew(
            title: Bundle.main.localizedInfoDictionary!["CFBundleDisplayName"] as! String,
            items: [
                WhatsNew.Item (
                    title: "Riêng tư", subtitle: "Set Memo sử dụng bảo mật sinh trắc học để đảm bảo không ai khác ngoài bạn có quyền truy cập vào ứng dụng.", image: UIImage(systemName: "hand.raised")
                ),
                WhatsNew.Item (
                    title: "Ghi chú", subtitle: "Hãy để Set Memo giúp việc viết ghi chú của bạn dễ dàng hơn bao giờ hết, ghi chú sẽ tự động lưu và đồng bộ trên tất cả các thiết bị của bạn.", image: UIImage(systemName: "pencil")
                ),
                WhatsNew.Item (
                    title: "Thông báo", subtitle: "Bạn có thể đặt thông báo cho từng ghi chú theo thời gian, hoặc đặt nhắc nhở ghi chú hàng ngày", image: Resource.Images.alarmButton
                ),
                WhatsNew.Item (
                    title: "Chia sẻ", subtitle: "Chia sẻ ghi chú của bạn cho mọi người", image: Resource.Images.shareButton
                ),
                WhatsNew.Item (
                    title: "Khóa ghi chú", subtitle: "Và để bảo mật nội dung riêng tư, bạn có thể thiết lập khóa riêng từng ghi chú", image: Resource.Images.setLockButton
                ),
                WhatsNew.Item (
                    title: "Tùy chỉnh ghi chú", subtitle: "Lựa chọn thay đổi phông chữ và kích thước chữ theo ý của bạn", image: UIImage(systemName: "textformat.size")
                ),
                WhatsNew.Item (
                    title: "Tùy chọn màu sắc", subtitle: "Với nhiều tùy chọn màu sắc ưa thích cho chủ đề", image: UIImage(systemName: "sparkles")
                )
            ]
        )
        
        var configuration = WhatsNewViewController.Configuration()
        
        if darkModeIsEnable() == true {
            configuration.apply(theme: .darkRed)
            
        } else {
            configuration.apply(theme: .default)
        }
        
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

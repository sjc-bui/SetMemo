//
//  SettingViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class SettingViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    let sections: Array = [
        "General".localized,
        "Advanced".localized,
        "Premium".localized,
        "Helps".localized,
        "Other".localized
    ]
    
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
        "ResetSettings".localized,
        "DeleteLabel".localized
    ]
    
    let advanced: Array = [
        "ResetSettings".localized,
        "DeleteLabel".localized,
        "RecentlyDeleted".localized
    ]
    
    let premiums: Array = [
        "UpgradePremium".localized,
        "RestorePurchase".localized
    ]
    
    let helps: Array = [
        "Feedback".localized,
        "RateApp".localized,
        "ShareWithFriends".localized
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
            return premiums.count
            
        } else if section == 3 {
            return helps.count
            
        } else if section == 4 {
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
                setupDynamicCells(cell: cell, arrow: true)
                return cell
                
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                cell.selectedBackground()
                setupDynamicCells(cell: cell, arrow: true)
                return cell
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                cell.selectedBackground()
                setupDynamicCells(cell: cell, arrow: true)
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
                setupDynamicCells(cell: cell, arrow: false)
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
                setupDynamicCells(cell: cell, arrow: false)
                return cell
                
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                cell.selectedBackground()
                setupDynamicCells(cell: cell, arrow: true)
                return cell
                
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(general[indexPath.row])"
                cell.accessoryType = .disclosureIndicator
                cell.selectedBackground()
                setupDynamicCells(cell: cell, arrow: true)
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 1 && recentlyDeleteTotal != 0 {
            
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
                cell.accessoryView = UIImageView(image: Resource.Images.cellAccessoryIcon)
                cell.selectedBackground()
                
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 1 && recentlyDeleteTotal == 0 {
            
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
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(premiums[indexPath.row])"
                cell.textLabel?.textColor = Colors.shared.defaultTintColor
                cell.backgroundColor = UIColor.white
                cell.backgroundColor = InterfaceColors.cellColor
                cell.selectedBackground()
                cell.accessoryType = .disclosureIndicator
                cell.accessoryView = UIImageView(image: Resource.Images.cellAccessoryIcon)
                return cell
            
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(premiums[indexPath.row])"
                cell.textLabel?.textColor = Colors.shared.defaultTintColor
                cell.backgroundColor = UIColor.white
                cell.backgroundColor = InterfaceColors.cellColor
                cell.selectedBackground()
                cell.accessoryType = .none
                cell.accessoryView = nil
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 3 {
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(helps[indexPath.row])"
                cell.textLabel?.textColor = Colors.shared.defaultTintColor
                cell.backgroundColor = UIColor.white
                cell.backgroundColor = InterfaceColors.cellColor
                cell.selectedBackground()
                cell.accessoryType = .none
                cell.accessoryView = nil
                return cell
            
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(helps[indexPath.row])"
                cell.textLabel?.textColor = Colors.shared.defaultTintColor
                cell.backgroundColor = UIColor.white
                cell.backgroundColor = InterfaceColors.cellColor
                cell.selectedBackground()
                cell.accessoryType = .none
                cell.accessoryView = nil
                return cell
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "\(helps[indexPath.row])"
                cell.textLabel?.textColor = Colors.shared.defaultTintColor
                cell.backgroundColor = UIColor.white
                cell.backgroundColor = InterfaceColors.cellColor
                cell.selectedBackground()
                cell.accessoryType = .none
                cell.accessoryView = nil
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 4 {
            
            switch indexPath.row {
            case 0:
                let cell = SettingCell(style: SettingCell.CellStyle.value1, reuseIdentifier: reuseSettingCell)
                cell.textLabel?.text = "\(other[indexPath.row])"
                cell.detailTextLabel?.text = "\(appVersion)"
                setupDynamicCells(cell: cell, arrow: false)
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
    
    func setupDynamicCells(cell: UITableViewCell, arrow: Bool) {
        cell.backgroundColor = UIColor.white
        cell.backgroundColor = InterfaceColors.cellColor
        
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.textColor = InterfaceColors.fontColor
        
        if arrow == true {
            cell.accessoryView = UIImageView(image: Resource.Images.cellAccessoryIcon)
        }
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
                
                self.showAlert(title: "Sure".localized, message: "ResetActionMessage".localized, alertStyle: .alert, actionTitles: ["Cancel".localized, "Reset".localized], actionStyles: [.cancel, .default], actions: [
                    { _ in
                        print("cancel")
                    },
                    { _ in
                        print("Resetting...")
                        self.defaults.set(0, forKey: Resource.Defaults.theme)
                        self.defaults.set(0, forKey: Resource.Defaults.defaultTintColor)
                        self.defaults.set(true, forKey: Resource.Defaults.vibrationOnTouch)
                        self.defaults.set(false, forKey: Resource.Defaults.showAlertOnDelete)
                        self.defaults.set(true, forKey: Resource.Defaults.displayDateTime)
                        self.defaults.set(false, forKey: Resource.Defaults.useBiometrics)
                        self.defaults.set("dateCreated", forKey: Resource.Defaults.sortBy)
                        self.defaults.set(false, forKey: Resource.Defaults.useDarkMode)
                        self.defaults.set(true, forKey: Resource.Defaults.firstTimeDeleted)
                        self.defaults.set("HelveticaNeue-Medium", forKey: Resource.Defaults.defaultFontStyle)
                        self.defaults.set(18, forKey: Resource.Defaults.defaultTextViewFontSize)
                        self.defaults.set("What happening today?", forKey: Resource.Defaults.remindEverydayContent)
                        
                        ShowToast.toast(message: "ResetSuccess".localized, duration: 1.0)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.pop()
                        }
                    }
                ])
                
            case 1:
                
                self.showAlert(title: "Sure".localized, message: "DeleteAllMessage".localized, alertStyle: .alert, actionTitles: ["Cancel".localized, "Delete".localized], actionStyles: [.cancel, .destructive], actions: [
                    { _ in
                        print("cancel")
                    },
                    { _ in
                        print("delete all")
                        
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
            cell?.isSelected = false
            
            switch indexPath.row {
            case 0:
                print("buy premium")
                self.push(viewController: PremiumViewController())
                
            case 1:
                
                print("restore purchase")
                self.showAlert(title: "Error!", message: "You didn't buy premium, please try again!", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [
                    { _ in
                        print("---")
                    }
                ])
                
            default:
                return
            }
            
        } else if indexPath.section == 3 {
            
            let cell = tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
            
            switch indexPath.row {
            case 0:
                
                self.showAlert(title: nil, message: nil, alertStyle: .actionSheet, actionTitles: ["SendFeedback".localized, "ReportBug".localized, "RequestFeature".localized, "Cancel".localized], actionStyles: [.default, .default, .default, .cancel], actions: [
                    { _ in
                        print("feedback")
                        self.sendMail(subject: "[FEEDBACK] \("SendFeedback".localized)", body: "TellUsDetail".localized)
                    },
                    { _ in
                        print("report bug")
                        self.sendMail(subject: "[BUG] \("ReportBug".localized)", body: "TellUsDetail".localized)
                    },
                    { _ in
                        print("feature request")
                        self.sendMail(subject: "[FEATURE] \("RequestFeature".localized)", body: "TellUsDetail".localized)
                    },
                    { _ in
                        print("cancel")
                    },
                ])
                
            case 1:
                
                print("rate app")
                //let urlStr = "https://itunes.apple.com/app/id\(Config.appId)" // (Option 1) Open App Page
                let urlStr = "https://itunes.apple.com/app/id\(Config.appId)?action=write-review" // (Option 2) Open App Review Page
                guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else {
                    return
                }
                
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
            case 2:
                
                print("share with friends")
                let textToShare = "Set Memo provides a new experience of managing all your memo. Try Set Memo."
                let objectToShare = [textToShare] as [Any]
                
                let activityViewController = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop,
                                                                 UIActivity.ActivityType.addToReadingList]
                
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                if defaults.bool(forKey: Resource.Defaults.useDarkMode) == true {
                    activityViewController.overrideUserInterfaceStyle = .dark
                    
                } else {
                    activityViewController.overrideUserInterfaceStyle = .light
                }
                
                self.present(activityViewController, animated: true, completion: nil)
                
            default:
                return
            }
            
        } else if indexPath.section == 4 {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.selectionStyle = .none
        }
    }
    
    func sendMail(subject: String, body: String) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([Config.supportEmail])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: true)
            
            present(mail, animated: true, completion: nil)
            
        } else {
            
            self.showAlert(title: "LoginToMailApp".localized, message: nil, alertStyle: .alert, actionTitles: ["Cancel".localized, "OpenMail".localized], actionStyles: [.default, .default], actions: [
                { _ in
                    print("error send mail")
                },
                { _ in
                    print("open mail")
                    let mailURL = URL(string: "message://")
                    if UIApplication.shared.canOpenURL(mailURL!) {
                        UIApplication.shared.open(mailURL!, options: [:], completionHandler: nil)
                    }
                }
            ])
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("cancelled")
            
        case MFMailComposeResult.saved.rawValue:
            print("saved")
            
        case MFMailComposeResult.sent.rawValue:
            print("sent")
            
        default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
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

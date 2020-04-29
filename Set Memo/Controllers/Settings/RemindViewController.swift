//
//  RemindViewController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/17.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class RemindViewController: UITableViewController {
    
    let sections = ["Remind text", "Remind at", ""]
    let reuseDatePickerCellId = "datePickerCellId"
    let reuseTextFileId = "textFieldId"
    let reuseButtonId = "buttonId"
    let reuseCellId = "cellId"
    let defaults = UserDefaults.standard
    let theme = ThemesViewController()
    let themes = Themes()
    let setting = SettingViewController()
    
    @objc func setRemind(sender: UIButton) {
        let index1: IndexPath = IndexPath(row: 0, section: 0)
        let textFieldContent = tableView.cellForRow(at: index1) as! TextFieldCell
        let remindContent = textFieldContent.textField.text!
        
        let index2: IndexPath = IndexPath(row: 0, section: 1)
        let pickerValue = tableView.cellForRow(at: index2) as! DatePickerCell
        
        let center = UNUserNotificationCenter.current()
        let id = "dailyReminder"
        
        let content = UNMutableNotificationContent()
        content.body = remindContent
        content.sound = UNNotificationSound.default
        content.threadIdentifier = "notifi"
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        
        let dateComponent = pickerValue.datePicker.calendar?.dateComponents([.hour, .minute], from: pickerValue.datePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent!, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateFromPicker = dateFormatter.string(from: pickerValue.datePicker.date)
        defaults.set(dateFromPicker, forKey: Resource.Defaults.remindAt)
        
        center.add(request) { (error) in
            if error != nil {
                print(error!)
            }
        }
        
        defaults.set(remindContent, forKey: Resource.Defaults.remindEverydayContent)
        defaults.set(true, forKey: Resource.Defaults.remindEveryDay)
        self.pop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "RemindEveryDay".localized
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: reuseDatePickerCellId)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: reuseTextFileId)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: reuseButtonId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseCellId)
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
            
        } else if section == 1 {
            return 1
            
        } else if section == 2 {
            return 1
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseTextFileId, for: indexPath) as! TextFieldCell
                cell.textField.text = defaults.string(forKey: Resource.Defaults.remindEverydayContent)
                cell.textField.inputAccessoryView = setTextFieldAccessory()
                cell.textField.textColor = InterfaceColors.fontColor
                
                setting.setupDynamicCells(cell: cell, arrow: false)
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellId, for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 1 {
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseDatePickerCellId, for: indexPath) as! DatePickerCell
                cell.datePicker.backgroundColor = UIColor.white
                cell.datePicker.backgroundColor = InterfaceColors.cellColor
                
                cell.datePicker.setValue(UIColor.black, forKeyPath: "textColor")
                cell.datePicker.setValue(InterfaceColors.fontColor, forKeyPath: "textColor")
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellId, for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 2 {
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseButtonId, for: indexPath) as! ButtonCell
                cell.btn.setTitle("Done".localized, for: .normal)
                cell.btn.titleLabel?.font = UIFont.systemFont(ofSize: Dimension.shared.medium, weight: .semibold)
                cell.btn.addTarget(self, action: #selector(setRemind(sender:)), for: .touchUpInside)
                cell.backgroundColor = Colors.shared.defaultTintColor
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellId, for: indexPath)
                return cell
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellId, for: indexPath)
            return cell
        }
    }
    
    func setTextFieldAccessory() -> UIView {
        
        let items = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let space = UIBarButtonItem.flexibleSpace
        let done = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(hideKeyboard))
        
        items.setItems([space, done], animated: true)
        items.barStyle = .default
        items.isUserInteractionEnabled = true
        items.sizeToFit()
        
        return items
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let cell = tableView.cellForRow(at: indexPath)
                cell?.isEditing = true
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 44
            
        } else if indexPath.section == 1 {
            return 180
            
        } else if indexPath.section == 2 {
            return 48
        }
        
        return 0
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if theme.darkModeEnabled() == true {
            return .lightContent
            
        } else {
            return .darkContent
        }
    }
}

//
//  RemindViewController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/17.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class RemindViewController: UITableViewController {
    
    let sections = ["Remind text", "Remind at"]
    let reuseDatePickerCellId = "datePickerCellId"
    let reuseTextFileId = "textFieldId"
    let reuseCellId = "cellId"
    let defaults = UserDefaults.standard
    
    var button = UIButton(type: .custom)
    func setReminderButton(){
        var btnWidth: Int?
        let btnHeight = 44
        let screenSize = self.view.frame.size
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            btnWidth = Int(self.view.frame.size.width - 32)
        } else {
            btnWidth = 250
        }
        
        button.frame = CGRect(x: (Int(screenSize.width) - btnWidth!) / 2, y: Int(screenSize.height) - 68, width: btnWidth!, height: btnHeight)
        button.setTitle("Done".localized, for: .normal)
        button.addTarget(self, action: #selector(setRemind(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: Dimension.shared.medium, weight: .semibold)
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor.colorFromString(from: UserDefaults.standard.integer(forKey: Resource.Defaults.defaultTintColor))
        
        view.addSubview(button)
    }
    
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
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "RemindEveryDay".localized
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: reuseDatePickerCellId)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: reuseTextFileId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseCellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setReminderButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.button.removeFromSuperview()
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
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellId, for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 1 {
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseDatePickerCellId, for: indexPath) as! DatePickerCell
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
            return UIScreen.height / 3
        }
        
        return 0
    }
}

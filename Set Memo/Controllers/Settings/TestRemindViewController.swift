//
//  TestRemindViewController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/12.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class TestRemindViewController: UITableViewController {
    
    let sections = ["Remind text", "Remind at"]
    let reuseDatePickerCellId = "datePickerCellId"
    let defaults = UserDefaults.standard
    
    var button = UIButton(type: .custom)
    func floatingButton(){
        let btnWidth = 250
        let btnHeight = 44
        button.frame = CGRect(x: (Int(self.view.frame.size.width) - btnWidth) / 2, y: Int(view.frame.size.height) - 70, width: btnWidth, height: btnHeight)
        button.setTitle("Done".localized, for: .normal)
        button.addTarget(self, action: #selector(setRemind(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: Dimension.shared.medium, weight: .semibold)
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor.colorFromString(from: UserDefaults.standard.integer(forKey: Resource.Defaults.defaultTintColor))
        
        view.addSubview(button)
    }
    
    @objc func setRemind(sender: UIButton) {
        let indexPath: IndexPath = IndexPath(row: 0, section: 0)
        let textFieldContent = tableView.cellForRow(at: indexPath) as! TextFieldCell
        print(textFieldContent.textField.text!)
        
        let index2: IndexPath = IndexPath(row: 0, section: 1)
        let pickerValue = tableView.cellForRow(at: index2) as! DatePickerCell
        print(pickerValue.datePicker.date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "RemindEveryDay".localized
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: reuseDatePickerCellId)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: "textFieldId")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        floatingButton()
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldId", for: indexPath) as! TextFieldCell
                cell.textField.text = defaults.string(forKey: Resource.Defaults.remindEverydayContent)
                cell.textField.inputAccessoryView = setTextFieldAccessory()
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 1 {
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseDatePickerCellId, for: indexPath) as! DatePickerCell
                
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
                return cell
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
            return cell
        }
    }
    
    func setTextFieldAccessory() -> UIView {
        let items = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 30))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
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

//
//  ThemesViewController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/04.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class ThemesViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let themes = Themes()
    let reuseIdentifier = "themesCell"
    let reusePickerCellId = "pickerCell"
    let reuseSwitchIdentifier = "SettingSwitchCell"
    let defaults = UserDefaults.standard
    var lastIndex: NSIndexPath = NSIndexPath(row: 0, section: 0)
    
    let sections = ["Themes".localized, "TintColor".localized, "ColorThemeMemo".localized]
    var themesOptionsData: [String] = [
        "LightTheme".localized,
        "DarkTheme".localized
    ]
    var tintColorData: [String] = [
        "Yellow".localized,
        "Red".localized,
        "Orange".localized,
        "Pink".localized,
        "Blue".localized,
        "Green".localized,
        "Indigo".localized
    ]
    var cellColorData: [String] = [
        "Vibrant",
        "High",
        "Soft",
        "Light"
    ]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if pickerView.tag == 1 {
            return 1
            
        } else if pickerView.tag == 2 {
            return 1
            
        } else if pickerView.tag == 3 {
            return 1
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 1 {
            return themesOptionsData.count
            
        } else if pickerView.tag == 2 {
            return tintColorData.count
            
        } else if pickerView.tag == 3 {
            return cellColorData.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1 {
            return themesOptionsData[row]
            
        } else if pickerView.tag == 2 {
            return tintColorData[row]
            
        } else if pickerView.tag == 3 {
            return cellColorData[row]
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 1 {
            if row == 0 {
                themes.setupDefaultTheme()
                setupDefaultPersistentNavigationBar()
                
                view.backgroundColor = InterfaceColors.secondaryBackgroundColor
                defaults.set(false, forKey: Resource.Defaults.useDarkMode)
                defaults.set(true, forKey: Resource.Defaults.useCellColor)
                
            } else if row == 1 {
                themes.setupPureDarkTheme()
                setupDarkPersistentNavigationBar()
                
                view.backgroundColor = InterfaceColors.secondaryBackgroundColor
                defaults.set(true, forKey: Resource.Defaults.useDarkMode)
            }
            
            defaults.set(row, forKey: Resource.Defaults.theme)
            
        } else if pickerView.tag == 2 {
            
            defaults.set(row, forKey: Resource.Defaults.defaultTintColor)
            navigationController?.navigationBar.tintColor = Colors.shared.defaultTintColor
            
        } else if pickerView.tag == 3 {
            
            defaults.set(row, forKey: Resource.Defaults.defaultCellColor)
        }
        
        let reloadSectionIndex: IndexSet = [0, 1, 2]
        self.tableView.reloadSections(reloadSectionIndex, with: .fade)
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
    
    func darkModeEnabled() -> Bool {
        
        if defaults.bool(forKey: Resource.Defaults.useDarkMode) == true {
            return true
            
        } else {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Themes".localized
        
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(PickerViewCell.self, forCellReuseIdentifier: reusePickerCellId)
        tableView.register(SettingSwitchCell.self, forCellReuseIdentifier: reuseSwitchIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDynamicElements()
    }
    
    func setupDynamicElements() {
        if darkModeEnabled() == false {
            themes.setupDefaultTheme()
            setupDefaultPersistentNavigationBar()
            
            view.backgroundColor = InterfaceColors.secondaryBackgroundColor
            
        } else if darkModeEnabled() == true {
            themes.setupPureDarkTheme()
            setupDarkPersistentNavigationBar()
            
            view.backgroundColor = InterfaceColors.secondaryBackgroundColor
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 2
            
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
                let cell = tableView.dequeueReusableCell(withIdentifier: reusePickerCellId, for: indexPath) as! PickerViewCell
                cell.pickerView.delegate = self
                cell.pickerView.dataSource = self
                cell.pickerView.tag = 1
                dynamicCell(cell: cell, picker: cell.pickerView)

                let index = defaults.integer(forKey: Resource.Defaults.theme)
                cell.pickerView.selectRow(index, inComponent: 0, animated: false)
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseSwitchIdentifier, for: indexPath) as! SettingSwitchCell
                cell.textLabel?.text = "MemoColor".localized
                cell.selectionStyle = .none
                cell.switchButton.addTarget(self, action: #selector(setupCellColor(sender:)), for: .valueChanged)
                
                if defaults.bool(forKey: Resource.Defaults.useCellColor) == true {
                    cell.switchButton.isOn = true
                } else {
                    cell.switchButton.isOn = false
                }
                setupDynamicCells(cell: cell, arrow: false)
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: reusePickerCellId, for: indexPath) as! PickerViewCell
            cell.pickerView.delegate = self
            cell.pickerView.dataSource = self
            cell.pickerView.tag = 2
            dynamicCell(cell: cell, picker: cell.pickerView)
            
            let index = defaults.integer(forKey: Resource.Defaults.defaultTintColor)
            cell.pickerView.selectRow(index, inComponent: 0, animated: false)
            
            return cell
            
        } else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: reusePickerCellId, for: indexPath) as! PickerViewCell
            cell.pickerView.delegate = self
            cell.pickerView.dataSource = self
            cell.pickerView.tag = 3
            dynamicCell(cell: cell, picker: cell.pickerView)
            
            let index = defaults.integer(forKey: Resource.Defaults.defaultCellColor)
            cell.pickerView.selectRow(index, inComponent: 0, animated: false)
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
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
    
    @objc func setupCellColor(sender: UISwitch) {
        
        if sender.isOn == true {
            defaults.set(true, forKey: Resource.Defaults.useCellColor)
            
        } else {
            if defaults.bool(forKey: Resource.Defaults.useDarkMode) == false {
                sender.isOn = true
                return
            }
            defaults.set(false, forKey: Resource.Defaults.useCellColor)
        }
    }
    
    func dynamicCell(cell: UITableViewCell, picker: UIPickerView) {
        cell.backgroundColor = UIColor.white
        cell.backgroundColor = InterfaceColors.cellColor
        
        picker.setValue(UIColor.black, forKeyPath: "textColor")
        picker.setValue(InterfaceColors.fontColor, forKeyPath: "textColor")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                return 100
            default:
                return 50
            }
            
        } else if indexPath.section == 1 {
            return 180
            
        } else if indexPath.section == 2 {
            return 100
        }
        
        return 0
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if darkModeEnabled() {
            return .lightContent
            
        } else {
            return .darkContent
        }
    }
}

//
//  FontStyleViewController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/09.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class FontStyleViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var fontStylePickerData: [String] = []
    var fontSizePickerData: [Int] = []
    let defaults = UserDefaults.standard
    let theme = ThemesViewController()
    let themes = Themes()
    let setting = SettingViewController()
    
    func setupFontStyle() {
        for family in UIFont.familyNames {
            for fontName in UIFont.fontNames(forFamilyName: family) {
                fontStylePickerData.append("\(fontName)")
            }
        }
    }
    
    func setupFontSize() {
        for i in 12...48 {
            fontSizePickerData.append(i)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return fontSizePickerData.count
            
        } else if pickerView.tag == 2 {
            return fontStylePickerData.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return "\(fontSizePickerData[row])"
            
        } else if pickerView.tag == 2 {
            return fontStylePickerData[row]
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            defaults.set(fontSizePickerData[row], forKey: Resource.Defaults.defaultTextViewFontSize)
            
        } else if pickerView.tag == 2 {
            defaults.set(fontStylePickerData[row], forKey: Resource.Defaults.defaultFontStyle)
        }
        
        let reloadSectionIndex: IndexSet = [0]
        self.tableView.reloadSections(reloadSectionIndex, with: .fade)
    }
    
    let sections = ["Example".localized, "FontSize".localized, "FontStyle".localized]
    fileprivate let reuseIdentifier = "pickerId"
    fileprivate let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Font".localized
        setupFontStyle()
        setupFontSize()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        self.tableView.register(PickerViewCell.self, forCellReuseIdentifier: reuseIdentifier)
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
                let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
                cell.selectionStyle = .none
                
                let customFontDefault = CGFloat(defaults.integer(forKey: Resource.Defaults.defaultTextViewFontSize))
                cell.textLabel?.font = UIFont(name: defaults.string(forKey: Resource.Defaults.defaultFontStyle)!, size: customFontDefault)
                
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = "The quick brown fox jumps over the lazy dog"
                setting.setupDynamicCells(cell: cell)
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 1 {
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PickerViewCell
                cell.pickerView.delegate = self
                cell.pickerView.dataSource = self
                cell.pickerView.tag = 1
                theme.dynamicCell(cell: cell, picker: cell.pickerView)
                
                let defaultSize = defaults.integer(forKey: Resource.Defaults.defaultTextViewFontSize)
                if let index = fontSizePickerData.firstIndex(of: defaultSize) {
                    cell.pickerView.selectRow(index, inComponent: 0, animated: false)
                }
                
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
                return cell
            }
            
        } else if indexPath.section == 2 {
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PickerViewCell
                cell.pickerView.delegate = self
                cell.pickerView.dataSource = self
                cell.pickerView.tag = 2
                theme.dynamicCell(cell: cell, picker: cell.pickerView)
                
                let defaultFont = defaults.string(forKey: Resource.Defaults.defaultFontStyle)!
                if let index = fontStylePickerData.firstIndex(of: defaultFont) {
                    cell.pickerView.selectRow(index, inComponent: 0, animated: false)
                }
                
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
                return cell
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return UITableView.automaticDimension
            
        } else if indexPath.section == 1 {
            let fontSizePickerHeight = UIScreen.height / 4
            return fontSizePickerHeight
            
        } else if indexPath.section == 2 {
            let fontStylePickerHeight = UIScreen.height / 3
            return fontStylePickerHeight
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

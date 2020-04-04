//
//  ThemesViewController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/04.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class ThemesViewController: UITableViewController {
    let sections = [""]
    let themeOptions = [
        "AutoChange".localized,
        "LightTheme".localized,
        "DarkTheme".localized
    ]
    
    let reuseIdentifier = "themesCell"
    let defaults = UserDefaults.standard
    var lastIndex: NSIndexPath = NSIndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Themes".localized
        
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return themeOptions.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingCell
        cell.textLabel?.text = "\(themeOptions[indexPath.row])"
        cell.tintColor = Colors.shared.accentColor
        cell.selectionStyle = .none
        
        switch indexPath.row {
        case 0:
            if isSelectThemeFromDefault(key: "default", indexPath: indexPath) == true {
                cell.accessoryType = .checkmark
            }
        case 1:
            if isSelectThemeFromDefault(key: "light", indexPath: indexPath) == true {
                cell.accessoryType = .checkmark
            }
        case 2:
            if isSelectThemeFromDefault(key: "dark", indexPath: indexPath) == true {
                cell.accessoryType = .checkmark
            }
        default:
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newRow = indexPath.row
        let oldRow = lastIndex.row
        
        if newRow != oldRow {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            tableView.cellForRow(at: lastIndex as IndexPath)?.accessoryType = .none
            
            lastIndex = indexPath as NSIndexPath
        }
        
        switch indexPath.row {
        case 0:
            defaults.set("default", forKey: Resource.Defaults.theme)
            tableView.reloadData()
        case 1:
            defaults.set("light", forKey: Resource.Defaults.theme)
            tableView.reloadData()
        case 2:
            defaults.set("dark", forKey: Resource.Defaults.theme)
            tableView.reloadData()
        default:
            print("not implement")
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func isSelectThemeFromDefault(key: String, indexPath: IndexPath) -> Bool {
        let themeStyle = defaults.string(forKey: Resource.Defaults.theme)
        if themeStyle == key {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
            return true
            
        } else {
            return false
        }
    }
}

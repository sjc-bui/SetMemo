//
//  AppearanceController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/05.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class AppearanceController: UITableViewController {
    let iconTypes: Array = ["Type".localized]
    let mode: Array = ["Light".localized, "Dark".localized]
    
    private let reuseIdentifier = "appIconCell"
    
    let defaults = UserDefaults.standard
    var lastIndexPath: NSIndexPath = NSIndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "AppIcon".localized
        
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return iconTypes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return mode.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return iconTypes[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingCell
        
        cell.textLabel?.text = "\(mode[indexPath.row])"
        cell.tintColor = UIColor.colorFromString(from: defaults.integer(forKey: Resource.Defaults.defaultTintColor))
        cell.selectionStyle = .none
        
        switch indexPath.row {
        case 0:
            if isSelectIconFromDefault(key: "light", indexPath: indexPath) == true {
                cell.accessoryType = .checkmark
            }
        case 1:
            if isSelectIconFromDefault(key: "dark", indexPath: indexPath) == true {
                cell.accessoryType = .checkmark
            }
        default:
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newRow = indexPath.row
        let oldRow = lastIndexPath.row
        
        if oldRow != newRow {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            tableView.cellForRow(at: lastIndexPath as IndexPath)?.accessoryType = .none
            
            lastIndexPath = indexPath as NSIndexPath
        }
        
        switch indexPath.row {
        case 0:
            defaults.set("light", forKey: Resource.Defaults.iconType)
            changeAppIcon(name: defaults.string(forKey: Resource.Defaults.iconType))
            tableView.reloadData()
        case 1:
            defaults.set("dark", forKey: Resource.Defaults.iconType)
            changeAppIcon(name: defaults.string(forKey: Resource.Defaults.iconType))
            tableView.reloadData()
        default:
            print("not implement")
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func isSelectIconFromDefault(key: String, indexPath: IndexPath) -> Bool {
        // set checkmark for selected icon type
        let iconString = defaults.string(forKey: Resource.Defaults.iconType)
        if iconString == key {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    private func changeAppIcon(name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            print("not support")
            return
        }
        
        // Set icon
        UIApplication.shared.setAlternateIconName(name) { (err) in
            if err != nil {
                print(err!)
            }
        }
    }
}

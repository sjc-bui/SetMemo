//
//  AppearanceController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/05.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class AppearanceController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView = UITableView()
    let iconTypes: Array = [NSLocalizedString("Type", comment: "")]
    let mode: Array = [NSLocalizedString("Light", comment: ""), NSLocalizedString("Dark", comment: "")]
    
    private let reuseIdentifier = "SettingCell"
    
    let defaults = UserDefaults.standard
    var lastIndexPath: NSIndexPath = NSIndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = NSLocalizedString("ChangeAppIcon", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableView()
    }
    
    func configureTableView() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: width, height: height), style: .grouped)
        view.addSubview(tableView)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return iconTypes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return mode.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return iconTypes[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingCell
        
        cell.textLabel?.text = "\(mode[indexPath.row])"
        cell.tintColor = Colors.shared.accentColor
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    private func changeAppIcon(name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
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

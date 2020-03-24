//
//  FontSizeController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/09.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class FontSizeController: UITableViewController {
    let sections = [NSLocalizedString("Size", comment: "")]
    let fontSizeOptions = [
        NSLocalizedString("Small", comment: ""),
        NSLocalizedString("Medium", comment: ""),
        NSLocalizedString("Large", comment: ""),
        NSLocalizedString("Maximum", comment: "")
    ]
    
    let defaults = UserDefaults.standard
    var lastIndexPath: NSIndexPath = NSIndexPath(row: 0, section: 0)
    
    private let reuseIdentifier = "cellId"
    private let small: Float = 14
    private let medium: Float = 18
    private let large: Float = 26
    private let maximum: Float = 32
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("FontSize", comment: "")
        
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
            return fontSizeOptions.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingCell
        
        cell.textLabel?.text = "\(fontSizeOptions[indexPath.row])"
        cell.tintColor = Colors.shared.accentColor
        cell.selectionStyle = .none
        
        switch indexPath.row {
        case 0:
            if selectedFontFromDefault(key: small, indexPath: indexPath) == true {
                cell.accessoryType = .checkmark
            }
        case 1:
            if selectedFontFromDefault(key: medium, indexPath: indexPath) == true {
                cell.accessoryType = .checkmark
            }
        case 2:
            if selectedFontFromDefault(key: large, indexPath: indexPath) == true {
                cell.accessoryType = .checkmark
            }
        case 3:
            if selectedFontFromDefault(key: maximum, indexPath: indexPath) == true {
                cell.accessoryType = .checkmark
            }
        default:
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func selectedFontFromDefault(key: Float, indexPath: IndexPath) -> Bool {
        // set checkmark for selected font size
        let size = defaults.float(forKey: Resource.Defaults.fontSize)
        if size == key {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
            return true
        } else {
            return false
        }
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
            defaults.set(small, forKey: Resource.Defaults.fontSize)
            tableView.reloadData()
        case 1:
            defaults.set(medium, forKey: Resource.Defaults.fontSize)
            tableView.reloadData()
        case 2:
            defaults.set(large, forKey: Resource.Defaults.fontSize)
            tableView.reloadData()
        case 3:
            defaults.set(maximum, forKey: Resource.Defaults.fontSize)
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
}

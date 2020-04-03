//
//  FontSizeController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/09.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class FontSizeController: UITableViewController {
    let sections = ["Size".localized]
    let fontSizeOptions = [
        "Small".localized,
        "Medium".localized,
        "Large".localized,
        "Maximum".localized
    ]
    
    let defaults = UserDefaults.standard
    var lastIndexPath: NSIndexPath = NSIndexPath(row: 0, section: 0)
    
    private let reuseIdentifier = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "FontSize".localized
        
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
            if selectedFontFromDefault(key: Dimension.shared.fontSmallSize, indexPath: indexPath) == true {
                cell.accessoryType = .checkmark
            }
        case 1:
            if selectedFontFromDefault(key: Dimension.shared.fontMediumSize, indexPath: indexPath) == true {
                cell.accessoryType = .checkmark
            }
        case 2:
            if selectedFontFromDefault(key: Dimension.shared.fontLargeSize, indexPath: indexPath) == true {
                cell.accessoryType = .checkmark
            }
        case 3:
            if selectedFontFromDefault(key: Dimension.shared.fontMaxSize, indexPath: indexPath) == true {
                cell.accessoryType = .checkmark
            }
        default:
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func selectedFontFromDefault(key: CGFloat, indexPath: IndexPath) -> Bool {
        // set checkmark for selected font size
        let size = defaults.float(forKey: Resource.Defaults.fontSize)
        if size == Float(key) {
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
            defaults.set(Dimension.shared.fontSmallSize, forKey: Resource.Defaults.fontSize)
            tableView.reloadData()
        case 1:
            defaults.set(Dimension.shared.fontMediumSize, forKey: Resource.Defaults.fontSize)
            tableView.reloadData()
        case 2:
            defaults.set(Dimension.shared.fontLargeSize, forKey: Resource.Defaults.fontSize)
            tableView.reloadData()
        case 3:
            defaults.set(Dimension.shared.fontMaxSize, forKey: Resource.Defaults.fontSize)
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

//
//  FontSizeController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/09.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class FontSizeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let sections = [NSLocalizedString("Size", comment: "")]
    let fontSizeOptions = [
        NSLocalizedString("Small", comment: ""),
        NSLocalizedString("Medium", comment: ""),
        NSLocalizedString("Large", comment: ""),
        NSLocalizedString("Maximum", comment: "")
    ]
    var tableView: UITableView = UITableView()
    
    let defaults = UserDefaults.standard
    var lastIndexPath: NSIndexPath = NSIndexPath(row: 0, section: 0)
    
    private let reuseIdentifier = "cellId"
    private let small: Float = 14
    private let medium: Float = 17
    private let large: Float = 21
    private let maximum: Float = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
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
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return fontSizeOptions.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingCell
        
        cell.textLabel?.text = "\(fontSizeOptions[indexPath.row])"
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
        let size = defaults.float(forKey: Defaults.fontSize)
        if size == key {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
            return true
        } else {
            return false
        }
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
            print("small")
            defaults.set(small, forKey: Defaults.fontSize)
            tableView.reloadData()
        case 1:
            print("medium")
            defaults.set(medium, forKey: Defaults.fontSize)
            tableView.reloadData()
        case 2:
            print("large")
            defaults.set(large, forKey: Defaults.fontSize)
            tableView.reloadData()
        case 3:
            print("maximum")
            defaults.set(maximum, forKey: Defaults.fontSize)
            tableView.reloadData()
        default:
            print("not implement")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
}

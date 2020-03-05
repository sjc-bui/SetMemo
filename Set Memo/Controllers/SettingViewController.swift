//
//  SettingViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let sections: Array = [NSLocalizedString("General", comment: ""), NSLocalizedString("Advanced", comment: "")]
    let general: Array = ["About", "Appearance", "Alerts"]
    let advanced: Array = ["Delete All Data"]
    
    var tableView: UITableView!
    private let reuseIdentifier = "SettingCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Setting", comment: "")
        configureTableView()
        removeExtraHeaderView()
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func configureTableView() {
        tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return general.count
        } else if section == 1 {
            return advanced.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingCell
        
        if indexPath.section == 0 {
            cell.accessoryType = .disclosureIndicator
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = general[indexPath.row]
                return cell
            case 1:
                cell.textLabel?.text = general[indexPath.row]
                return cell
            case 2:
                cell.textLabel?.text = general[indexPath.row]
                return cell
            default:
                return cell
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = advanced[indexPath.row]
                cell.textLabel?.textColor = UIColor.red
                return cell
            default:
                return cell
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            print("section 1")
        } else if indexPath.section == 1 {
            print("section 2")
        }
    }
    
    func removeExtraHeaderView() {
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
    }
}

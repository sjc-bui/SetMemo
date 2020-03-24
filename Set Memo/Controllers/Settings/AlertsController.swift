//
//  AlertsController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/05.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class AlertsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView = UITableView()
    let sections: Array = [
        NSLocalizedString("TouchAction", comment: ""),
        ""
    ]
    let touchAction: Array = [NSLocalizedString("Vibration", comment: "")]
    let badgeIcon: Array = [NSLocalizedString("BadgeIcon", comment: "")]
    
    private let reuseSettingCell = "SettingCell"
    private let reuseSettingSwitchCell = "SettingSwitchCell"
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = NSLocalizedString("Alert", comment: "")
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
        
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseSettingCell)
        tableView.register(SettingSwitchCell.self, forCellReuseIdentifier: reuseSettingSwitchCell)
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
            return touchAction.count
        case 1:
            return badgeIcon.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseSettingCell) as! SettingCell
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseSettingSwitchCell, for: indexPath) as! SettingSwitchCell
                cell.textLabel?.text = "\(touchAction[indexPath.row])"
                cell.selectionStyle = .none
                cell.switchButton.addTarget(self, action: #selector(setupVibrationOnTouch(sender:)), for: .valueChanged)
                
                if defaults.bool(forKey: Resource.Defaults.vibrationOnTouch) == true {
                    cell.switchButton.isOn = true
                } else {
                    cell.switchButton.isOn = false
                }
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseSettingCell, for: indexPath) as! SettingCell
                return cell
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseSettingSwitchCell, for: indexPath) as! SettingSwitchCell
                cell.textLabel?.text = "\(badgeIcon[indexPath.row])"
                cell.selectionStyle = .none
                cell.switchButton.addTarget(self, action: #selector(showBadgeIcon(sender:)), for: .valueChanged)
                
                if defaults.bool(forKey: Resource.Defaults.showBadgeIcon) == true {
                    cell.switchButton.isOn = true
                } else {
                    cell.switchButton.isOn = false
                }
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseSettingCell, for: indexPath) as! SettingCell
                return cell
            }
        }
        
        return cell
    }
    
    @objc func setupVibrationOnTouch(sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: Resource.Defaults.vibrationOnTouch)
            
            viewWillAppear(true)
            self.tableView.reloadData()
        } else {
            defaults.set(false, forKey: Resource.Defaults.vibrationOnTouch)
            
            viewWillAppear(true)
            self.tableView.reloadData()
        }
    }
    
    @objc func showBadgeIcon(sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: Resource.Defaults.showBadgeIcon)
            viewWillAppear(true)
            self.tableView.reloadData()
        } else {
            defaults.set(false, forKey: Resource.Defaults.showBadgeIcon)
            viewWillAppear(true)
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
}

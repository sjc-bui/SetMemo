//
//  SettingViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import RealmSwift

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let sections: Array = [NSLocalizedString("General", comment: ""), NSLocalizedString("Advanced", comment: "")]
    let general: Array = [NSLocalizedString("About", comment: ""), NSLocalizedString("Appearance", comment: ""), NSLocalizedString("Alert", comment: ""),
    NSLocalizedString("PlaceHolderLabel", comment: "")]
    let advanced: Array = [NSLocalizedString("DeleteLabel", comment: "")]
    
    var tableView: UITableView!
    private let reuseIdentifier = "SettingCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Setting", comment: "")
        self.navigationController?.navigationBar.shadowImage = UIImage()
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
            case 3:
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
            let cell = tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
            switch indexPath.row {
            case 0:
                self.navigationController?.pushViewController(AboutController(), animated: true)
            case 1:
                self.navigationController?.pushViewController(AppearanceController(), animated: true)
            case 2:
                self.navigationController?.pushViewController(AlertsController(), animated: true)
            case 3:
                let alert = UIAlertController(title: NSLocalizedString("Placeholder", comment: ""), message: NSLocalizedString("CustomPlaceholder", comment: ""), preferredStyle: .alert)
                
                alert.addTextField { textField in
                    let placeholder = UserDefaults.standard.string(forKey: "writeNotePlaceholder")
                    textField.placeholder = placeholder ?? "lalala..."
                    textField.autocorrectionType = .yes
                    textField.autocapitalizationType = .sentences
                }
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { [weak alert] _ in
                    print(alert?.message ?? "cancel")
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { [weak alert] _ in
                    let textField = alert?.textFields![0]
                    let text = textField?.text
                    
                    if text?.isEmpty ?? false {
                    } else {
                        UserDefaults.standard.set(text, forKey: "writeNotePlaceholder")
                    }
                }))
                
                present(alert, animated: true, completion: nil)
            default:
                return
            }
        } else if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
            switch indexPath.row {
            case 0:
                let deleteAllAlert = UIAlertController(title: NSLocalizedString("Sure", comment: ""), message: NSLocalizedString("DeleteAll", comment: ""), preferredStyle: .alert)
                let delete = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { action in
                })
                
                let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
                deleteAllAlert.addAction(cancel)
                deleteAllAlert.addAction(delete)
                
                present(deleteAllAlert, animated: true, completion: nil)
            default:
                return
            }
        }
    }
    
    // MARK: - Delete All Data
    @objc func DeleteAll() {
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

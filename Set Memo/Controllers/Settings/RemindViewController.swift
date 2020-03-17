//
//  RemindViewController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/17.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class RemindViewConntroller: UIViewController {
    let datePicker = UIDatePicker()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        setupView()
    }
    
    func setupNavigation() {
        self.navigationItem.title = NSLocalizedString("RemindEveryDay", comment: "")
        
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(setRemind))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func setRemind() {
        fireNotification()
        defaults.set(true, forKey: Resource.Defaults.remindEveryDay)
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupView() {
        datePicker.datePickerMode = .time
        self.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        datePicker.widthAnchor.constraint(equalToConstant: 250).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 130).isActive = true
    }
    
    func fireNotification() {
        let center = UNUserNotificationCenter.current()
        // let uuid = UUID().uuidString
        let id = "daily"
        
        let content = UNMutableNotificationContent()
        content.title = "Set Memo"
        content.body = String(format: NSLocalizedString("WriteMemoToday", comment: ""), "Quan")
        content.sound = UNNotificationSound.default
        content.threadIdentifier = "notifi"
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        
        let dateComponent = datePicker.calendar?.dateComponents([.hour, .minute], from: datePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent!, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error != nil {
                print(error!)
            }
        }
    }
}

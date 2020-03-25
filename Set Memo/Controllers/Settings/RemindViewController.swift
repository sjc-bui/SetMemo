//
//  RemindViewController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/17.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class RemindViewController: UIViewController {
    let datePicker: UIDatePicker = UIDatePicker()
    let defaults = UserDefaults.standard
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done".localized, for: .normal)
        button.addTarget(self, action: #selector(setRemind(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 12
        button.backgroundColor = Colors.shared.accentColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        setupView()
    }
    
    func setupNavigation() {
        self.navigationItem.title = "RemindEveryDay".localized
    }
    
    @objc func setRemind(sender: UIButton) {
        fireNotification()
        defaults.set(true, forKey: Resource.Defaults.remindEveryDay)
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupView() {
        self.view.addSubview(datePicker)
        self.view.addSubview(confirmButton)
        
        datePicker.datePickerMode = .time
        datePicker.timeZone = NSTimeZone.local
        datePicker.setValue(UIColor.label, forKey: "textColor")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        datePicker.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        confirmButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 30).isActive = true
    }
    
    func fireNotification() {
        let center = UNUserNotificationCenter.current()
        // let uuid = UUID().uuidString
        let id = "daily"
        
        let content = UNMutableNotificationContent()
        content.body = String(format: "WriteMemoToday".localized, "Quan")
        content.sound = UNNotificationSound.default
        content.threadIdentifier = "notifi"
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        
        let dateComponent = datePicker.calendar?.dateComponents([.hour, .minute], from: datePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent!, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateFromPicker = dateFormatter.string(from: datePicker.date)
        defaults.set(dateFromPicker, forKey: Resource.Defaults.remindAt)
        
        center.add(request) { (error) in
            if error != nil {
                print(error!)
            }
        }
    }
}

//
//  ReminderViewController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/21.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController {
    
    var memoData: [Memo] = []
    var filterMemoData: [Memo] = []
    var isFiltering: Bool = false
    var index: Int = 0
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.timeZone = NSTimeZone.local
        picker.datePickerMode = .dateAndTime
        return picker
    }()
    
    lazy var setRemindButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Done".localized, for: .normal)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = Colors.shared.defaultTintColor.adjust(by: -7.75)
        btn.layer.cornerRadius = 12
        btn.addTarget(self, action: #selector(setReminder(sender:)), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.shared.defaultTintColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRightBarButton()
    }
    
    func setupView() {
        self.navigationController?.navigationBar.setColors(background: Colors.shared.defaultTintColor, text: .white)
        datePicker.setValue(UIColor.white, forKey: "textColor")
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        setRemindButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(datePicker)
        view.addSubview(setRemindButton)
        
        let buttonWidth: CGFloat?
        if UIDevice.current.userInterfaceIdiom == .pad {
            buttonWidth = 400
            
        } else {
            buttonWidth = 340
        }
        
        datePicker.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 200).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setRemindButton.widthAnchor.constraint(equalToConstant: buttonWidth!).isActive = true
        setRemindButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        setRemindButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        setRemindButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14).isActive = true
    }
    
    @objc func setReminder(sender: UIButton) {
        print("Reminder is set")
        setReminderContent(index: index)
        dismiss(animated: true, completion: nil)
    }
    
    func setReminderContent(index: Int) {
        
        if isFiltering == true {
            let filterData = filterMemoData[index]
            let content = filterData.value(forKey: "content") as? String
            let hashTag = filterData.value(forKey: "hashTag") as? String
            scheduleNotification(title: hashTag!, bodyContent: content!, index: index)
            
        } else {
            let memo = memoData[index]
            let content = memo.value(forKey: "content") as? String
            let hashTag = memo.value(forKey: "hashTag") as? String
            scheduleNotification(title: hashTag!, bodyContent: content!, index: index)
        }
    }
    
    func scheduleNotification(title: String, bodyContent: String, index: Int) {
        
        let center = UNUserNotificationCenter.current()
        let uuid = UUID().uuidString
        
        let content = UNMutableNotificationContent()
        content.title = "#\(title)"
        content.body = bodyContent
        content.userInfo = ["reminderTitle": title]
        content.sound = UNNotificationSound.default
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        
        let components = datePicker.calendar?.dateComponents([.year, .month, .day, .hour, .minute], from: datePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components!, repeats: false)
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "DatetimeFormat".localized
        let dateFromPicker = dateFormatter.string(from: datePicker.date)
        
        center.add(request) { (error) in
            if error != nil {
                print("Reminder error: \(error!)")
            }
        }
        
        updateContentWithReminder(notificationUUID: uuid, dateReminder: datePicker.date.timeIntervalSinceReferenceDate, index: index)
        
        SPAlert().done(title: "RemindSetTitle".localized, message: String(format: "RemindAt".localized, dateFromPicker), haptic: true, duration: 2.0)
    }
    
    func updateContentWithReminder(notificationUUID: String, dateReminder: Double, index: Int) {
        
        if isFiltering == true {
            let filterData = filterMemoData[index]
            filterData.notificationUUID = notificationUUID
            filterData.dateReminder = dateReminder
            filterData.isReminder = true
            
        } else {
            let memo = memoData[index]
            memo.notificationUUID = notificationUUID
            memo.dateReminder = dateReminder
            memo.isReminder = true
        }
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        do {
            try context?.save()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func setupRightBarButton() {
        let closeBtn = UIBarButtonItem(image: UIImage(named: "cancel"), style: .done, target: self, action: #selector(dismissView))
        self.navigationItem.rightBarButtonItem = closeBtn
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    @objc func dismissView() {
        print("dismiss")
        DeviceControl().feedbackOnPress()
        dismiss(animated: true, completion: nil)
    }
}
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
    var background: UIColor?
    let defaults = UserDefaults.standard
    
    lazy var label: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.boldSystemFont(ofSize: 40)
        return l
    }()
    
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
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 14
        btn.addTarget(self, action: #selector(setReminder(sender:)), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = background
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
        self.navigationController?.navigationBar.setColors(background: background!, text: .white)
        datePicker.setValue(UIColor.white, forKey: "textColor")
        
        label.text = "SetReminderTitle".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        setRemindButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubviews([label, datePicker, setRemindButton])
        
        if defaults.bool(forKey: Resource.Defaults.useCellColor) == false {
            background = UIColor.darkGray
        }
        
        setRemindButton.backgroundColor = background!.adjust(by: -7.75)
        
        let buttonWidth: CGFloat?
        if UIDevice.current.userInterfaceIdiom == .pad {
            buttonWidth = 400
            
        } else {
            buttonWidth = 340
        }
        
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 36).isActive = true
        
        datePicker.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 250).isActive = true
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
        content.title = title
        content.body = bodyContent.trimmingCharacters(in: .whitespacesAndNewlines)
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
        
        ShowToast.toast(message: String(format: "RemindAt".localized, dateFromPicker), duration: 2.0)
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
        let closeBtn = UIBarButtonItem(image: UIImage.SVGImage(named: "icons_filled_cancel", fillColor: .white), style: .done, target: self, action: #selector(dismissView))
        self.navigationItem.rightBarButtonItem = closeBtn
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

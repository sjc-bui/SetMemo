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
        btn.backgroundColor = .lightGray
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
        setupRightBarButton()
        setupView()
    }
    
    func setupView() {
        datePicker.setValue(UIColor.white, forKey: "textColor")
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        setRemindButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(datePicker)
        view.addSubview(setRemindButton)
        
        datePicker.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: view.frame.size.height / 3).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setRemindButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        setRemindButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        setRemindButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        setRemindButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20).isActive = true
    }
    
    @objc func setReminder(sender: UIButton) {
        print("Reminder is set")
        dismiss(animated: true, completion: nil)
    }
    
    func setupRightBarButton() {
        self.navigationController?.navigationBar.tintColor = .white
        let closeBtn = UIBarButtonItem(image: UIImage(named: "cancel"), style: .done, target: self, action: #selector(dismissView))
        self.navigationItem.rightBarButtonItem = closeBtn
        self.navigationController?.navigationBar.setColors(background: Colors.shared.defaultTintColor, text: .white)
    }
    
    @objc func dismissView() {
        print("dismiss")
        DeviceControl().feedbackOnPress()
        dismiss(animated: true, completion: nil)
    }
}

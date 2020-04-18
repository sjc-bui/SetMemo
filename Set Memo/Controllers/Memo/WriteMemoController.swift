//
//  NewMemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import CoreData

class WriteMemoController: BaseViewController, UITextViewDelegate {
    
    let editor = TextViewEditor()
    let defaults = UserDefaults.standard
    var hashTag: String?
    var navigationBarHeight: CGFloat?
    let randomColor = UIColor.getRandomColor()
    let setting = SettingViewController()
    
    func setupUI() {
        view = editor
        editor.textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        editor.textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        editor.textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        editor.textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    }
    
    override func initialize() {
        setupUI()
        navigationBarHeight = self.navigationController?.navigationBar.bounds.height ?? 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardListener()
        
        self.view.backgroundColor = UIColor.getRandomColorFromString(color: randomColor)
        editor.textView.backgroundColor = UIColor.getRandomColorFromString(color: randomColor)
        setupNavigationBar()
        setupDynamicKeyboardColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        editor.textView.setupTextViewToolbar()
        editor.textView.becomeFirstResponder()
        setupRightBarButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeNotificationObserver()
        self.autoSave()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        editor.textView.resignFirstResponder()
    }
    
    func setupDynamicKeyboardColor() {
        if setting.darkModeIsEnable() == true {
            editor.textView.keyboardAppearance = .dark
            editor.textView.overrideUserInterfaceStyle = .dark
            
        } else {
            editor.textView.keyboardAppearance = .default
            editor.textView.overrideUserInterfaceStyle = .light
        }
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.setColors(background: UIColor.getRandomColorFromString(color: randomColor), text: .white)
    }
    
    func setupRightBarButtons() {
        let hashTagButton = UIBarButtonItem(image: Resource.Images.hashTagButton, style: .plain, target: self, action: #selector(setHashTag))
        let doneButton = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(hideKeyboard))
        self.navigationItem.rightBarButtonItems = [doneButton, hashTagButton]
    }
    
    @objc func setHashTag() {
        
        DeviceControl().feedbackOnPress()
        let alert = UIAlertController(title: "#hashTag", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "hashTag"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .none
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let doneBtn = UIAlertAction(title: "Done".localized, style: .default, handler: { [weak alert] _ in
            let textField = alert?.textFields![0]
            let text = textField?.text
            
            if text?.isNullOrWhiteSpace() ?? false {
            } else {
                self.hashTag = FormatString().formatHashTag(text: text!)
                print(FormatString().formatHashTag(text: text!))
            }
        })
        
        alert.view.tintColor = Colors.shared.defaultTintColor
        alert.addAction(cancelBtn)
        alert.addAction(doneBtn)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func autoSave() {
        
        if !editor.textView.text.isNullOrWhiteSpace() {
            let date = Date.timeIntervalSinceReferenceDate
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            do {
                setMemoValue(context: managedContext, content: editor.textView.text, hashTag: hashTag ?? "todo", date: date)
                try managedContext.save()
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            editor.textView.text = ""
        }
    }
    
    func setMemoValue(context: NSManagedObjectContext, content: String, hashTag: String, date: Double) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Memo", in: context)
        let memo = NSManagedObject(entity: entity!, insertInto: context)
        
        memo.setValue(content, forKey: "content")
        memo.setValue(date, forKey: "dateEdited")
        memo.setValue(date, forKey: "dateCreated")
        memo.setValue(hashTag, forKey: "hashTag")
        memo.setValue(false, forKey: "isReminder")
        memo.setValue(false, forKey: "isLocked")
        memo.setValue(false, forKey: "isEdited")
        memo.setValue(false, forKey: "temporarilyDelete")
        memo.setValue(0, forKey: "dateReminder")
        memo.setValue(randomColor, forKey: "color")
        
        let updateDate = Date(timeIntervalSinceReferenceDate: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeZone = .current
        let dateString = dateFormatter.string(from: updateDate)
        
        memo.setValue(dateString, forKey: "dateString")
    }
    
    @objc func hideKeyboard() {
        DeviceControl().feedbackOnPress()
        editor.textView.endEditing(true)
    }
    
    func addKeyboardListener() {
        self.addNotificationObserver(selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification)
        
        self.addNotificationObserver(selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardViewEndFrame = keyboardValue.cgRectValue
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            editor.textView.contentInset = .zero
            self.navigationItem.rightBarButtonEnable(isEnabled: false)
        } else {
            editor.textView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardViewEndFrame.size.height, right: 0.0)
            self.navigationItem.rightBarButtonEnable(isEnabled: true)
        }
        
        editor.textView.scrollIndicatorInsets = editor.textView.contentInset
        
        let selectedRange = editor.textView.selectedRange
        editor.textView.scrollRangeToVisible(selectedRange)
    }
}

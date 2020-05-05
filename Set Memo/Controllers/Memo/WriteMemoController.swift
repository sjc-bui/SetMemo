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
        editor.textView.anchor(top: view.safeAreaLayoutGuide.topAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor)
    }
    
    override func initialize() {
        setupUI()
        navigationBarHeight = self.navigationController?.navigationBar.bounds.height ?? 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardListener()
        var background = UIColor.getRandomColorFromString(color: randomColor)
        
        if defaults.bool(forKey: Resource.Defaults.useCellColor) == false {
            background = UIColor.black
        }
        
        self.view.backgroundColor = background
        editor.textView.backgroundColor = background
        setupNavigationBar(navBackground: background)
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
    
    func setupNavigationBar(navBackground: UIColor) {
        navigationController?.navigationBar.setColors(background: navBackground, text: .white)
    }
    
    func setupRightBarButtons() {
        let hashTagButton = UIBarButtonItem(image: Resource.Images.hashTagButton, style: .plain, target: self, action: #selector(setHashTag))
        self.navigationItem.rightBarButtonItem = hashTagButton
    }
    
    @objc func setHashTag() {
        
        DeviceControl().feedbackOnPress()
        let alertController = UIAlertController(title: "#hashTag", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "newHashtag"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .none
            
            if self.defaults.bool(forKey: Resource.Defaults.useDarkMode) == true {
                textField.keyboardAppearance = .dark
                
            } else {
                textField.keyboardAppearance = .default
            }
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Done".localized, style: .default, handler: { _ in
            let text = alertController.textFields?.first?.text
            if text?.isNullOrWhiteSpace() ?? false {
            } else {
                guard let text = alertController.textFields!.first?.text else { return }
                if text.isNullOrWhiteSpace() {
                } else {
                    self.hashTag = FormatString().formatHashTag(text: text)
                    print(FormatString().formatHashTag(text: text))
                }
            }
        }))
        
        if defaults.bool(forKey: Resource.Defaults.useDarkMode) == true {
            alertController.overrideUserInterfaceStyle = .dark
            
        } else {
            alertController.overrideUserInterfaceStyle = .light
        }
        
        alertController.view.tintColor = Colors.shared.defaultTintColor
        present(alertController, animated: true, completion: nil)
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
    
    func addKeyboardListener() {
        self.addNotificationObserver(selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification)
        
        self.addNotificationObserver(selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardViewEndFrame = keyboardValue.cgRectValue
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            editor.textView.contentInset = .zero
            
        } else {
            editor.textView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardViewEndFrame.size.height, right: 0.0)
        }
        
        editor.textView.scrollIndicatorInsets = editor.textView.contentInset
        
        let selectedRange = editor.textView.selectedRange
        editor.textView.scrollRangeToVisible(selectedRange)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

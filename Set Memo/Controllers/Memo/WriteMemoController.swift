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
    
    let defaults = UserDefaults.standard
    var hashTag: String?
    var navigationBarHeight: CGFloat?
    
    fileprivate var textView: UITextView = {
        let tv = UITextView()
        tv.tintColor = Colors.shared.accentColor
        tv.isEditable = true
        tv.isScrollEnabled = true
        tv.text = ""
        tv.textColor = UIColor(named: "mainTextColor")
        tv.isUserInteractionEnabled = true
        tv.alwaysBounceVertical = true
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: CGFloat(UserDefaults.standard.float(forKey: Resource.Defaults.fontSize)), weight: .regular)
        return tv
    }()
    
    func setupUI() {
        self.view.addSubview(textView)
        textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
    
    override func initialize() {
        setupUI()
        navigationBarHeight = self.navigationController?.navigationBar.bounds.height ?? 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        characterCount()
        addKeyboardListener()
        //setupNavigationToolBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
        setupRightBarButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //self.navigationController?.setToolbarHidden(true, animated: true)
        self.autoSave()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        textView.resignFirstResponder()
    }
    
    fileprivate func setupNavigationToolBar() {
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        let items: [UIBarButtonItem] = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Select", style: .plain, target: self, action: nil)
        ]
        self.toolbarItems = items
    }
    
    func setupRightBarButtons() {
        let hashTagButton = UIBarButtonItem(image: Resource.Images.hashTagButton, style: .plain, target: self, action: #selector(setHashTag))
        let doneButton = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(hideKeyboard))
        self.navigationItem.rightBarButtonItems = [doneButton, hashTagButton]
    }
    
    @objc func setHashTag() {
        let alert = UIAlertController(title: "#hashTag", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "hashTag"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .none
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel".localized, style: .default, handler: nil)
        let doneBtn = UIAlertAction(title: "Done".localized, style: .default, handler: { [weak alert] _ in
            let textField = alert?.textFields![0]
            let text = textField?.text
            
            if text?.isNullOrWhiteSpace() ?? false {
            } else {
                self.hashTag = FormatString().formatHashTag(text: text!)
                print(FormatString().formatHashTag(text: text!))
            }
        })
        
        doneBtn.setValue(Colors.shared.accentColor, forKey: Resource.Defaults.titleTextColor)
        
        alert.addAction(cancelBtn)
        alert.addAction(doneBtn)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        characterCount()
    }
    
    private func characterCount() {
        let textCount: Int = textView.text.count
        self.navigationItem.title = String(format: "%d", textCount)
    }
    
    @objc func autoSave() {
        
        if !textView.text.isNullOrWhiteSpace() {
            let date = Date.timeIntervalSinceReferenceDate
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            do {
                setMemoValue(context: managedContext, content: textView.text, hashTag: hashTag ?? "todo", date: date)
                try managedContext.save()
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            characterCount()
            textView.text = ""
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
        memo.setValue(false, forKey: "isEdited")
        memo.setValue(false, forKey: "temporarilyDelete")
        memo.setValue(0, forKey: "dateReminder")
        
        let updateDate = Date(timeIntervalSinceReferenceDate: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeZone = .current
        let dateString = dateFormatter.string(from: updateDate)
        
        memo.setValue(dateString, forKey: "dateString")
    }
    
    @objc func hideKeyboard() {
        textView.endEditing(true)
    }
    
    func addKeyboardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardViewEndFrame = keyboardValue.cgRectValue
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            //writeMemoView.inputTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 68, right: 0)
        } else {
            //writeMemoView.inputTextView.contentInset.bottom = keyboardViewEndFrame.size.height + 68
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
}

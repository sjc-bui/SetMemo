//
//  NewMemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import CoreData

class WriteMemoController: UIViewController, UITextViewDelegate {
    let writeMemoView = WriteMemoView()
    var inputContent: String? = nil
    let defaults = UserDefaults.standard
    var hashTag: String?
    var navigationBarHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        navigationBarHeight = self.navigationController?.navigationBar.bounds.height ?? 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        writeMemoView.backgroundColor = .white
        setupPlaceholder()
        characterCount()
        setupDynamicKeyboardColor()
        addKeyboardListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        writeMemoView.inputTextView.becomeFirstResponder()
        setupRightBarButtons()
    }
    
    func setupRightBarButtons() {
        let hashTagButton = UIBarButtonItem(image: Resource.Images.hashTagButton, style: .plain, target: self, action: #selector(setHashTag))
        let doneButton = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(hideKeyboard))
        self.navigationItem.rightBarButtonItems = [doneButton, hashTagButton]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.autoSave()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        writeMemoView.inputTextView.resignFirstResponder()
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
        
        cancelBtn.setValue(Colors.shared.accentColor, forKey: Resource.Defaults.titleTextColor)
        doneBtn.setValue(Colors.shared.accentColor, forKey: Resource.Defaults.titleTextColor)
        
        alert.addAction(cancelBtn)
        alert.addAction(doneBtn)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        characterCount()
    }
    
    func setupPlaceholder() {
        let placeholder = UserDefaults.standard.string(forKey: Resource.Defaults.writeMemoPlaceholder) ?? ""
        writeMemoView.inputTextView.placeholder = placeholder
    }
    
    private func characterCount() {
        let textCount: Int = writeMemoView.inputTextView.text.count
        self.navigationItem.title = String(format: "%d", textCount)
    }
    
    @objc func autoSave() {
        
        if !writeMemoView.inputTextView.text.isNullOrWhiteSpace() {
            let date = Date.timeIntervalSinceReferenceDate
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            do {
                setMemoValue(context: managedContext, content: writeMemoView.inputTextView.text, hashTag: hashTag ?? "todo", date: date)
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            characterCount()
            writeMemoView.inputTextView.text = ""
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
    
    func setupView() {
        view = writeMemoView
        writeMemoView.inputTextView.frame = CGRect(x: 0, y: 0, width: writeMemoView.screenWidth, height: writeMemoView.screenHeight)
        writeMemoView.inputTextView.isScrollEnabled = false
        writeMemoView.inputTextView.delegate = self
        writeMemoView.inputTextView.isScrollEnabled = true
    }
    
    @objc func hideKeyboard() {
        writeMemoView.inputTextView.endEditing(true)
    }
    
    func setupDynamicKeyboardColor() {
        if defaults.string(forKey: Resource.Defaults.iconType) == "light" {
            writeMemoView.inputTextView.keyboardAppearance = .default
        } else {
            writeMemoView.inputTextView.keyboardAppearance = .dark
        }
    }
    
    func addKeyboardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardViewEndFrame = keyboardValue.cgRectValue
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            writeMemoView.inputTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 68, right: 0)
        } else {
            writeMemoView.inputTextView.contentInset.bottom = keyboardViewEndFrame.size.height + 68
        }
        
        writeMemoView.inputTextView.scrollIndicatorInsets = writeMemoView.inputTextView.contentInset
        
        let selectedRange = writeMemoView.inputTextView.selectedRange
        writeMemoView.inputTextView.scrollRangeToVisible(selectedRange)
    }
}

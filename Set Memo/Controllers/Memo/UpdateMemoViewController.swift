//
//  UpdateMemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/01.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class UpdateMemoViewController: BaseViewController, UITextViewDelegate {
    
    var content: String = ""
    var hashTag: String = ""
    var dateCreated: String = ""
    var dateEdited: String = ""
    var isReminder: Bool = false
    var dateReminder: String?
    
    let writeMemoView = WriteMemoView()
    
    var memoData: [Memo] = []
    var filterMemoData: [Memo] = []
    var isFiltering: Bool = false
    var index: Int = 0
    
    override func initialize() {
        print(index)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        writeMemoView.inputTextView.text = content
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRightBarButton()
        addKeyboardListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        updateContent(index: index, newContent: writeMemoView.inputTextView.text)
    }
    
    func addKeyboardListener() {
        self.navigationItem.rightBarButtonEnable(isEnabled: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            writeMemoView.inputTextView.contentInset = .zero
            self.navigationItem.rightBarButtonEnable(isEnabled: false)
            
        } else {
            writeMemoView.inputTextView.contentInset.bottom = keyboardScreenEndFrame.size.height + 68
            self.navigationItem.rightBarButtonEnable(isEnabled: true)
        }
        
        writeMemoView.inputTextView.scrollIndicatorInsets = writeMemoView.inputTextView.contentInset
        
        let selectedRange = writeMemoView.inputTextView.selectedRange
        writeMemoView.inputTextView.scrollRangeToVisible(selectedRange)
    }
    
    func setupRightBarButton() {
        
        let hideKeyboardBtn = UIBarButtonItem(image: Resource.Images.keyboardButton, style: .plain, target: self, action: #selector(hideKeyboard))
        let hashTagBtn = UIBarButtonItem(image: Resource.Images.hashTagButton, style: .plain, target: self, action: #selector(hashTagChangeHandler))
        let infoBtn = UIBarButtonItem(image: Resource.Images.infoButton, style: .plain, target: self, action: #selector(showMemoInfo))
        
        self.navigationItem.rightBarButtonItems = [hideKeyboardBtn, hashTagBtn, infoBtn]
    }
    
    @objc func showMemoInfo() {
        let contentCount = content.countWords()
        let createdInfo = String(format: "DateCreatedInfo".localized, dateCreated)
        let editedInfo = String(format: "DateEditedInfo".localized, dateEdited)
        let charsCount = String(format: "CharactersCount".localized, content.count)
        let wordsCount = String(format: "WordsCount".localized, contentCount)
        
        let alert = UIAlertController(title: nil, message: "\(createdInfo)\n\(editedInfo)\n\(charsCount)\n\(wordsCount)", preferredStyle: .actionSheet)
        
        let deleteReminderBtn = UIAlertAction(title: "DeleteReminder".localized, style: .default) { (action) in
            print("reminder deleted")
        }
        let doneBtn = UIAlertAction(title: "Done".localized, style: .cancel, handler: nil)
        
        alert.view.tintColor = Colors.shared.accentColor
        alert.pruneNegativeWidthConstraints()
        alert.addAction(doneBtn)
        
        if isReminder {
            alert.addAction(deleteReminderBtn)
        }
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.any]
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        DeviceControl().feedbackOnPress()
        self.view.endEditing(true)
    }
    
    @objc func hashTagChangeHandler() {
        
        let alert = UIAlertController(title: "#\(hashTag)", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "newHashTag"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Done".localized, style: .default, handler: { [weak alert] _ in
            
            let textField = alert?.textFields![0]
            let text = textField?.text
            
            if text?.isNullOrWhiteSpace() ?? false {
            } else {
                let newHashTag = FormatString().formatHashTag(text: text!)
                self.updateHashTag(index: self.index, newHashTag: newHashTag)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateHashTag(index: Int, newHashTag: String) {
        if isFiltering == true {
            if filterMemoData[index].hashTag != newHashTag {
                filterMemoData[index].hashTag = newHashTag
                filterMemoData[index].dateEdited = Date.timeIntervalSinceReferenceDate
            }
            
        } else if isFiltering == false {
            if memoData[index].hashTag != newHashTag {
                memoData[index].hashTag = newHashTag
                memoData[index].dateEdited = Date.timeIntervalSinceReferenceDate
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        do {
            try context?.save()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func setupView() {
        view = writeMemoView
        let textView = writeMemoView.inputTextView
        writeMemoView.inputTextView.frame = CGRect(x: 0, y: 0, width: writeMemoView.screenWidth, height: writeMemoView.screenHeight)
        textView.font = UIFont.systemFont(ofSize: CGFloat(UserDefaults.standard.float(forKey: Resource.Defaults.fontSize)))
        textView.placeholder = ""
        textView.alwaysBounceVertical = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.isPlaceholderScrollEnabled = true
        textView.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func updateContent(index: Int, newContent: String) {
        
        if isFiltering == true {
            if filterMemoData[index].content != newContent {
                filterMemoData[index].content = newContent
                filterMemoData[index].dateEdited = Date.timeIntervalSinceReferenceDate
                print("Update filter data")
            }
            
        } else if isFiltering == false {
            if memoData[index].content != newContent {
                memoData[index].content = newContent
                memoData[index].dateEdited = Date.timeIntervalSinceReferenceDate
                print("Update data")
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        do {
            try context?.save()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

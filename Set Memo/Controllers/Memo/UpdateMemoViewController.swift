//
//  UpdateMemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/01.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import SPAlert

class UpdateMemoViewController: BaseViewController, UITextViewDelegate {
    
    var content: String = ""
    var hashTag: String = ""
    var dateCreated: String = ""
    var dateEdited: String = ""
    var dateReminder: String = ""
    var isReminder: Bool = false
    var isEdited: Bool = false
    var dateLabelHeader: String = ""
    
    var memoData: [Memo] = []
    var filterMemoData: [Memo] = []
    var isFiltering: Bool = false
    var index: Int = 0
    
    fileprivate var textView: UITextView = {
        let tv = UITextView()
        tv.tintColor = Colors.shared.accentColor
        tv.isEditable = true
        tv.isScrollEnabled = true
        tv.text = "update text view."
        tv.textColor = UIColor(named: "mainTextColor")
        tv.isUserInteractionEnabled = true
        tv.alwaysBounceVertical = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tv.font = UIFont.systemFont(ofSize: CGFloat(UserDefaults.standard.float(forKey: Resource.Defaults.fontSize)), weight: .regular)
        return tv
    }()
    
    fileprivate var dateEditedLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.text = "not set"
        lb.textColor = UIColor.lightGray
        lb.backgroundColor = UIColor.systemBackground
        lb.textDropShadow()
        lb.textAlignment = .center
        return lb
    }()
    
    func setupUI() {
        view.addSubview(dateEditedLabel)
        view.addSubview(textView)
        
        dateEditedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        dateEditedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dateEditedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dateEditedLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        textView.topAnchor.constraint(equalTo: dateEditedLabel.bottomAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
    
    func textViewToolBar() {
        let items = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let moveLeft = UIBarButtonItem(image: Resource.Images.moveLeftButton, style: .plain, target: self, action: #selector(moveCursorToLeft))
        let moveRight = UIBarButtonItem(image: Resource.Images.moveRightButton, style: .plain, target: self, action: #selector(moveCursorToRight))
        let calendarBadge = UIBarButtonItem(image: Resource.Images.addCalendarButton, style: .plain, target: self, action: #selector(selectCurrentDate))
        let sharpSign = UIBarButtonItem(image: Resource.Images.sharpButton, style: .plain, target: self, action: #selector(addSharpSign))
        let moveToBegin = UIBarButtonItem(image: Resource.Images.moveToBeginButton, style: .plain, target: self, action: #selector(moveBegin))
        let moveToEnd = UIBarButtonItem(image: Resource.Images.moveToEndButton, style: .plain, target: self, action: #selector(moveEnd))
        let addTabSpace = UIBarButtonItem(image: Resource.Images.addTabSpace, style: .plain, target: self, action: #selector(addTab))
        
        items.setItems([
            moveLeft, flexibleSpace,
            moveRight, flexibleSpace,
            addTabSpace, flexibleSpace,
            moveToBegin, flexibleSpace,
            moveToEnd, flexibleSpace,
            sharpSign, flexibleSpace,
            calendarBadge], animated: true)
        items.barStyle = .default
        items.tintColor = Colors.shared.accentColor
        items.isUserInteractionEnabled = true
        items.sizeToFit()
        
        textView.inputAccessoryView = items
    }
    
    @objc fileprivate func moveCursorToLeft() {
        if let selectedRange = textView.selectedTextRange {
            if let newPosition = textView.position(from: selectedRange.start, offset: -1) {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    @objc fileprivate func moveCursorToRight() {
        if let selectedRange = textView.selectedTextRange {
            if let newPosition = textView.position(from: selectedRange.start, offset: 1) {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    @objc fileprivate func selectCurrentDate() {
        
        let selectCurrentDateSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let now = Date()
        
        let dateTimeFullString = now.string(with: "DatetimeFormat".localized)
        let timeLongString = now.string(with: "DateMonthYear".localized)
        let timeShortString = now.string(with: "DateTimeShort".localized)
        let hourMinuteString = now.string(with: "HourAndMinute".localized)
        
        let fullStyle = UIAlertAction(title: "\(dateTimeFullString)", style: .default) { (action) in
            self.textView.insertText(" \(dateTimeFullString)")
        }
        let timeLong = UIAlertAction(title: "\(timeLongString)", style: .default) { (action) in
            self.textView.insertText(" \(timeLongString)")
        }
        let timeShort = UIAlertAction(title: "\(timeShortString)", style: .default) { (action) in
            self.textView.insertText(" \(timeShortString)")
        }
        let hourMinute = UIAlertAction(title: "\(hourMinuteString)", style: .default) { (action) in
            self.textView.insertText(" \(hourMinuteString)")
        }
        let cancelButton = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        selectCurrentDateSheet.view.tintColor = Colors.shared.accentColor
        selectCurrentDateSheet.addAction(cancelButton)
        selectCurrentDateSheet.addAction(fullStyle)
        selectCurrentDateSheet.addAction(timeLong)
        selectCurrentDateSheet.addAction(timeShort)
        selectCurrentDateSheet.addAction(hourMinute)
        
        selectCurrentDateSheet.pruneNegativeWidthConstraints()
        selectCurrentDateSheet.safePosition()
        
        self.present(selectCurrentDateSheet, animated: true, completion: nil)
    }
    
    @objc fileprivate func addSharpSign() {
        let sharpSign = "#"
        textView.insertText(sharpSign)
    }
    
    @objc fileprivate func moveBegin() {
        let begin = textView.beginningOfDocument
        textView.selectedTextRange = textView.textRange(from: begin, to: begin)
    }
    
    @objc fileprivate func moveEnd() {
        let end = textView.endOfDocument
        textView.selectedTextRange = textView.textRange(from: end, to: end)
    }
    
    @objc fileprivate func addTab() {
        textView.insertText("\t")
    }
    
    override func initialize() {
        print("This memo is remind = \(isReminder)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        textView.text = content
        dateEditedLabel.text = dateLabelHeader
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRightBarButton()
        addKeyboardListener()
        textViewToolBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        updateContent(index: index, newContent: textView.text)
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
            //writeMemoView.inputTextView.contentInset = .zero
            self.navigationItem.rightBarButtonEnable(isEnabled: false)
            
        } else {
            //writeMemoView.inputTextView.contentInset.bottom = keyboardScreenEndFrame.size.height + 68
            self.navigationItem.rightBarButtonEnable(isEnabled: true)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    func setupRightBarButton() {
        
        let hideKeyboardBtn = UIBarButtonItem(image: Resource.Images.keyboardButton, style: .plain, target: self, action: #selector(hideKeyboard))
        let hashTagBtn = UIBarButtonItem(image: Resource.Images.hashTagButton, style: .plain, target: self, action: #selector(hashTagChangeHandle))
        let infoBtn = UIBarButtonItem(image: Resource.Images.infoButton, style: .plain, target: self, action: #selector(viewMemoInfo))
        
        self.navigationItem.rightBarButtonItems = [hideKeyboardBtn, hashTagBtn, infoBtn]
    }
    
    @objc func viewMemoInfo() {
        
        let contentCount = content.countWords()
        let createdInfo = String(format: "DateCreatedInfo".localized, dateCreated)
        let editedInfo = String(format: "DateEditedInfo".localized, dateEdited)
        let reminderInfo = String(format: "DateReminderInfo".localized, dateReminder)
        let charsCount = String(format: "CharactersCount".localized, content.count)
        let wordsCount = String(format: "WordsCount".localized, contentCount)
        
        var info: String = ""
        info += "\(createdInfo)\n"
        if isEdited {
            info += "\(editedInfo)\n"
        }
        if isReminder {
            info += "\(reminderInfo)\n"
        }
        info += "\n\(charsCount)\n"
        info += "\(wordsCount)"
        
        let alert = UIAlertController(title: nil, message: "\(info)", preferredStyle: .actionSheet)
        
        let deleteReminderBtn = UIAlertAction(title: "DeleteReminder".localized, style: .default) { (action) in
            self.deleteReminderHandle()
        }
        let doneBtn = UIAlertAction(title: "Done".localized, style: .cancel, handler: nil)
        
        alert.view.tintColor = Colors.shared.accentColor
        alert.addAction(doneBtn)
        
        if isReminder {
            alert.addAction(deleteReminderBtn)
        }
        
        alert.pruneNegativeWidthConstraints()
        alert.safePosition()
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteReminderHandle() {
        
        if isFiltering == true {
            let removeUUID = filterMemoData[index].notificationUUID ?? "empty"
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [removeUUID])
            filterMemoData[index].isReminder = false
            filterMemoData[index].notificationUUID = "cleared"
            
        } else {
            let removeUUID = memoData[index].notificationUUID ?? "empty"
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [removeUUID])
            memoData[index].isReminder = false
            memoData[index].notificationUUID = "cleared"
        }
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        do {
            try context?.save()
            isReminder = false
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let alertView = SPAlertView(title: "ReminderDeleted".localized, message: nil, preset: .done)
        alertView.duration = 1
        alertView.present()
    }
    
    @objc func hideKeyboard() {
        DeviceControl().feedbackOnPress()
        self.view.endEditing(true)
    }
    
    @objc func hashTagChangeHandle() {
        
        let alert = UIAlertController(title: "#\(hashTag)", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "newHashTag"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .none
        }
        
        let cancelButton = UIAlertAction(title: "Cancel".localized, style: .default, handler: nil)
        let doneButton = UIAlertAction(title: "Done".localized, style: .default, handler: { [weak alert] _ in
            
            let textField = alert?.textFields![0]
            let text = textField?.text
            
            if text?.isNullOrWhiteSpace() ?? false {
            } else {
                let newHashTag = FormatString().formatHashTag(text: text!)
                self.updateHashTag(index: self.index, newHashTag: newHashTag)
            }
        })
        
        doneButton.setValue(Colors.shared.accentColor, forKey: Resource.Defaults.titleTextColor)
        alert.addAction(cancelButton)
        alert.addAction(doneButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateHashTag(index: Int, newHashTag: String) {
        
        if isFiltering == true {
            if filterMemoData[index].hashTag != newHashTag {
                filterMemoData[index].hashTag = newHashTag
                if filterMemoData[index].isEdited == false {
                    filterMemoData[index].isEdited = true
                }
                filterMemoData[index].dateEdited = Date.timeIntervalSinceReferenceDate
            }
            
        } else if isFiltering == false {
            if memoData[index].hashTag != newHashTag {
                memoData[index].hashTag = newHashTag
                if memoData[index].isEdited == false {
                    memoData[index].isEdited = true
                }
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func updateContent(index: Int, newContent: String) {
        
        if isFiltering == true {
            if filterMemoData[index].content != newContent {
                filterMemoData[index].content = newContent
                if filterMemoData[index].isEdited == false {
                    filterMemoData[index].isEdited = true
                }
                filterMemoData[index].dateEdited = Date.timeIntervalSinceReferenceDate
                print("Update filter data")
            }
            
        } else if isFiltering == false {
            if memoData[index].content != newContent {
                memoData[index].content = newContent
                if memoData[index].isEdited == false {
                    memoData[index].isEdited = true
                }
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

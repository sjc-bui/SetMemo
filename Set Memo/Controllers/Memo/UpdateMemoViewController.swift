//
//  UpdateMemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/01.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import LocalAuthentication
import EMAlertController
import SwiftKeychainWrapper

class UpdateMemoViewController: BaseViewController, UITextViewDelegate {
    
    var content: String = ""
    var hashTag: String = ""
    var dateCreated: String = ""
    var dateEdited: String = ""
    var dateReminder: String = ""
    var isReminder: Bool = false
    var isLocked: Bool = false
    var isEdited: Bool = false
    var dateLabelHeader: String = ""
    var backgroundColor: UIColor?
    
    var userUnlocked: Bool = false
    
    var memoData: [Memo] = []
    var filterMemoData: [Memo] = []
    var isFiltering: Bool = false
    var index: Int = 0
    let setting = SettingViewController()
    let defaults = UserDefaults.standard
    let keychain = KeychainWrapper.standard
    
    fileprivate var textView: UITextView = {
        let tv = UITextView()
        tv.tintColor = UIColor.white
        tv.isEditable = true
        tv.isScrollEnabled = true
        tv.text = "update text view."
        tv.textColor = UIColor.white
        tv.isUserInteractionEnabled = true
        tv.alwaysBounceVertical = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tv.font = UIFont.setCustomFont(style: UserDefaults.standard.string(forKey: Resource.Defaults.defaultFontStyle)!, fontSize: CGFloat(UserDefaults.standard.integer(forKey: Resource.Defaults.defaultTextViewFontSize)))
        return tv
    }()
    
    fileprivate var dateEditedLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.text = "not set"
        lb.textColor = UIColor.lightText
        lb.backgroundColor = UIColor.systemBackground
        lb.textDropShadow()
        lb.textAlignment = .center
        return lb
    }()
    
    let lockView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setupUI() {
        
        view.addSubviews([dateEditedLabel, textView])
        
        dateEditedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        dateEditedLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        dateEditedLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        dateEditedLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        textView.topAnchor.constraint(equalTo: dateEditedLabel.bottomAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    }
    
    func setupLockView() {
        view.addSubview(lockView)
        
        lockView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        lockView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lockView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        lockView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
    
    override func initialize() {
        setupUI()
        textView.text = content
        dateEditedLabel.text = dateLabelHeader
        
        if isLocked {
            setupLockView()
            lockView.backgroundColor = backgroundColor
            unlockMemoWithBioMetrics()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = backgroundColor
        textView.backgroundColor = backgroundColor
        dateEditedLabel.backgroundColor = backgroundColor
        self.navigationController?.navigationBar.setColors(background: backgroundColor!, text: .white)
        setupDynamicKeyboardColor()
    }
    
    func setupDynamicKeyboardColor() {
        if setting.darkModeIsEnable() == true {
            textView.keyboardAppearance = .dark
            textView.overrideUserInterfaceStyle = .dark
            
        } else {
            textView.keyboardAppearance = .default
            textView.overrideUserInterfaceStyle = .light
        }
    }
    
    func unlockMemoWithBioMetrics() {
        
        // using Local Authentication to lock or unlock current memo
        let context = LAContext()
        context.localizedFallbackTitle = "EnterPassword".localized
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "UnlockToViewMemo".localized
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
                
                DispatchQueue.main.async {
                    if success {
                        self.removeLockViewFromSuper()
                        
                    } else {
                        
                        guard let error = evaluateError else {
                            return
                        }
                        
                        switch error {
                        case LAError.userFallback:
                            self.handleEnterUnlockPassword()
                        case LAError.userCancel:
                            print("User cancel")
                        default:
                            print("Touch ID may not be configured")
                        }
                    }
                }
            }
            
        } else {
            handleEnterUnlockPassword()
        }
    }
    
    func handleEnterUnlockPassword() {
        
        let alert = EMAlertController(title: "ViewMemo".localized, message: "EnterPasswordToView".localized)
        alert.addTextField { (textField) in
            textField?.placeholder = "******"
            textField?.isSecureTextEntry = true
        }
        let cancel = EMAlertAction(title: "Cancel".localized, style: .cancel)
        let ok = EMAlertAction(title: "OK", style: .normal) {
            
            let inputUserPassword = alert.textFields.first?.text ?? ""
            let keychainPassword = self.keychain.string(forKey: Resource.Defaults.passwordToUseBiometric) ?? ""
            
            // if input password is matching with keychain password
            if inputUserPassword.elementsEqual(keychainPassword) == true {
                self.removeLockViewFromSuper()
                
            } else {
                ShowToast.toast(message: "PasswordIncorrect".localized, duration: 1.0)
            }
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func removeLockViewFromSuper() {
        UIView.animate(withDuration: 0.3, animations: {
            self.lockView.alpha = 0
            
        }) { _ in
            self.userUnlocked = true
            self.lockView.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRightBarButton()
        addKeyboardListener()
        textView.setupTextViewToolbar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeNotificationObserver()
        updateContent(index: index, newContent: textView.text)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isLocked == true && userUnlocked == false {
            self.lockView.removeFromSuperview()
        }
    }
    
    func addKeyboardListener() {
        
        self.addNotificationObserver(selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification)
        
        self.addNotificationObserver(selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
            
        } else {
            textView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardScreenEndFrame.size.height, right: 0.0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    func setupRightBarButton() {
        
        let hashTagBtn = UIBarButtonItem(image: Resource.Images.hashTagButton, style: .plain, target: self, action: #selector(hashTagChangeHandle))
        let infoBtn = UIBarButtonItem(image: Resource.Images.infoButton, style: .plain, target: self, action: #selector(viewMemoInfo))
        
        self.navigationItem.rightBarButtonItems = [hashTagBtn, infoBtn]
    }
    
    @objc func viewMemoInfo() {
        
        DeviceControl().feedbackOnPress()
        let contentCount = content.countWords()
        let createdInfo = String(format: "DateCreatedInfo".localized, dateCreated)
        let editedInfo = String(format: "DateEditedInfo".localized, dateEdited)
        let reminderInfo = String(format: "DateReminderInfo".localized, dateReminder)
        let charsCount = String(format: "CharactersCount".localized, content.count)
        let wordsCount = String(format: "WordsCount".localized, contentCount)
        
        var info: String = ""
        if isLocked {
            info += "\("MemoIsLocked".localized)\n"
        }
        info += "\(createdInfo)\n"
        if isEdited {
            info += "\(editedInfo)\n"
        }
        if isReminder {
            info += "\(reminderInfo)\n"
        }
        info += "\n\(charsCount)\n"
        info += "\(wordsCount)"
        
        let alert = EMAlertController(title: nil, message: "\(info)")
        
        let viewLockedMemoButton = EMAlertAction(title: "ViewMemo".localized, style: .normal) {
            self.unlockMemoWithBioMetrics()
        }
        let deleteReminderBtn = EMAlertAction(title: "DeleteReminder".localized, style: .normal) {
            self.deleteReminderHandle()
        }
        let done = EMAlertAction(title: "Done".localized, style: .cancel)
        
        alert.addAction(done)
        
        if isReminder {
            alert.addAction(deleteReminderBtn)
        }
        
        if isLocked == true && userUnlocked == false {
            alert.addAction(viewLockedMemoButton)
        }
        
        present(alert, animated: true, completion: nil)
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
        
        ShowToast.toast(message: "ReminderDeleted".localized, duration: 1.0)
    }
    
    @objc func hashTagChangeHandle() {
        
        if isLocked == true && userUnlocked == true || isLocked == false {
            
            DeviceControl().feedbackOnPress()
            let alert = EMAlertController(title: "#\(hashTag)", message: nil)
            alert.addTextField { (textField) in
                textField?.placeholder = "newHashTag"
                textField?.autocorrectionType = .yes
                textField?.autocapitalizationType = .none
                
                if defaults.bool(forKey: Resource.Defaults.useDarkMode) == true {
                    textField?.keyboardAppearance = .dark
                    
                } else {
                    textField?.keyboardAppearance = .default
                }
            }
            let cancel = EMAlertAction(title: "Cancel".localized, style: .cancel)
            let done = EMAlertAction(title: "Done".localized, style: .normal) {
                
                let text = alert.textFields.first?.text
                if text?.isNullOrWhiteSpace() ?? false {
                } else {
                    let newHashTag = FormatString().formatHashTag(text: text!)
                    self.updateHashTag(index: self.index, newHashTag: newHashTag)
                }
            }
            alert.addAction(done)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

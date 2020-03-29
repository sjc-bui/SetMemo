//
//  NewMemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import RealmSwift

class WriteMemoController: UIViewController, UITextViewDelegate {
    let writeMemoView = WriteMemoView()
    let item: MemoItem = MemoItem()
    var inputContent: String? = nil
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        writeMemoView.backgroundColor = .white
        setupPlaceholder()
        characterCount()
        setupDynamicKeyboardColor()
        addKeyboardListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.autoSave()
    }
    
    func setupNavigation() {
        let hashTagButton = UIBarButtonItem(image: Resource.Images.hashTagButton, style: .plain, target: self, action: #selector(setHashTag))
        self.navigationItem.rightBarButtonItem = hashTagButton
    }
    
    @objc func setHashTag() {
        let alert = UIAlertController(title: "#hashTag", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "hashTag"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Done".localized, style: .default, handler: { [weak alert] _ in
            let textField = alert?.textFields![0]
            let text = textField?.text
            
            if text?.isNullOrWhiteSpace() ?? false {
            } else {
                self.item.hashTag = FormatString().formatHashTag(text: text!)
            }
        }))
        
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
            let now = Date()
            item.content = writeMemoView.inputTextView.text
            item.dateCreated = now
            item.dateEdited = now
            item.isReminder = false
            
            RealmServices.shared.create(item)
            characterCount()
            writeMemoView.inputTextView.text = ""
        }
    }
    
    func setupView() {
        view = writeMemoView
        writeMemoView.inputTextView.frame = CGRect(x: 0, y: 0, width: writeMemoView.screenWidth, height: writeMemoView.screenHeight)
        writeMemoView.inputTextView.isScrollEnabled = false
        writeMemoView.inputTextView.delegate = self
        writeMemoView.inputTextView.isScrollEnabled = true
        writeMemoView.inputTextView.becomeFirstResponder()
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
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            writeMemoView.inputTextView.contentInset = .zero
        } else {
            writeMemoView.inputTextView.contentInset.bottom = keyboardScreenEndFrame.size.height + 68
        }
        
        writeMemoView.inputTextView.scrollIndicatorInsets = writeMemoView.inputTextView.contentInset
        
        let selectedRange = writeMemoView.inputTextView.selectedRange
        writeMemoView.inputTextView.scrollRangeToVisible(selectedRange)
    }
}

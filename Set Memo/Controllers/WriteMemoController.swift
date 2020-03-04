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
    var inputContent: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor(red: 0.1450980392, green: 0.4274509804, blue: 0.9019607843, alpha: 1)
        setupView()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        writeMemoView.backgroundColor = UIColor.orange
        setupPlaceholder()
        setupNavigationBar()
        characterCount()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.autoSave()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        characterCount()
    }
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func setupPlaceholder() {
        let placeholder = UserDefaults.standard.string(forKey: "writeNotePlaceholder") ?? "Write something..."
        writeMemoView.inputTextView.placeholder = placeholder
    }
    
    private func characterCount() {
        let textCount: Int = writeMemoView.inputTextView.text.count
        self.navigationItem.title = String(format: "%d", textCount)
    }
    
    @objc func autoSave() {
        if !writeMemoView.inputTextView.text.isNullOrWhiteSpace() {
            let item: MemoItem = MemoItem()
            item.content = writeMemoView.inputTextView.text
            item.created = Date()
            
            RealmServices.shared.create(item)
            characterCount()
            writeMemoView.inputTextView.text = ""
        }
    }
    
    func setupView() {
        view = writeMemoView
        
        // add tap gesture to view.
        let tap = UIGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
        
        writeMemoView.frame = CGRect(x: 0, y: 80, width: writeMemoView.screenWidth, height: writeMemoView.screenHeight / 4)
        writeMemoView.inputTextView.isScrollEnabled = false
        writeMemoView.inputTextView.tintColor = UIColor.white
        writeMemoView.inputTextView.delegate = self
        writeMemoView.inputTextView.isScrollEnabled = true
    }
    
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            writeMemoView.inputTextView.contentInset = .zero
            writeMemoView.inputTextView.frame = CGRect(x: 0, y: 80, width: view.bounds.width, height: writeMemoView.screenHeight / 4)
        } else {
            writeMemoView.inputTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height + 42, right: 0)
            writeMemoView.inputTextView.frame = CGRect(x: 0, y: 40, width: view.bounds.width, height: writeMemoView.screenHeight)
        }
        
        writeMemoView.inputTextView.scrollIndicatorInsets = writeMemoView.inputTextView.contentInset
        
        let selectedRange = writeMemoView.inputTextView.selectedRange
        writeMemoView.inputTextView.scrollRangeToVisible(selectedRange)
    }
    
    @objc func handleTap(_ sender: UIGestureRecognizer? = nil) {
        // tap to focus cursor in text view.
        writeMemoView.inputTextView.becomeFirstResponder()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

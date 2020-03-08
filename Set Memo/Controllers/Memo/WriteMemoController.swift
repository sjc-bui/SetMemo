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
        setupView()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        writeMemoView.backgroundColor = .white
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
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backToListView))
        let remindButton = UIBarButtonItem(image: UIImage(named: "alarm"), style: .plain, target: self, action: #selector(createRemind))
        self.navigationItem.leftBarButtonItem = remindButton
        self.navigationItem.rightBarButtonItem = backButton
    }
    
    @objc func createRemind() {
        DeviceControl().feedbackOnPress()
        print("picker")
    }
    
    @objc func backToListView() {
        DeviceControl().feedbackOnPress()
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupPlaceholder() {
        let placeholder = UserDefaults.standard.string(forKey: Defaults.writeNotePlaceholder) ?? ""
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
        
        writeMemoView.frame = CGRect(x: 0, y: 0, width: writeMemoView.screenWidth, height: writeMemoView.screenHeight)
        writeMemoView.inputTextView.isScrollEnabled = false
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
        } else {
            writeMemoView.inputTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height + 42, right: 0)
            writeMemoView.inputTextView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: writeMemoView.screenHeight)
        }
        
        writeMemoView.inputTextView.scrollIndicatorInsets = writeMemoView.inputTextView.contentInset
        
        let selectedRange = writeMemoView.inputTextView.selectedRange
        writeMemoView.inputTextView.scrollRangeToVisible(selectedRange)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // tap to focus cursor in text view.
        print("view tapping")
        writeMemoView.inputTextView.becomeFirstResponder()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let frame = CGRect(x: 0, y: 0, width: size.width, height: writeMemoView.screenHeight)
        writeMemoView.inputTextView.frame = frame
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

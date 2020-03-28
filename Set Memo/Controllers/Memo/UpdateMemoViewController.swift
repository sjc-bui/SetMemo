//
//  UpdateMemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/01.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import RealmSwift

class UpdateMemoViewController: BaseViewController, UITextViewDelegate {
    var memoId: String = ""
    var inputContent: String? = nil
    var textViewIsChanging: Bool = false
    let writeMemoView = WriteMemoView()
    
    override func initialize() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let realm = try! Realm()
        let memoItem = realm.objects(MemoItem.self).filter("id = %@", memoId).first
        setupView()
        writeMemoView.inputTextView.text = memoItem?.content
        setupNavigation(time: DatetimeUtil().convertDatetime(datetime: memoItem!.dateEdited))
        addKeyboardListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        updateMemoItem()
    }
    
    func addKeyboardListener() {
        self.navigationItem.rightBarButtonEnable(isEnabled: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        //let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
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
    
    func textViewDidChange(_ textView: UITextView) {
        textViewIsChanging = true
    }
    
    func setupNavigation(time: String) {
        self.navigationItem.title = time
        let hideKeyboardBtn = UIBarButtonItem(image: Resource.Images.keyboardButton, style: .plain, target: self, action: #selector(hideKeyboard))
        self.navigationItem.rightBarButtonItem = hideKeyboardBtn
    }
    
    @objc func hideKeyboard() {
        DeviceControl().feedbackOnPress()
        self.view.endEditing(true)
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
    
    @objc func updateMemoItem() {
        DeviceControl().feedbackOnPress()
        if textViewIsChanging {
            let realm = try! Realm()
            let item = realm.objects(MemoItem.self).filter("id = %@", memoId).first
            do {
                try realm.write {
                    item?.content = writeMemoView.inputTextView.text
                    item?.dateEdited = Date()
                }
            } catch {
                print(error)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

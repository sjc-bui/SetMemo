//
//  UpdateMemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/01.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import RealmSwift

class UpdateMemoViewController: UIViewController, UITextViewDelegate {
    var memoId: String = ""
    var inputContent: String? = nil
    var textViewIsChanging: Bool = false
    let writeMemoView = WriteMemoView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let realm = try! Realm()
        let memoItem = realm.objects(MemoItem.self).filter("id = %@", memoId).first
        setupView()
        writeMemoView.inputTextView.text = memoItem?.content
        setupNavigation(time: DatetimeUtil().convertDatetime(datetime: memoItem!.created))
    }
    
    func setupBackground() {
        writeMemoView.backgroundColor = .white
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textViewIsChanging = true
    }
    
    func setupNavigation(time: String) {
        self.navigationItem.title = time
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(updateMemoItem))
        let remindButton = UIBarButtonItem(image: UIImage(named: "alarm"), style: .plain, target: self, action: #selector(updateRemind))
        self.navigationItem.rightBarButtonItem = backButton
        self.navigationItem.leftBarButtonItem = remindButton
    }
    
    @objc func updateRemind() {
        DeviceControl().feedbackOnPress()
        print("update remind")
    }
    
    func setupView() {
        view = writeMemoView
        let textView = writeMemoView.inputTextView
        writeMemoView.inputTextView.frame = CGRect(x: 0, y: 0, width: writeMemoView.screenWidth, height: writeMemoView.screenHeight)
        textView.font = UIFont.systemFont(ofSize: CGFloat(UserDefaults.standard.float(forKey: Defaults.fontSize)))
        textView.placeholder = ""
        textView.alwaysBounceVertical = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.isPlaceholderScrollEnabled = true
        textView.delegate = self
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
    
    @objc func updateMemoItem() {
        DeviceControl().feedbackOnPress()
        if textViewIsChanging {
            let realm = try! Realm()
            let item = realm.objects(MemoItem.self).filter("id = %@", memoId).first
            do {
                try realm.write {
                    item?.content = writeMemoView.inputTextView.text
                    item?.created = Date()
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

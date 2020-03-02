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
    var textView: UITextView = UITextView()
    var textViewIsChanging: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupNavigation()
        setupEditor()
        
        let realm = try! Realm()
        let memoItem = realm.objects(MemoItem.self).filter("id = %@", memoId).first
        textView.text = memoItem?.content
    }
    
    func setupBackground() {
        let backgroundImage = UIImageView(frame: .zero)
        self.view.insertSubview(backgroundImage, at: 0)
        backgroundImage.pinImageView(to: view)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textViewIsChanging = true
    }
    
    func setupNavigation() {
        self.navigationItem.title = NSLocalizedString("Edit", comment: "")
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let updateButton = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(updateMemoItem))
        self.navigationItem.rightBarButtonItem = updateButton
    }
    
    @objc func updateMemoItem() {
        if textViewIsChanging {
            let realm = try! Realm()
            let item = realm.objects(MemoItem.self).filter("id = %@", memoId).first
            do {
                try realm.write {
                    item?.content = textView.text
                    item?.created = Date()
                }
                self.navigationController?.popViewController(animated: true)
            } catch {
                print(error)
            }
        }
    }
    
    // Configure editor view.
    func setupEditor() {
        textView = CustomTextView().textViewDraw()
        textView.delegate = self
        
        // Toolbar above keyboard
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: textView.frame.width, height: 33)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(hideKeyboard))
        toolBar.setItems([flexSpace, doneButton], animated: false)
        textView.inputAccessoryView = toolBar
        
        view.addSubview(textView)
        textView.pin(to: view)
    }
    
    // Click done button and keyboard disapper
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}

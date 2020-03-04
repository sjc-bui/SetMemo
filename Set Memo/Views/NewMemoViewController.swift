//
//  NewMemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import RealmSwift

class NewMemoViewController: UIViewController, UITextViewDelegate {
    var inputContent: String? = nil
    var textView: UITextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.1450980392, green: 0.4274509804, blue: 0.9019607843, alpha: 1)
        
        setupEditor()
        setNavbarButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.autoSave()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.navigationItem.title = String(format: "%d", textView.text.count)
    }
    
    func setNavbarButton() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    @objc func autoSave() {
        if !textView.text.isNullOrWhiteSpace() {
            let item: MemoItem = MemoItem()
            item.content = textView.text
            item.created = Date()
            
            RealmServices.shared.create(item)
            textView.text = ""
        }
    }
    
    // Configure editor view.
    func setupEditor() {
        textView = CustomTextView().textViewDraw()
        textView.delegate = self
        
        // Toolbar above keyboard
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: textView.frame.width, height: 34)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(hideKeyboard))
        toolBar.setItems([flexSpace, doneButton], animated: false)
        textView.inputAccessoryView = toolBar
        
        view.addSubview(textView)
        textView.pin(to: view)
        textView.becomeFirstResponder() // auto focus to textview when open.
    }
    
    // Click done button and keyboard disapper
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}

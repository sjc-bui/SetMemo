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
        let backgroundImage = UIImageView(frame: .zero)
        self.view.insertSubview(backgroundImage, at: 0)
        backgroundImage.pinImageView(to: view)
        
        setupEditor()
        setNavbarButton()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.navigationItem.title = String(format: "%d", textView.text.count)
    }
    
    func setNavbarButton() {
        let saveButton = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(saveMemo))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func saveMemo() {
        if !textView.text.isNullOrWhiteSpace() {
            let item: MemoItem = MemoItem()
            item.content = textView.text
            item.created = Date()
            
            RealmServices.shared.create(item)
            self.navigationController?.popViewController(animated: true)
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
        textView.becomeFirstResponder() // auto focus to textview when open.
    }
    
    // Click done button and keyboard disapper
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}

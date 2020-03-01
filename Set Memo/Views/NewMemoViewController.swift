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
    var textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // remove text from back button
        self.navigationItem.title = NSLocalizedString("New", comment: "")
        
        let backgroundImage = UIImageView(frame: .zero)
        self.view.insertSubview(backgroundImage, at: 0)
        backgroundImage.pinImageView(to: view)
        
        setupEditor()
        setNavbarButton()
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
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        textView = UITextView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor.white
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.autocapitalizationType = UITextAutocapitalizationType.none
        textView.keyboardType = UIKeyboardType.default
        textView.returnKeyType = UIReturnKeyType.default
        textView.dataDetectorTypes = UIDataDetectorTypes.all
        let range = NSMakeRange(textView.text.count - 1, 0)
        textView.scrollRangeToVisible(range)
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.setPadding()
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

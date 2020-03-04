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
        self.view.backgroundColor = UIColor(red: 0.07843137255, green: 0.7960784314, blue: 0.6274509804, alpha: 1)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textViewIsChanging = true
    }
    
    func setupNavigation() {
        self.navigationItem.title = NSLocalizedString("Edit", comment: "")
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let closeButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(updateMemoItem))
        let emptyBtn = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = closeButton
        self.navigationItem.leftBarButtonItem = emptyBtn
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
            } catch {
                print(error)
            }
        }
        self.navigationController?.popViewController(animated: true)
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

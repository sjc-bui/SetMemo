//
//  TextViewEditor.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/10.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class TextViewEditor: UIView {
    
    var textView: UITextView = {
        let tv = UITextView()
        tv.tintColor = UIColor.colorFromString(from: UserDefaults.standard.integer(forKey: Resource.Defaults.defaultTintColor))
        tv.isEditable = true
        tv.isScrollEnabled = true
        tv.text = ""
        tv.textColor = UIColor(named: "mainTextColor")
        tv.isUserInteractionEnabled = true
        tv.alwaysBounceVertical = true
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont(name: UserDefaults.standard.string(forKey: Resource.Defaults.defaultFontStyle)!, size: CGFloat(UserDefaults.standard.integer(forKey: Resource.Defaults.defaultTextViewFontSize)))
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(textView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

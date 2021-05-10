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
        tv.tintColor = UIColor.white
        tv.isEditable = true
        tv.isScrollEnabled = true
        tv.text = ""
        tv.textColor = UIColor.white
        tv.isUserInteractionEnabled = true
        tv.alwaysBounceVertical = true
        tv.textContainerInset = UIEdgeInsets(top: 5, left: 20, bottom: 10, right: 20)
        tv.font = UIFont.setCustomFont(style: UserDefaults.standard.string(forKey: Resource.Defaults.defaultFontStyle)!, fontSize: CGFloat(UserDefaults.standard.integer(forKey: Resource.Defaults.defaultTextViewFontSize)))
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

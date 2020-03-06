//
//  WriteMemoView.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/04.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import MultilineTextField

class WriteMemoView: UIView {
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    lazy var inputTextView: MultilineTextField = {
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        let textField = MultilineTextField(frame: frame)
        textField.backgroundColor = UIColor.clear
        textField.textColor = UIColor.white
        textField.placeholderColor = UIColor.white
        textField.font = UIFont.boldSystemFont(ofSize: 32)
        textField.isEditable = true
        textField.textContainerInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        textField.leftViewOrigin = CGPoint(x: 8, y: 8)
        
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(inputTextView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

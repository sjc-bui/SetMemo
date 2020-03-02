//
//  CustomTextView.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/02.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class CustomTextView {
    func textViewDraw() -> UITextView {
        let textView: UITextView = UITextView()
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        textView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = UIColor.white
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.autocapitalizationType = UITextAutocapitalizationType.none
        textView.keyboardType = UIKeyboardType.default
        textView.returnKeyType = UIReturnKeyType.default
        textView.dataDetectorTypes = UIDataDetectorTypes.all
        let range = NSMakeRange(textView.text.count - 1, 0)
        textView.scrollRangeToVisible(range)
        textView.isScrollEnabled = true
        textView.setPadding()
        textView.backgroundColor = .clear
        
        return textView
    }
}

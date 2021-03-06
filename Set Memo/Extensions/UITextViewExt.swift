//
//  UITextViewExt.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/29.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UITextView {
    
    func setPadding() {
        self.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 6, right: 10)
    }
    
    func setupTextViewToolbar() {
        
        let items = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 30))
        
        let flexibleSpace = UIBarButtonItem.flexibleSpace
        let moveLeft = UIBarButtonItem(image: Resource.Images.moveLeftButton, style: .plain, target: self, action: #selector(moveCursorToLeft))
        let moveRight = UIBarButtonItem(image: Resource.Images.moveRightButton, style: .plain, target: self, action: #selector(moveCursorToRight))
        let calendarBadge = UIBarButtonItem(image: Resource.Images.addCalendarButton, style: .plain, target: self, action: #selector(addToday))
        let sharpSign = UIBarButtonItem(image: Resource.Images.sharpButton, style: .plain, target: self, action: #selector(addSharpSign))
        let moveToBegin = UIBarButtonItem(image: Resource.Images.moveToBeginButton, style: .plain, target: self, action: #selector(moveBegin))
        let moveToEnd = UIBarButtonItem(image: Resource.Images.moveToEndButton, style: .plain, target: self, action: #selector(moveEnd))
        let addTabSpace = UIBarButtonItem(image: Resource.Images.addTabSpace, style: .plain, target: self, action: #selector(addTab))
        let hideKeyboard = UIBarButtonItem(image: Resource.Images.keyboardButton, style: .plain, target: self, action: #selector(hideKeyboad))
        
        items.setItems([
            addTabSpace, flexibleSpace,
            moveLeft, flexibleSpace,
            moveRight, flexibleSpace,
            moveToBegin, flexibleSpace,
            moveToEnd, flexibleSpace,
            sharpSign, flexibleSpace,
            calendarBadge, flexibleSpace,
            hideKeyboard
        ], animated: true)
        
        items.barStyle = .default
        items.tintColor = Colors.shared.defaultTintColor
        items.isUserInteractionEnabled = true
        items.sizeToFit()
        
        self.inputAccessoryView = items
    }
    
    @objc fileprivate func hideKeyboad() {
        self.endEditing(true)
    }
    
    @objc fileprivate func moveCursorToLeft() {
        if let selectedRange = self.selectedTextRange {
            if let newPosition = self.position(from: selectedRange.start, offset: -1) {
                self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    @objc fileprivate func moveCursorToRight() {
        if let selectedRange = self.selectedTextRange {
            if let newPosition = self.position(from: selectedRange.start, offset: 1) {
                self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    @objc fileprivate func addSharpSign() {
        let sharpSign = "#\u{00A0}"
        self.insertText(sharpSign)
    }
    
    @objc fileprivate func moveBegin() {
        let begin = self.beginningOfDocument
        self.selectedTextRange = self.textRange(from: begin, to: begin)
    }
    
    @objc fileprivate func moveEnd() {
        let end = self.endOfDocument
        self.selectedTextRange = self.textRange(from: end, to: end)
    }
    
    @objc fileprivate func addTab() {
        self.insertText("\t")
    }
    
    @objc fileprivate func addToday() {
        let now = Date()
        let dateTimeFullString = now.string(with: "DatetimeFormat".localized)
        self.insertText("\(dateTimeFullString)\u{00A0}")
    }
}

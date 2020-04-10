//
//  UIViewExt.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/29.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UIView {
    func pin(to superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

extension UIViewController {
    
    func getCurrenDateTimme() {
        
        let selectCurrentDateSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let now = Date()
        var getString: String = ""
        
        let dateTimeFullString = now.string(with: "DatetimeFormat".localized)
        let timeLongString = now.string(with: "DateMonthYear".localized)
        let timeShortString = now.string(with: "DateTimeShort".localized)
        let hourMinuteString = now.string(with: "HourAndMinute".localized)
        
        let fullStyle = UIAlertAction(title: "\(dateTimeFullString)", style: .default) { (action) in
            getString = dateTimeFullString
        }
        let timeLong = UIAlertAction(title: "\(timeLongString)", style: .default) { (action) in
            getString = timeLongString
        }
        let timeShort = UIAlertAction(title: "\(timeShortString)", style: .default) { (action) in
            getString = timeShortString
        }
        let hourMinute = UIAlertAction(title: "\(hourMinuteString)", style: .default) { (action) in
            getString = hourMinuteString
        }
        let cancelButton = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        selectCurrentDateSheet.view.tintColor = UIColor.colorFromString(from: UserDefaults.standard.integer(forKey: Resource.Defaults.defaultTintColor))
        selectCurrentDateSheet.addAction(cancelButton)
        selectCurrentDateSheet.addAction(fullStyle)
        selectCurrentDateSheet.addAction(timeLong)
        selectCurrentDateSheet.addAction(timeShort)
        selectCurrentDateSheet.addAction(hourMinute)
        
        selectCurrentDateSheet.pruneNegativeWidthConstraints()
        selectCurrentDateSheet.safePosition()
        
        self.present(selectCurrentDateSheet, animated: true, completion: nil)
    }
}

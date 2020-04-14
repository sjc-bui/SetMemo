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

//        let now = Date()
//        var getString: String = ""
//
//        let dateTimeFullString = now.string(with: "DatetimeFormat".localized)
//        let timeLongString = now.string(with: "DateMonthYear".localized)
//        let timeShortString = now.string(with: "DateTimeShort".localized)
//        let hourMinuteString = now.string(with: "HourAndMinute".localized)
    
    
    func showAlert(title: String?, message: String?, alertStyle: UIAlertController.Style, actionTitles: [String], actionStyles: [UIAlertAction.Style], actions: [((UIAlertAction) -> Void)]) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        
        for (index, actionTitle) in actionTitles.enumerated() {
            let action = UIAlertAction(title: actionTitle, style: actionStyles[index], handler: actions[index])
            alert.addAction(action)
        }
        
        alert.view.tintColor = UIColor.colorFromString(from: UserDefaults.standard.integer(forKey: Resource.Defaults.defaultTintColor))
        
        alert.pruneNegativeWidthConstraints()
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.any]
        }
        
        self.present(alert, animated: true)
    }
}

//
//  UIViewControllerExt.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UIViewController {

//        let now = Date()
//        var getString: String = ""
//
//        let dateTimeFullString = now.string(with: "DatetimeFormat".localized)
//        let timeLongString = now.string(with: "DateMonthYear".localized)
//        let timeShortString = now.string(with: "DateTimeShort".localized)
//        let hourMinuteString = now.string(with: "HourAndMinute".localized)
    
    func wc_doneBarButton(title: String = "完成") -> UIButton {
        let doneButton = UIButton(type: .system)
        doneButton.layer.cornerRadius = 5
        doneButton.layer.masksToBounds = true
        doneButton.frame.size = CGSize(width: 56, height: 30)
        doneButton.backgroundColor = Colors.Brand
        doneButton.setBackgroundImage(UIImage(color: Colors.Brand_120), for: .disabled)
        doneButton.setBackgroundImage(UIImage(color: Colors.Brand), for: .normal)
        doneButton.setTitle(title, for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return doneButton
    }
    
    func showAlert(title: String?, message: String?, alertStyle: UIAlertController.Style, actionTitles: [String], actionStyles: [UIAlertAction.Style], actions: [((UIAlertAction) -> Void)]) {
        
        let defaults = UserDefaults.standard
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        
        for (index, actionTitle) in actionTitles.enumerated() {
            let action = UIAlertAction(title: actionTitle, style: actionStyles[index], handler: actions[index])
            alert.addAction(action)
        }
        
        alert.view.tintColor = Colors.shared.defaultTintColor
        
        alert.pruneNegativeWidthConstraints()
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.any]
        }
        
        if defaults.bool(forKey: Resource.Defaults.useDarkMode) == true {
            alert.overrideUserInterfaceStyle = .dark
            
        } else {
            alert.overrideUserInterfaceStyle = .light
        }
        
        self.present(alert, animated: true)
    }
    
    func addNotificationObserver(selector: Selector, name: Notification.Name) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
    
    /// Unassign as listener from all notification
    func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func push(viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func pop(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
}

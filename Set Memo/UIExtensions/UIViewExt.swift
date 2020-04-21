//
//  UIViewExt.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/29.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0)}
    }
    
    func pin(to superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func addTapGesture(target: AnyObject, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = 1
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
    }
    
    func addLongPress(target: AnyObject, action: Selector) {
        let longPress = UILongPressGestureRecognizer(target: target, action: action)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(longPress)
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
        
        alert.view.tintColor = Colors.shared.defaultTintColor
        
        alert.pruneNegativeWidthConstraints()
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.any]
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

extension CALayer {
    
    func addShadow(color: UIColor) {
        self.shadowOffset = .zero
        self.shadowOpacity = 0.3
        self.shadowRadius = 5
        self.shadowColor = color.cgColor
        self.masksToBounds = false
    }
}

extension UICollectionViewCell {
    
    func setCellStyle(radius: CGFloat, background: UIColor) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.backgroundColor = background
        self.layer.addShadow(color: UIColor.darkGray)
    }
}

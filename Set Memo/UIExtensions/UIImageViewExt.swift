//
//  UIImageViewExt.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/01.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension UIImageView {
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }

        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }

        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0

        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    func pinImageView(to view: UIView) {
        image = UIImage(named: "greenChalkboard")
        contentMode = .scaleToFill
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor,constant:0),
            trailingAnchor.constraint(equalTo: view.trailingAnchor,constant:0),
            topAnchor.constraint(equalTo: view.topAnchor,constant:0),
            bottomAnchor.constraint(equalTo: view.bottomAnchor,constant:0)
        ])
    }
}

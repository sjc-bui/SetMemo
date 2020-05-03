//
//  CALayerExt.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension CALayer {
    
    func roundCorner(radius: CGFloat) {
        // Smooth round corners
        let roundPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius)
        let maskLayer = CAShapeLayer()
        maskLayer.path = roundPath.cgPath
        self.mask = maskLayer
    }
    
    func addShadow(color: UIColor) {
        self.shadowOffset = .zero
        self.shadowOpacity = 0.2
        self.shadowRadius = 10
        self.shadowColor = color.cgColor
        self.masksToBounds = false
    }
    
    func shapeLayer() -> CAShapeLayer? {
        guard let sublayers = sublayers else {
            return nil
        }
        for layer in sublayers {
            if let shape = layer as? CAShapeLayer {
                return shape
            }
            return layer.shapeLayer()
        }
        return nil
    }
}

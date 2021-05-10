//
//  UIImageExt.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import SVGKit

extension UIImage {
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
    
    static func SVGImage(named: String, fillColor: UIColor? = nil) -> UIImage? {
        
        if let url = Bundle.main.url(forResource: named, withExtension: "svg") {
            let image = SVGKImage(contentsOf: url)
            if let color = fillColor {
                image?.fill(color: color)
            }
            return image?.uiImage.withRenderingMode(.alwaysOriginal)
        }
        return nil
    }
}

extension SVGKImage {
    
    func fill(color: UIColor) {
        if let sharpLayer = caLayerTree.shapeLayer() {
            sharpLayer.fillColor = color.cgColor
        }
    }
}

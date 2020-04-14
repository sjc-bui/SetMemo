//
//  SPAlert.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/09.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import SPAlert

class SPAlert {
    
    func done(title: String, message: String?, haptic: Bool, duration: TimeInterval) {
        let alertView = SPAlertView(title: title, message: message, preset: .done)
        alertView.duration = duration
        alertView.present()
    }
    
    func customImage(title: String?, message: String?, image: UIImage?) {
        let spalert = SPAlertView(title: title!, message: message, image: image!)
        spalert.duration = 0.5
        spalert.present()
    }
}

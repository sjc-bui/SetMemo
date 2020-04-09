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
}

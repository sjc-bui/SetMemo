//
//  BundleExt.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/16.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension Bundle {
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        return version
    }
}

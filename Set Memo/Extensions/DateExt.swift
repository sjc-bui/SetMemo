//
//  DateExt.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/07.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension Date {
    
    func string(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: self)
    }
}

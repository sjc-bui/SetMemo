//
//  DatetimeUtil.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/02.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class DatetimeUtil {
    
    func convertDatetime(date: Double) -> String {
        let dateEdit = Date(timeIntervalSinceReferenceDate: date)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = .current
        
        let dateString = dateFormatter.string(from: dateEdit)
        return dateString
    }
}

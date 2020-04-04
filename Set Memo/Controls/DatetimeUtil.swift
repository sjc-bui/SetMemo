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
        
        dateFormatter.dateFormat = "DatetimeFormat".localized
        dateFormatter.timeZone = .current
        
        let dateString = dateFormatter.string(from: dateEdit)
        return dateString
    }
    
    func calculateDate() -> String {
        return "Today"
    }
}

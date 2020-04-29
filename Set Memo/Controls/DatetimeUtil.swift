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
    
    func timeAgo(at date: Double) -> String? {
        
        let current = Date().timeIntervalSinceReferenceDate
        let minuteAgo = Int(((current - date) / 60))
        
        if minuteAgo < 1 {
            return "Now".localized
            
        } else if minuteAgo >= 1 && minuteAgo < 60 {
            return String(format: "MinutesAgo".localized, minuteAgo)
            
        } else if minuteAgo >= 60 && minuteAgo < 1440 {
            return String(format: "HoursAgo".localized, (minuteAgo / 60))
            
        } else if minuteAgo >= 1440 && minuteAgo < 10080 {
            return String(format: "DaysAgo".localized, (minuteAgo / (24 * 60)))
        }
        
        return DatetimeUtil().convertDatetime(date: date)
    }
}

//
//  DatetimeUtil.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/02.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class DatetimeUtil {
    func convertDatetime(datetime: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = NSLocalizedString("DatetimeFormat", comment: "")
        let dateString = dateFormatter.string(from: datetime)
        return dateString
    }
}

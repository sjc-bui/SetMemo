//
//  DatePickerCell.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/12.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class DatePickerCell: UITableViewCell {
    
    let datePicker = UIDatePicker()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        datePicker.timeZone = NSTimeZone.local
        datePicker.datePickerMode = .time
        contentView.addSubview(datePicker)
        
        datePicker.anchor(top: contentView.topAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

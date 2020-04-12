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
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.timeZone = NSTimeZone.local
        datePicker.datePickerMode = .time
        contentView.addSubview(datePicker)
        
        datePicker.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

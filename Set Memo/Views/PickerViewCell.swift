//
//  PickerViewCell.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/09.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class PickerViewCell: UITableViewCell {
    
    let pickerView = UIPickerView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pickerView)
        
        pickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        pickerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        pickerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

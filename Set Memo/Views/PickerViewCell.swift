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
        
        contentView.addSubview(pickerView)
        
        pickerView.anchor(top: contentView.topAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

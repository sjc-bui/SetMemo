//
//  TextFieldCell.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/12.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {
    
    let textField = UITextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tintColor = .deepOrange
        textField.placeholder = "custom content"
        contentView.addSubview(textField)
        
        textField.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

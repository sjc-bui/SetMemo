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
        
        textField.tintColor = .deepOrange
        textField.placeholder = "Content"
        
        contentView.addSubview(textField)
        textField.anchor(top: contentView.topAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

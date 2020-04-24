//
//  ButtonCell.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/24.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {
    
    let btn = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        btn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(btn)
        btn.isUserInteractionEnabled = true
        
        btn.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        btn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        btn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        btn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

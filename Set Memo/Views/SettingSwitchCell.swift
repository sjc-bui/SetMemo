//
//  SettingSwitchCell.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/07.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class SettingSwitchCell: UITableViewCell {
    let detailText = UILabel()
    let switchButton = UISwitch()
    let descriptionText = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(detailText)
        contentView.addSubview(switchButton)
        contentView.addSubview(descriptionText)
        descriptionText.textColor = UIColor.secondaryLabel
        
        detailText.translatesAutoresizingMaskIntoConstraints = false
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        switchButton.onTintColor = Colors.shared.accentColor
        
        detailText.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        detailText.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -10).isActive = true
        detailText.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -10).isActive = true
        
        descriptionText.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        descriptionText.leftAnchor.constraint(equalTo: contentView.rightAnchor, constant: -118).isActive = true
        descriptionText.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -10).isActive = true
        descriptionText.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -10).isActive = true
        
        switchButton.leftAnchor.constraint(equalTo: contentView.rightAnchor, constant: -64).isActive = true
        switchButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        switchButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        switchButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    override func prepareForReuse() {
        switchButton.removeTarget(nil, action: nil, for: .allEvents)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

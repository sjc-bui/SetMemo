//
//  MemoViewCell.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/27.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class MemoViewCell: UITableViewCell {
    
    let iconType = UIImageView()
    let content = UILabel()
    let dateCreated = UILabel()
    let dateEdited = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        iconType.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        dateCreated.translatesAutoresizingMaskIntoConstraints = false
        dateEdited.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(content)
        contentView.addSubview(dateCreated)
        contentView.addSubview(dateEdited)
        contentView.addSubview(iconType)
        
        let views = [
            "content" : content,
            "dateEdited" : dateEdited,
            "iconType" : iconType,
            ]
        
        var allConstraints: [NSLayoutConstraint] = []
        
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[content]-[dateEdited]-|", options: [], metrics: nil, views: views)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[dateEdited]-|", options: [], metrics: nil, views: views)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[content]-|", options: [], metrics: nil, views: views)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[dateEdited]-|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

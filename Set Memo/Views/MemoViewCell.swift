//
//  MemoViewCell.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/27.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class MemoViewCell: UITableViewCell {
    
    var content: UILabel = {
        let c = UILabel()
        c.numberOfLines = 1
        c.text = "content"
        c.textColor = UIColor(named: "mainTextColor")
        c.textDropShadow()
        return c
    }()
    
    var hashTag: UILabel = {
        let h = UILabel()
        h.numberOfLines = 1
        h.text = "hashTag"
        h.textColor = Colors.shared.subColor
        h.textDropShadow()
        h.textAlignment = NSTextAlignment.right
        return h
    }()
    
    var dateEdited: UILabel = {
        let d = UILabel()
        d.numberOfLines = 1
        d.text = "24/01/2019"
        d.textColor = Colors.shared.subColor
        d.textDropShadow()
        return d
    }()
    
    var reminderIsSetIcon: UIImageView = {
        let r = UIImageView()
        r.image = Resource.Images.smallBellButton
        r.tintColor = Colors.shared.reminderBtn
        r.isHidden = true
        return r
    }()
    
    var importantIcon: UIImageView = {
        let i = UIImageView()
        i.image = Resource.Images.smallStarFillButton
        i.tintColor = Colors.shared.importantBtn
        i.isHidden = true
        return i
    }()
    
    fileprivate lazy var horizontalStackView: UIStackView = {
        let s = UIStackView(arrangedSubviews: [importantIcon, dateEdited, hashTag, reminderIsSetIcon])
        s.axis = .horizontal
        s.alignment = .leading
        s.spacing = 6
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    fileprivate lazy var verticalStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [content, horizontalStackView])
        v.axis = .vertical
        v.spacing = 3
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(verticalStackView)
        
        reminderIsSetIcon.widthAnchor.constraint(equalToConstant: Dimension.shared.iconSize).isActive = true
        reminderIsSetIcon.heightAnchor.constraint(equalToConstant: Dimension.shared.iconSize).isActive = true
        importantIcon.widthAnchor.constraint(equalToConstant: Dimension.shared.iconSize).isActive = true
        importantIcon.heightAnchor.constraint(equalToConstant: Dimension.shared.iconSize).isActive = true
        
        verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

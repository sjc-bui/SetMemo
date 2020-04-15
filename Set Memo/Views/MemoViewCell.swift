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
        c.textColor = .white
        c.textDropShadow()
        return c
    }()
    
    var hashTag: UILabel = {
        let h = UILabel()
        h.numberOfLines = 1
        h.text = "hashTag"
        h.textColor = .lightText
        h.textDropShadow()
        h.textAlignment = NSTextAlignment.right
        return h
    }()
    
    var dateEdited: UILabel = {
        let d = UILabel()
        d.numberOfLines = 1
        d.text = "24/01/2019"
        d.textColor = .lightText
        d.textDropShadow()
        return d
    }()
    
    var reminderIsSetIcon: UIImageView = {
        let r = UIImageView()
        r.image = Resource.Images.smallBellButton
        r.tintColor = .white
        r.contentMode = .scaleAspectFill
        r.isHidden = true
        return r
    }()
    
    var lockIcon: UIImageView = {
        let i = UIImageView()
        i.image = Resource.Images.smallLockButton
        i.contentMode = .scaleAspectFill
        i.tintColor = .white
        i.isHidden = true
        return i
    }()
    
    fileprivate lazy var dateAndHashtagStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [dateEdited, hashTag])
        s.axis = .horizontal
        s.alignment = .leading
        s.spacing = 6
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    fileprivate lazy var middleCellStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [content, dateAndHashtagStack])
        v.axis = .vertical
        v.spacing = 3
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    fileprivate lazy var groupStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [lockIcon, middleCellStack, reminderIsSetIcon])
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 6
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(groupStack)
        
        reminderIsSetIcon.widthAnchor.constraint(equalToConstant: Dimension.shared.iconSize).isActive = true
        reminderIsSetIcon.heightAnchor.constraint(equalToConstant: Dimension.shared.iconSize).isActive = true
        
        lockIcon.widthAnchor.constraint(equalToConstant: Dimension.shared.iconSize).isActive = true
        lockIcon.heightAnchor.constraint(equalToConstant: Dimension.shared.iconSize).isActive = true
        
        groupStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        groupStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        groupStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13).isActive = true
        groupStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

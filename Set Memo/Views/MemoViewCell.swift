//
//  MemoViewCell.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/27.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class MemoViewCell: UICollectionViewCell {
    
    var content: UILabel = {
        let c = UILabel()
        c.numberOfLines = 2
        c.text = "content"
        c.textColor = UIColor.primaryText
        c.textDropShadow()
        return c
    }()
    
    var hashTag: UILabel = {
        let h = UILabel()
        h.numberOfLines = 1
        h.text = "hashTag"
        h.textColor = UIColor.secondaryText
        h.textDropShadow()
        return h
    }()
    
    var dateEdited: UILabel = {
        let d = UILabel()
        d.numberOfLines = 1
        d.text = "24/01/2019"
        d.textColor = UIColor.secondaryText
        d.textDropShadow()
        return d
    }()
    
    var reminderIsSetIcon: UIImageView = {
        let r = UIImageView()
        r.image = Resource.Images.smallAlarmIcon
        r.contentMode = .scaleAspectFill
        r.isHidden = true
        return r
    }()
    
    var lockIcon: UIImageView = {
        let i = UIImageView()
        i.image = UIImage.SVGImage(named: "icons_outlined_lock", fillColor: UIColor.white)
        i.contentMode = .scaleAspectFill
        i.tintColor = .white
        i.isHidden = true
        return i
    }()
    
    var moreIcon: UIImageView = {
        let m = UIImageView()
        m.image = UIImage.SVGImage(named: "icons_filled_more", fillColor: UIColor.white)
        m.contentMode = .scaleAspectFill
        m.tintColor = .white
        m.isHidden = false
        m.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        m.layer.cornerRadius = 12
        m.clipsToBounds = true
        return m
    }()
    
    fileprivate lazy var lockAndReminderIcon: UIStackView = {
        let s = UIStackView(arrangedSubviews: [moreIcon, lockIcon, reminderIsSetIcon])
        s.axis = .vertical
        s.alignment = .trailing
        s.spacing = 5
        return s
    }()
    
    fileprivate lazy var middleCellStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [content, dateEdited, hashTag])
        v.axis = .vertical
        v.alignment = .fill
        v.spacing = 2
        return v
    }()
    
    fileprivate lazy var groupStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [middleCellStack, lockAndReminderIcon])
        s.axis = .horizontal
        s.alignment = .leading
        s.spacing = 3
        return s
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }
    
    func setupContentView() {
        
        contentView.addSubview(groupStack)
        
        moreIcon.setSize(size: CGSize(width: Dimension.shared.iconSize, height: Dimension.shared.iconSize))
        
        reminderIsSetIcon.setSize(size: CGSize(width: Dimension.shared.iconSize, height: Dimension.shared.iconSize))
        
        lockIcon.setSize(size: CGSize(width: Dimension.shared.iconSize, height: Dimension.shared.iconSize))
        
        groupStack.anchor(top: contentView.topAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor, padding: UIEdgeInsets(top: 12, left: 12, bottom: -10, right: -12), size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  PremiumViewCell.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/05/03.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class Features {
    
    var feature: String?
    var type: FeatureType?
    
    init(feature: String, type: FeatureType) {
        self.feature = feature
        self.type = type
    }
}

enum FeatureType {
    case basic
    case premium
}

class PremiumViewCell: UITableViewCell {
    
    var features: UILabel = {
        let f = UILabel()
        f.numberOfLines = 1
        f.text = "feature"
        f.textAlignment = .left
        f.font = UIFont.systemFont(ofSize: 16)
        return f
    }()
    
    var yes: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "yes"
        label.textColor = UIColor.systemGreen
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    lazy var options: UIStackView = {
        let s = UIStackView(arrangedSubviews: [yes])
        s.axis = .horizontal
        s.alignment = .trailing
        s.spacing = 10
        return s
    }()
    
    lazy var cell: UIStackView = {
        let v = UIStackView(arrangedSubviews: [features, options])
        v.axis = .horizontal
        v.alignment = .center
        v.spacing = 10
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(cell)
        cell.anchor(top: contentView.topAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

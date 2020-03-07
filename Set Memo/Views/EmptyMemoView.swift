//
//  EmptyMemoView.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/05.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class EmptyMemoView: UIView {
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.textColor = Colors.primaryText
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 1
        label.text = NSLocalizedString("EmptyLabel", comment: "")
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.textColor = Colors.darkgrayColor
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 1
        label.text = NSLocalizedString("EmptyDescription", comment: "")
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stackView.frame = bounds
    }
    
    lazy var containerView: UIView = {
        let containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            stackView.widthAnchor.constraint(equalTo: widthAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        frame = superview?.bounds ?? .zero
    }
}

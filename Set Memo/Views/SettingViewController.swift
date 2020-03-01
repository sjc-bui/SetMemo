//
//  SettingViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Setting(1)"
        let backgroundImage = UIImageView(frame: .zero)
        self.view.insertSubview(backgroundImage, at: 0)
        backgroundImage.pinImageView(to: view)
    }
}

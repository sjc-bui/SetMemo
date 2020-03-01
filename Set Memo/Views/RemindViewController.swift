//
//  TodoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class RemindViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Remind(8)"
        let backgroundImage = UIImageView(frame: .zero)
        self.view.insertSubview(backgroundImage, at: 0)
        backgroundImage.pinImageView(to: view)
    }
}

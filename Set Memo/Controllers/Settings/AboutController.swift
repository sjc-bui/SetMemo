//
//  AboutController.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/05.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class AboutController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .white
        self.navigationItem.title = NSLocalizedString("About", comment: "")
    }
}

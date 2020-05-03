//
//  PremiumViewController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/05/03.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class PremiumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let sections: Array = [""]
    fileprivate let cellID = "cellID"
    let themes = Themes()
    let theme = ThemesViewController()
    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    let upgradeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(String(format: "Upgrade".localized, "Set Memo"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = Colors.shared.defaultTintColor
        btn.isUserInteractionEnabled = true
        btn.layer.cornerRadius = 12
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(upgrade), for: .touchUpInside)
        return btn
    }()
    
    let restorePurchase : UIButton = {
        let btn = UIButton()
        btn.setTitle("RestorePurchase".localized, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.setTitleColor(UIColor.systemBlue, for: .normal)
        btn.isUserInteractionEnabled = true
        btn.addTarget(self, action: #selector(restore), for: .touchUpInside)
        return btn
    }()
    
    @objc func upgrade() {
        print("upgrade")
    }
    
    @objc func restore() {
        print("restore")
    }
    
    let listFeatures: Array = [
        Features(feature: "Custom app icon", type: FeatureType.basic),
        Features(feature: "Share memo", type: FeatureType.basic),
        Features(feature: "Custom font size & style", type: FeatureType.basic),
        Features(feature: "Set remind every day", type: FeatureType.basic),
        Features(feature: "Use biometrics", type: FeatureType.premium),
        Features(feature: "Dark theme", type: FeatureType.premium),
        Features(feature: "Tint color", type: FeatureType.premium),
        Features(feature: "Set remind for memo", type: FeatureType.premium),
        Features(feature: "Lock memo", type: FeatureType.premium)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.navigationItem.title = "BuyPremium".localized
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDynamicElements()
    }
    
    func setupView() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        upgradeButton.translatesAutoresizingMaskIntoConstraints = false
        restorePurchase.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        self.view.addSubview(upgradeButton)
        self.view.addSubview(restorePurchase)
        
        var buttonWidth: CGFloat?
        if UIDevice.current.userInterfaceIdiom == .pad {
            buttonWidth = 350
            
        } else {
            buttonWidth = view.frame.size.width - 36
        }
        
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: upgradeButton.topAnchor, constant: -20).isActive = true
        
        upgradeButton.bottomAnchor.constraint(equalTo: restorePurchase.topAnchor, constant: -5).isActive = true
        upgradeButton.widthAnchor.constraint(equalToConstant: buttonWidth!).isActive = true
        upgradeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        upgradeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        restorePurchase.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        restorePurchase.widthAnchor.constraint(equalToConstant: buttonWidth!).isActive = true
        restorePurchase.heightAnchor.constraint(equalToConstant: 44).isActive = true
        restorePurchase.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        tableView.register(PremiumViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    func setupDynamicElements() {
        
        if theme.darkModeEnabled() == false {
            themes.setupDefaultTheme()
            setupDefaultPersistentNavigationBar()
            
            view.backgroundColor = InterfaceColors.secondaryBackgroundColor
            tableView.backgroundColor = InterfaceColors.secondaryBackgroundColor
            
        } else {
            themes.setupPureDarkTheme()
            setupDarkPersistentNavigationBar()
            
            view.backgroundColor = InterfaceColors.secondaryBackgroundColor
            tableView.backgroundColor = InterfaceColors.secondaryBackgroundColor
        }
    }
    
    func setupDefaultPersistentNavigationBar() {
        navigationController?.navigationBar.backgroundColor = InterfaceColors.secondaryBackgroundColor
        navigationController?.navigationBar.barTintColor = InterfaceColors.secondaryBackgroundColor
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setupDarkPersistentNavigationBar() {
        navigationController?.navigationBar.backgroundColor = InterfaceColors.secondaryBackgroundColor
        navigationController?.navigationBar.barTintColor = InterfaceColors.secondaryBackgroundColor
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listFeatures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PremiumViewCell
        cell.features.text = listFeatures[indexPath.row].feature
        
        if theme.darkModeEnabled() == true {
            cell.features.textColor = .white
            
        } else {
            cell.features.textColor = .black
        }
        
        cell.yes.text = "Include".localized
        
        switch listFeatures[indexPath.row].type {
        case .basic:
            cell.yes.textColor = .systemGreen
            
        case .premium:
            cell.yes.textColor = .amber
            
        default:
            print("color is not set")
        }
        
        cell.selectionStyle = .none
        setupDynamicCells(cell: cell, arrow: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Feature in Basic and Premium"
    }
    
    func setupDynamicCells(cell: UITableViewCell, arrow: Bool) {
        cell.backgroundColor = UIColor.white
        cell.backgroundColor = InterfaceColors.cellColor
        
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.textColor = InterfaceColors.fontColor
        
        if arrow == true {
            cell.accessoryView = UIImageView(image: Resource.Images.cellAccessoryIcon)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
           
           if theme.darkModeEnabled() == true {
               return .lightContent
               
           } else {
               return .darkContent
           }
       }
}

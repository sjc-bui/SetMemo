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
    let defaults = UserDefaults.standard
    
    let upgradeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(String(format: "Upgrade".localized, "Set Memo"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = Colors.shared.defaultTintColor
        btn.isUserInteractionEnabled = true
        btn.layer.cornerRadius = 12
        btn.layer.cornerCurve = .continuous
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
        
        defaults.set(true, forKey: Resource.Defaults.setMemoPremium)
        print("upgrade")
        if defaults.bool(forKey: Resource.Defaults.setMemoPremium) == true {
            
            self.showAlert(title: "Congratulation", message: "Success purchase for your premium, enjoy with Set Memo Premium", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [
                { _ in
                    self.dismiss(animated: true, completion: nil)
                }
            ])
        }
    }
    
    @objc func restore() {
        print("restore")
    }
    
    let listFeatures: Array = [
        Features(feature: "CustomAppIconF".localized, type: FeatureType.basic),
        Features(feature: "ShareMemoF".localized, type: FeatureType.basic),
        Features(feature: "CustomFontAndStyleF".localized, type: FeatureType.basic),
        Features(feature: "SetRemindEverydayF".localized, type: FeatureType.basic),
        Features(feature: "UseBiometricsF".localized, type: FeatureType.premium),
        Features(feature: "DarkModeF".localized, type: FeatureType.premium),
        Features(feature: "TintColorF".localized, type: FeatureType.premium),
        Features(feature: "SetRemindForMemoF".localized, type: FeatureType.premium),
        Features(feature: "LockMemoF".localized, type: FeatureType.premium)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.navigationItem.title = "UpgradePremium".localized
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDynamicElements()
        setupRightBarButton()
    }
    
    func setupRightBarButton() {
        let closeBtn = UIBarButtonItem(image: UIImage.SVGImage(named: "icons_filled_cancel", fillColor: .systemGray), style: .done, target: self, action: #selector(dismissView))
        self.navigationItem.rightBarButtonItem = closeBtn
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
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
        return "PremiumViewHeaderTitle".localized
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let background: UIColor?
        let title: String?
        
        if indexPath.row <= 3 {
            background = .systemGreen
            title = "Basic".localized
        } else {
            background = UIColor.amber
            title = "Premium".localized
        }
        
        let featureType = UIContextualAction(style: .normal, title: title) { (action, view, completion) in
            completion(false)
        }
        
        featureType.backgroundColor = background
        return UISwipeActionsConfiguration(actions: [featureType])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if theme.darkModeEnabled() == true {
           return .lightContent
           
        } else {
           return .darkContent
        }
    }
}

//
//  MemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import RealmSwift
import StoreKit

class MemoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var tableView: UITableView = UITableView()
    var dt: Results<MemoItem>?
    let notification = UINotificationFeedbackGenerator()
    let searchController = UISearchController(searchResultsController: nil)
    let emptyView = EmptyMemoView()
    let defaults = UserDefaults.standard
    
    override func initialize() {
        //super.initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableView()
        fetchMemoFromDB()
        setupNavigation()
        resetBadgeIcon()
        requestReviewApp()
    }
    
    func requestReviewApp() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        // request user review when update to new version
        if dt!.count > 10 && defaults.value(forKey: Resource.Defaults.lastReview) as? String != appVersion {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                defaults.set(appVersion, forKey: Resource.Defaults.lastReview)
            }
        }
    }
    
    func resetBadgeIcon() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // table view configure
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.pin(to: view)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
    
    private func setupNavigation() {
        self.navigationController?.navigationBar.tintColor = Colors.shared.accentColor
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        extendedLayoutIncludesOpaqueBars = true
        
        // custom Right bar button
        let createButton = UIBarButtonItem(image: Resource.Images.createButton, style: .plain, target: self, action: #selector(createNewMemo))
        let sortButton = UIBarButtonItem(image: Resource.Images.sortButton, style: .plain, target: self, action: #selector(sortBy))
        let searchButton = UIBarButtonItem(image: Resource.Images.searchButton, style: .plain, target: self, action: nil)
        let settingButton = UIBarButtonItem(image: Resource.Images.settingButton, style: .plain, target: self, action: #selector(settingPage))
        self.navigationItem.rightBarButtonItems = [createButton, sortButton, searchButton]
        self.navigationItem.leftBarButtonItem = settingButton
    }
    
    @objc func sortBy() {
        DeviceControl().feedbackOnPress()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let sortByDateCreated = UIAlertAction(title: NSLocalizedString("SortByDateCreated", comment: ""), style: .default, handler: { (action) in
            self.defaults.set(Resource.SortBy.dateCreated, forKey: Resource.Defaults.sortBy)
            self.fetchMemoFromDB()
        })
        
        let sortByDateEdited = UIAlertAction(title: NSLocalizedString("SortByDateEdited", comment: ""), style: .default, handler: {
            (action) in
            self.defaults.set(Resource.SortBy.dateEdited, forKey: Resource.Defaults.sortBy)
            self.fetchMemoFromDB()
        })
        
        let sortByTitle = UIAlertAction(title: NSLocalizedString("SortByTitle", comment: ""), style: .default, handler: { (action) in
            self.defaults.set(Resource.SortBy.title, forKey: Resource.Defaults.sortBy)
            self.fetchMemoFromDB()
        })
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        let target = "titleTextColor"
        sortByDateCreated.setValue(Colors.shared.accentColor, forKey: target)
        sortByDateEdited.setValue(Colors.shared.accentColor, forKey: target)
        sortByTitle.setValue(Colors.shared.accentColor, forKey: target)
        cancel.setValue(Colors.shared.accentColor, forKey: target)
        
        alertController.addAction(sortByDateCreated)
        alertController.addAction(sortByDateEdited)
        alertController.addAction(sortByTitle)
        alertController.addAction(cancel)
        
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        let screen = UIScreen.main.bounds
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screen.size.width / 2, y: screen.size.height, width: 1.0, height: 1.0)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func createNewMemo() {
        DeviceControl().feedbackOnPress()
        self.navigationController?.pushViewController(WriteMemoController(), animated: true)
    }
    
    @objc func settingPage() {
        DeviceControl().feedbackOnPress()
        self.navigationController?.pushViewController(SettingViewController(), animated: true)
    }
    
    func fetchMemoFromDB() {
        let sortBy = defaults.string(forKey: Resource.Defaults.sortBy)
        var sortKeyPath: String?
        
        if sortBy == Resource.SortBy.dateCreated {
            sortKeyPath = Resource.SortBy.dateCreated
        } else if sortBy == Resource.SortBy.title {
            sortKeyPath = Resource.SortBy.content
        } else if sortBy == Resource.SortBy.dateEdited {
            sortKeyPath = Resource.SortBy.dateEdited
        }
        
        dt = RealmServices.shared.read(MemoItem.self).sorted(byKeyPath: sortKeyPath!, ascending: false)
        self.tableView.reloadData()
    }
    
//    private func updateMemoItemCount() {
//        let totalMemo: Int = dt!.count
//        self.navigationItem.title = navigationTitle(total: totalMemo)
//    }
    
    func navigationTitle(total: Int) -> String {
        if total != 0 {
            return String(format: NSLocalizedString("TotalMemo", comment: ""), total)
        }
        return NSLocalizedString("Memo", comment: "")
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If table has no data. preview empty view.
        if dt?.count == 0 {
            tableView.backgroundView = emptyView
        } else {
            tableView.backgroundView = nil
        }
        
        return dt!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultFontSize = defaults.float(forKey: Resource.Defaults.fontSize)
        let myCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        myCell.backgroundColor = .clear
        myCell.textLabel?.text = dt![indexPath.row].content
        myCell.textLabel?.numberOfLines = 2
        myCell.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(defaultFontSize), weight: .regular)
        
        if defaults.bool(forKey: Resource.Defaults.displayDateTime) == true {
            let detailTextSize = (defaultFontSize / 1.5).rounded(.down)
            myCell.detailTextLabel?.text = DatetimeUtil().convertDatetime(datetime: dt![indexPath.row].dateEdited)
            myCell.detailTextLabel?.font = UIFont.systemFont(ofSize: CGFloat(detailTextSize))
        } else {
            myCell.detailTextLabel?.text = ""
        }
        
        myCell.tintColor = Colors.shared.orangeColor
        myCell.accessoryType = .disclosureIndicator
        return myCell
    }
    
    // Selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memoId = dt![indexPath.row].id
        let updateView = UpdateMemoViewController()
        updateView.memoId = memoId
        self.navigationController?.pushViewController(updateView, animated: true)
    }
    
    // Delete row
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = dt![indexPath.row]
            RealmServices.shared.delete(item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.01 * Double(indexPath.row), animations: {
            cell.alpha = 1
        })
    }
}

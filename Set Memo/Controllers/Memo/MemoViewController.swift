//
//  MemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import RealmSwift

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
        fireNotification()
        resetBadgeIcon()
    }
    
    func resetBadgeIcon() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func fireNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        // let uuid = UUID().uuidString
        // if set only one time in a day
        let id = "daily"
        
        let content = UNMutableNotificationContent()
        content.title = "Set Memo"
        content.subtitle = "Subtitle"
        content.body = "Did you write memo today?"
        content.sound = UNNotificationSound.default
        content.threadIdentifier = "notifi"
        content.badge = 1
        
        let gregorian = Calendar(identifier: .gregorian)
        let date = Date()
        var dateComponent = gregorian.dateComponents([.hour, .minute], from: date)
        dateComponent.hour = 23
        dateComponent.minute = 00
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error != nil {
                print(error!)
            }
        }
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
//        let search = UISearchController(searchResultsController: nil)
//        search.searchBar.tintColor = Colors.shared.accentColor
//        search.searchBar.backgroundImage = UIImage()
//        self.navigationItem.searchController = search
        
        self.navigationItem.title = NSLocalizedString("Memo", comment: "")
        self.navigationController?.navigationBar.tintColor = Colors.shared.accentColor
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        extendedLayoutIncludesOpaqueBars = true
        
        // custom Right bar button
        let createButton = UIBarButtonItem(image: Resource.Images.createButton, style: .plain, target: self, action: #selector(createNewMemo))
        let sortButton = UIBarButtonItem(image: Resource.Images.sortButton, style: .plain, target: self, action: #selector(sortBy))
        let settingButton = UIBarButtonItem(image: Resource.Images.settingButton, style: .plain, target: self, action: #selector(settingPage))
        self.navigationItem.rightBarButtonItems = [createButton, sortButton]
        self.navigationItem.leftBarButtonItem = settingButton
    }
    
    @objc func sortBy() {
        DeviceControl().feedbackOnPress()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let sortByDateCreated = UIAlertAction(title: NSLocalizedString("SortByDateCreated", comment: ""), style: .default, handler: { (action) in
            self.defaults.set(Resource.SortBy.dateCreated, forKey: Resource.Defaults.sortBy)
            self.fetchMemoFromDB()
        })
        
        let sortByDateEdited = UIAlertAction(title: NSLocalizedString("SortByDateEdited", comment: ""), style: .default) { (action) in
            self.defaults.set(Resource.SortBy.dateEdited, forKey: Resource.Defaults.sortBy)
            self.fetchMemoFromDB()
        }
        
        let sortByTitle = UIAlertAction(title: NSLocalizedString("SortByTitle", comment: ""), style: .default, handler: { (action) in
            self.defaults.set(Resource.SortBy.dateEdited, forKey: Resource.Defaults.sortBy)
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
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
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
        let realm = try! Realm()
        let sortBy = defaults.string(forKey: Resource.Defaults.sortBy)
        var sortKeyPath: String?
        
        if sortBy == Resource.SortBy.dateCreated {
            sortKeyPath = Resource.SortBy.dateCreated
        } else if sortBy == Resource.SortBy.title {
            sortKeyPath = Resource.SortBy.content
        } else if sortBy == Resource.SortBy.dateEdited {
            sortKeyPath = Resource.SortBy.dateEdited
        }
        
        dt = realm.objects(MemoItem.self).sorted(byKeyPath: sortKeyPath!, ascending: false)
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
}

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

class MemoViewController: UITableViewController {
    var dt: Results<MemoItem>?
    let notification = UINotificationFeedbackGenerator()
    let searchController = UISearchController(searchResultsController: nil)
    let emptyView = EmptyMemoView()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMemoFromDB()
        setupNavigation()
        resetIconBadges()
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
    
    func resetIconBadges() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func setupNavigation() {
        self.navigationController?.navigationBar.tintColor = Colors.shared.accentColor
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        extendedLayoutIncludesOpaqueBars = true
        
        //searchController.searchResultsUpdater = self as UISearchResultsUpdating
        //configureSearchBar()
        
        // custom Right bar button
        let sortButton = UIBarButtonItem(title: "Sort".localized, style: .done, target: self, action: #selector(sortBy))
        let createButton = UIBarButtonItem(title: "New".localized, style: .done, target: self, action: #selector(createNewMemo))
        let settingButton = UIBarButtonItem(image: Resource.Images.settingButton, style: .plain, target: self, action: #selector(settingPage))
        self.navigationItem.rightBarButtonItems = [createButton, sortButton]
        self.navigationItem.leftBarButtonItem = settingButton
    }
    
    func configureSearchBar() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Notes"
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.isActive = false
        //searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    @objc func sortBy() {
        DeviceControl().feedbackOnPress()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let sortByDateCreated = UIAlertAction(title: "SortByDateCreated".localized, style: .default, handler: { (action) in
            self.defaults.set(Resource.SortBy.dateCreated, forKey: Resource.Defaults.sortBy)
            self.fetchMemoFromDB()
        })
        
        let sortByDateEdited = UIAlertAction(title: "SortByDateEdited".localized, style: .default, handler: {
            (action) in
            self.defaults.set(Resource.SortBy.dateEdited, forKey: Resource.Defaults.sortBy)
            self.fetchMemoFromDB()
        })
        
        let sortByTitle = UIAlertAction(title: "SortByTitle".localized, style: .default, handler: { (action) in
            self.defaults.set(Resource.SortBy.title, forKey: Resource.Defaults.sortBy)
            self.fetchMemoFromDB()
        })
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
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
        self.navigationController?.pushViewController(SettingViewController(style: .insetGrouped), animated: true)
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
        
        dt = RealmServices.shared.read(MemoItem.self, temporarilyDelete: false).sorted(byKeyPath: sortKeyPath!, ascending: false)
        self.tableView.reloadData()
    }
    
//    private func updateMemoItemCount() {
//        let totalMemo: Int = dt!.count
//        self.navigationItem.title = navigationTitle(total: totalMemo)
//    }
    
    func navigationTitle(total: Int) -> String {
        if total != 0 {
            return String(format: "TotalMemo".localized, total)
        }
        return "Memo".localized
    }
    
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dt?.count == 0 {
            tableView.backgroundView = emptyView
        } else {
            tableView.backgroundView = nil
        }
        
        return dt!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultFontSize = defaults.float(forKey: Resource.Defaults.fontSize)
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        cell.backgroundColor = .clear
        cell.textLabel?.text = dt![indexPath.row].content
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(defaultFontSize), weight: .regular)
        
        if defaults.bool(forKey: Resource.Defaults.displayDateTime) == true {
            let detailTextSize = (defaultFontSize / 1.5).rounded(.down)
            cell.detailTextLabel?.text = DatetimeUtil().convertDatetime(datetime: dt![indexPath.row].dateEdited)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: CGFloat(detailTextSize))
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        cell.tintColor = Colors.shared.orangeColor
        cell.accessoryType = .disclosureIndicator
        
        cell.contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longTapHandler(sender:))))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memoId = dt![indexPath.row].id
        let updateView = UpdateMemoViewController()
        updateView.memoId = memoId
        self.navigationController?.pushViewController(updateView, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // temploratily delete item
        if editingStyle == .delete {
            deleteHandler(indexPath: indexPath)
        }
    }
    
    func deleteHandler(indexPath: IndexPath) {
        let item = dt![indexPath.row]
        let realm = try! Realm()
        let memoItem = realm.objects(MemoItem.self).filter("id = %@", item.id).first
        do {
            try realm.write({
                memoItem!.temporarilyDelete = true
                memoItem?.dateEdited = Date()
            })
        } catch {
            print(error)
        }
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.01 * Double(indexPath.row), animations: {
            cell.alpha = 1
        })
    }
    
    @objc func longTapHandler(sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: location)!
        
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let remind = UIAlertAction(title: "RemindMe".localized, style: .default) { (action) in
            print("remind me")
        }
        
        let share = UIAlertAction(title: "Share".localized, style: .default) { (action) in
            let shareText = self.dt![indexPath.row].content
            self.shareMemo(content: shareText)
        }
        
        let delete = UIAlertAction(title: "Delete".localized, style: .default) { (action) in
            self.deleteHandler(indexPath: indexPath)
        }
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        let target = "titleTextColor"
        remind.setValue(Colors.shared.accentColor, forKey: target)
        share.setValue(Colors.shared.accentColor, forKey: target)
        delete.setValue(Colors.shared.accentColor, forKey: target)
        cancel.setValue(Colors.shared.accentColor, forKey: target)
        
        alertSheet.addAction(remind)
        alertSheet.addAction(share)
        alertSheet.addAction(delete)
        alertSheet.addAction(cancel)
        
        alertSheet.popoverPresentationController?.sourceView = self.view
        alertSheet.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        let screen = UIScreen.main.bounds
        alertSheet.popoverPresentationController?.sourceRect = CGRect(x: screen.size.width / 2, y: screen.size.height, width: 1.0, height: 1.0)
        
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    func shareMemo(content: String) {
        let textToShare = content
        let objectToShare = [textToShare] as [Any]
        
        let activityViewController = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop,
                                                         UIActivity.ActivityType.addToReadingList]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}

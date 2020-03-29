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
    var data: [MemoItem] = []
    var filterMemo: [MemoItem] = []
    let notification = UINotificationFeedbackGenerator()
    let searchController = UISearchController(searchResultsController: nil)
    let emptyView = EmptyMemoView()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MemoViewCell.self, forCellReuseIdentifier: "cellId")
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
        if data.count > 10 && defaults.value(forKey: Resource.Defaults.lastReview) as? String != appVersion {
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
        configureSearchBar()
        
        // custom Right bar button
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down.circle"), style: .plain, target: self, action: #selector(sortBy))
        let createButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .plain, target: self, action: #selector(createNewMemo))
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingPage))
        self.navigationItem.rightBarButtonItems = [createButton, sortButton]
        self.navigationItem.leftBarButtonItem = settingButton
    }
    
    func configureSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "SearchPlaceholder".localized
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.isActive = false
        searchController.searchBar.scopeButtonTitles = ["SortByTitle".localized, "hashTag"]
        //searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            filterMemo = data.filter({ (memo: MemoItem) -> Bool in
                memo.content.lowercased().contains(searchText.lowercased())
            })
            tableView.reloadData()
        } else if searchController.searchBar.selectedScopeButtonIndex == 1 {
            filterMemo = data.filter({ (memo: MemoItem) -> Bool in
                memo.hashTag.lowercased().contains(searchText.lowercased())
            })
            tableView.reloadData()
        }
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
        
        data = RealmServices.shared.read(MemoItem.self, temporarilyDelete: false)
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
        if data.count == 0 {
            tableView.backgroundView = emptyView
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            if isFiltering() {
                return filterMemo.count
            } else {
                return data.count
            }
        }
        
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MemoViewCell
        cell.selectedBackground()
        
        var memo = data[indexPath.row]
        if isFiltering() {
            memo = filterMemo[indexPath.row]
        } else {
            memo = data[indexPath.row]
        }
        
        let defaultFontSize = defaults.float(forKey: Resource.Defaults.fontSize)
        
        cell.content.font = UIFont.boldSystemFont(ofSize: CGFloat(defaultFontSize))
        cell.content.text = memo.content
        cell.content.numberOfLines = 2
        
        if defaults.bool(forKey: Resource.Defaults.displayDateTime) == true {
            let detailTextSize = (defaultFontSize / 1.2).rounded(.down)
            cell.dateEdited.font = UIFont.systemFont(ofSize: CGFloat(detailTextSize))
            cell.hashTag.font = UIFont.systemFont(ofSize: CGFloat(detailTextSize))
            cell.dateEdited.text = "\(DatetimeUtil().convertDatetime(datetime: memo.dateEdited))"
            cell.hashTag.text = "#\(memo.hashTag)"
            cell.hashTag.textAlignment = .right
        } else {
            cell.dateEdited.text = ""
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longTapHandler(sender:))))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var memoId: String?
        
        if isFiltering() {
            memoId = filterMemo[indexPath.row].id
        } else {
            memoId = data[indexPath.row].id
        }
        
        let updateView = UpdateMemoViewController()
        updateView.memoId = memoId!
        self.navigationController?.pushViewController(updateView, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // temploratily delete item
        if editingStyle == .delete {
            deleteHandler(indexPath: indexPath)
        }
    }
    
    func deleteHandler(indexPath: IndexPath) {
        var item = data[indexPath.row]
        
        if isFiltering() {
            item = filterMemo[indexPath.row]
        } else {
            item = data[indexPath.row]
        }
        
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
    
    @objc func longTapHandler(sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: location)!
        
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let remind = UIAlertAction(title: "RemindMe".localized, style: .default) { (action) in
            print("remind me")
        }
        
        let share = UIAlertAction(title: "Share".localized, style: .default) { (action) in
            let shareText = self.data[indexPath.row].content
            let hashTag = self.data[indexPath.row].hashTag
            self.shareMemo(content: shareText, hashTag: hashTag)
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
        
        if !(navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
            DeviceControl().feedbackOnPress()
            self.present(alertSheet, animated: true, completion: nil)
        }
    }
    
    func shareMemo(content: String, hashTag: String) {
        let textToShare = "#\(hashTag)\n\(content)"
        let objectToShare = [textToShare] as [Any]
        
        let activityViewController = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop,
                                                         UIActivity.ActivityType.addToReadingList]
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        let screen = UIScreen.main.bounds
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: screen.size.width / 2, y: screen.size.height, width: 1.0, height: 1.0)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension MemoViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

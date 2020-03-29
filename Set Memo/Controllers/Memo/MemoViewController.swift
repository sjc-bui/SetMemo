//
//  MemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import StoreKit
import CoreData

class MemoViewController: UITableViewController {
    var memoData: [Memo] = []
    var filterMemoData: [Memo] = []
    
    let notification = UINotificationFeedbackGenerator()
    let searchController = UISearchController(searchResultsController: nil)
    let emptyView = EmptyMemoView()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        tableView.register(MemoViewCell.self, forCellReuseIdentifier: "cellId")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMemoFromCoreData()
        setupNavigation()
        resetIconBadges()
        requestReviewApp()
    }
    
    func requestReviewApp() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        // request user review when update to new version
        if memoData.count > 10 && defaults.value(forKey: Resource.Defaults.lastReview) as? String != appVersion {
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
        self.navigationItem.title = "Memo".localized
        self.navigationController?.navigationBar.tintColor = Colors.shared.accentColor
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        extendedLayoutIncludesOpaqueBars = true
        
        //searchController.searchResultsUpdater = self as UISearchResultsUpdating
        configureSearchBar()
        
        let createButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .plain, target: self, action: #selector(createNewMemo))
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingPage))
        self.navigationItem.rightBarButtonItem = createButton
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
            filterMemoData = memoData.filter({ (memo: Memo) -> Bool in
                memo.content!.lowercased().contains(searchText.lowercased())
            })
            tableView.reloadData()
        } else if searchController.searchBar.selectedScopeButtonIndex == 1 {
            filterMemoData = memoData.filter({ (memo: Memo) -> Bool in
                memo.hashTag!.lowercased().contains(searchText.lowercased())
            })
            tableView.reloadData()
        }
    }
    
    @objc func sortBy() {
        DeviceControl().feedbackOnPress()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let sortByDateCreated = UIAlertAction(title: "SortByDateCreated".localized, style: .default, handler: { (action) in
            self.defaults.set(Resource.SortBy.dateCreated, forKey: Resource.Defaults.sortBy)
            self.fetchMemoFromCoreData()
        })
        
        let sortByDateEdited = UIAlertAction(title: "SortByDateEdited".localized, style: .default, handler: {
            (action) in
            self.defaults.set(Resource.SortBy.dateEdited, forKey: Resource.Defaults.sortBy)
            self.fetchMemoFromCoreData()
        })
        
        let sortByTitle = UIAlertAction(title: "SortByTitle".localized, style: .default, handler: { (action) in
            self.defaults.set(Resource.SortBy.title, forKey: Resource.Defaults.sortBy)
            self.fetchMemoFromCoreData()
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
    
    func fetchMemoFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Memo")
        fetchRequest.returnsObjectsAsFaults = false
        
        let sortBy = defaults.string(forKey: Resource.Defaults.sortBy)
        var sortDescriptor: NSSortDescriptor?
        
        if sortBy == Resource.SortBy.dateCreated {
            sortDescriptor = NSSortDescriptor(key: Resource.SortBy.dateCreated, ascending: false)
        } else if sortBy == Resource.SortBy.title {
            sortDescriptor = NSSortDescriptor(key: Resource.SortBy.content, ascending: false)
        } else if sortBy == Resource.SortBy.dateEdited {
            sortDescriptor = NSSortDescriptor(key: Resource.SortBy.dateEdited, ascending: false)
        }
        
        fetchRequest.sortDescriptors = [sortDescriptor] as? [NSSortDescriptor]
        
        do {
            self.memoData = try managedContext.fetch(fetchRequest) as! [Memo]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        print("get sorted data here")
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
        if memoData.isEmpty {
            tableView.backgroundView = emptyView
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            if isFiltering() {
                return filterMemoData.count
            } else {
                return memoData.count
            }
        }
        return memoData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MemoViewCell
        cell.selectedBackground()
        
        var memo = memoData[indexPath.row]
        if isFiltering() {
            memo = filterMemoData[indexPath.row]
        } else {
            memo = memoData[indexPath.row]
        }
        
        let content = memo.value(forKey: "content") as? String
        let dateEdited = memo.value(forKey: "dateEdited") as? Double ?? 0
        //let isReminder = memo.value(forKey: "isReminder") as? Bool
        let hashTag = memo.value(forKey: "hashTag") as? String
        
        let defaultFontSize = defaults.float(forKey: Resource.Defaults.fontSize)

        cell.content.font = UIFont.boldSystemFont(ofSize: CGFloat(defaultFontSize))
        cell.content.numberOfLines = 2
        cell.content.text = content

        if defaults.bool(forKey: Resource.Defaults.displayDateTime) == true {
            let dateEdit = Date(timeIntervalSinceReferenceDate: dateEdited)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeZone = .current
            let dateString = dateFormatter.string(from: dateEdit)
            
            let detailTextSize = (defaultFontSize / 1.2).rounded(.down)
            cell.dateEdited.font = UIFont.systemFont(ofSize: CGFloat(detailTextSize))
            cell.dateEdited.text = dateString
            
            cell.hashTag.font = UIFont.systemFont(ofSize: CGFloat(detailTextSize))
            cell.hashTag.textAlignment = .right
            cell.hashTag.text = hashTag
        } else {
            cell.dateEdited.text = ""
        }

        cell.accessoryType = .disclosureIndicator
        cell.contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longTapHandler(sender:))))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var memoId: String?
        
//        if isFiltering() {
//            memoId = filterMemo[indexPath.row].id
//        } else {
//            memoId = data[indexPath.row].id
//        }
        
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sortText: String?
        let sortBy = defaults.string(forKey: Resource.Defaults.sortBy)
        
        if sortBy == Resource.SortBy.title {
            sortText = "SortByTitle".localized
        } else if sortBy == Resource.SortBy.dateCreated {
            sortText = "SortByDateCreated".localized
        } else if sortBy == Resource.SortBy.dateEdited {
            sortText = "SortByDateEdited".localized
        }
        
        return String(format: "SortBy".localized, sortText!)
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = Colors.shared.accentColor
        header.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        header.textLabel?.textAlignment = NSTextAlignment.right
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(sortBy))
        header.addGestureRecognizer(gesture)
    }
    
    func deleteHandler(indexPath: IndexPath) {
//        var item = data[indexPath.row]
//
//        if isFiltering() {
//            item = filterMemo[indexPath.row]
//        } else {
//            item = data[indexPath.row]
//        }
        
        print("delete data")
        
        //tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    @objc func longTapHandler(sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: location)!
        
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let remind = UIAlertAction(title: "RemindMe".localized, style: .default) { (action) in
            print("remind me")
        }
        
        let share = UIAlertAction(title: "Share".localized, style: .default) { (action) in
//            let shareText = self.data[indexPath.row].content
//            let hashTag = self.data[indexPath.row].hashTag
//            self.shareMemo(content: shareText, hashTag: hashTag)
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

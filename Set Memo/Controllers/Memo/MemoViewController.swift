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
import SPAlert

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
        self.navigationItem.setBackButtonTitle(title: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        configureSearchBar()
        resetIconBadges()
        requestReviewApp()
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchMemoFromCoreData()
        setupBarButton()
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
    }
    
    func setupBarButton() {
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
        
        alertController.view.tintColor = Colors.shared.accentColor
        
        alertController.addAction(sortByDateCreated)
        alertController.addAction(sortByDateEdited)
        alertController.addAction(sortByTitle)
        alertController.addAction(cancel)
        alertController.pruneNegativeWidthConstraints()
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.any]
        }
        
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
        fetchRequest.predicate = NSPredicate(format: "temporarilyDelete = %d", false)
        
        do {
            self.memoData = try managedContext.fetch(fetchRequest) as! [Memo]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
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
        } else {
            tableView.backgroundView = nil
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

        cell.content.font = UIFont.systemFont(ofSize: CGFloat(defaultFontSize), weight: .medium)
        cell.content.textColor = UIColor(named: "mainTextColor")
        cell.content.numberOfLines = 1
        cell.content.text = content
        
        if defaults.bool(forKey: Resource.Defaults.displayDateTime) == true {
            let dateString = DatetimeUtil().convertDatetime(date: dateEdited)
            let detailTextSize = (defaultFontSize / 1.2).rounded(.down)
            cell.dateEdited.textColor = Colors.shared.systemGrayColor
            cell.dateEdited.font = UIFont.systemFont(ofSize: CGFloat(detailTextSize))
            cell.dateEdited.text = dateString
            
            cell.hashTag.font = UIFont.systemFont(ofSize: CGFloat(detailTextSize))
            cell.hashTag.textColor = Colors.shared.systemGrayColor
            cell.hashTag.textAlignment = .right
            cell.hashTag.text = "#\(hashTag!)"
            
        } else {
            cell.dateEdited.text = ""
        }
        
        cell.accessoryType = .none
        cell.contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longTapHandler(sender:))))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let updateView = UpdateMemoViewController()
        var memo = memoData[indexPath.row]
        
        if isFiltering() {
            memo = filterMemoData[indexPath.row]
            updateView.filterMemoData = filterMemoData
            updateView.isFiltering = true
        } else {
            memo = memoData[indexPath.row]
            updateView.memoData = memoData
        }
        
        let content = memo.value(forKey: "content") as? String
        let hashTag = memo.value(forKey: "hashTag") as? String
        let dateCreated = memo.value(forKey: "dateCreated") as? Double ?? 0
        let dateEdited = memo.value(forKey: "dateEdited") as? Double ?? 0
        let isReminder = memo.value(forKey: "isReminder") as? Bool
        let dateReminder = memo.value(forKey: "dateReminder") as? String
        
        let dateCreatedString = DatetimeUtil().convertDatetime(date: dateCreated)
        let dateEditedString = DatetimeUtil().convertDatetime(date: dateEdited)
        
        updateView.navigationItem.title = dateEditedString
        updateView.content = content!
        updateView.hashTag = hashTag!
        updateView.dateCreated = dateCreatedString
        updateView.dateEdited = dateEditedString
        updateView.isReminder = isReminder!
        updateView.dateReminder = dateReminder
        updateView.index = indexPath.row
        
        self.navigationController?.pushViewController(updateView, animated: true)
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
        header.textLabel?.font = UIFont.systemFont(ofSize: Dimension.shared.medium, weight: .medium)
        header.textLabel?.textAlignment = NSTextAlignment.right
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(sortBy))
        header.addGestureRecognizer(gesture)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let remind = remindAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, remind])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            self.deleteHandler(indexPath: indexPath)
            completion(true)
        }
        action.image = Resource.Images.trashButton
        action.backgroundColor = .systemRed
        return action
    }
    
    func remindAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            self.setReminder()
            completion(true)
        }
        action.image = Resource.Images.alarmButton
        action.backgroundColor = Colors.shared.accentColor
        return action
    }
    
    // MARK: - Long Tap Handle
    @objc func longTapHandler(sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: location)!
        
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let remind = UIAlertAction(title: "RemindMe".localized, style: .default) { (action) in
            self.setReminder()
        }
        
        let share = UIAlertAction(title: "Share".localized, style: .default) { (action) in
            self.shareHandler(indexPath: indexPath)
        }
        
        let delete = UIAlertAction(title: "Delete".localized, style: .default) { (action) in
            self.deleteHandler(indexPath: indexPath)
        }
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        alertSheet.view.tintColor = Colors.shared.accentColor
        
        alertSheet.addAction(remind)
        alertSheet.addAction(share)
        alertSheet.addAction(delete)
        alertSheet.addAction(cancel)
        alertSheet.pruneNegativeWidthConstraints()
        
        if let popoverController = alertSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.any]
        }
        
        if !(navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
            DeviceControl().feedbackOnPress()
            self.present(alertSheet, animated: true, completion: nil)
        }
    }
    
    // MARK: - Delete memo
    func deleteHandler(indexPath: IndexPath) {
        
        if defaults.bool(forKey: Resource.Defaults.firstTimeDeleted) == true {
            let alertController = UIAlertController(title: "DeletedMemoMoved".localized, message: "DeletedMemoMovedMess".localized, preferredStyle: .alert)
            
            let acceptButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            acceptButton.setValue(Colors.shared.accentColor, forKey: "titleTextColor")
            
            alertController.addAction(acceptButton)
            
            defaults.set(false, forKey: Resource.Defaults.firstTimeDeleted)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        if isFiltering() == true {
            let filteredMemo = filterMemoData[indexPath.row]
            
            // remove pending notification.
            let notificationUUID = filteredMemo.notificationUUID ?? "empty"
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [notificationUUID])
            
            // remove notification on badge.
            
            filteredMemo.setValue(true, forKey: "temporarilyDelete")
            filterMemoData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else {
            let memo = memoData[indexPath.row]
            
            let noficationUUID = memo.notificationUUID ?? "empty"
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [noficationUUID])
            
            memo.setValue(true, forKey: "temporarilyDelete")
            memoData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error) , \(error.userInfo)")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Share memo
    func shareHandler(indexPath: IndexPath) {
        if isFiltering() == true {
            let filterData = filterMemoData[indexPath.row]
            let content = filterData.value(forKey: "content") as? String
            let hashTag = filterData.value(forKey: "hashTag") as? String
            self.shareMemo(content: content!, hashTag: hashTag!)
            
        } else {
            let memo = memoData[indexPath.row]
            let content = memo.value(forKey: "content") as? String
            let hashTag = memo.value(forKey: "hashTag") as? String
            self.shareMemo(content: content!, hashTag: hashTag!)
        }
    }
    
    func shareMemo(content: String, hashTag: String) {
        let textToShare = "#\(hashTag)\n\(content)"
        let objectToShare = [textToShare] as [Any]
        
        let activityViewController = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop,
                                                         UIActivity.ActivityType.addToReadingList]
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.any]
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Set Reminder
    func setReminder() {
        let remindController = UIAlertController(title: "SetReminder".localized, message: nil, preferredStyle: .actionSheet)
        let customView = UIView()
        let datePicker = UIDatePicker()
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.timeZone = NSTimeZone.local
        datePicker.setValue(UIColor.label, forKey: "textColor")
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        
        customView.addSubview(datePicker)
        remindController.view.addSubview(customView)
        
        datePicker.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        datePicker.leftAnchor.constraint(equalTo: customView.leftAnchor).isActive = true
        datePicker.rightAnchor.constraint(equalTo: customView.rightAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
        
        customView.topAnchor.constraint(equalTo: remindController.view.topAnchor, constant: 36).isActive = true
        customView.rightAnchor.constraint(equalTo: remindController.view.rightAnchor, constant: -10).isActive = true
        customView.leftAnchor.constraint(equalTo: remindController.view.leftAnchor, constant: 10).isActive = true
        if UIDevice.current.userInterfaceIdiom == .phone {
            customView.bottomAnchor.constraint(equalTo: remindController.view.bottomAnchor, constant: -120).isActive = true
        } else {
            customView.bottomAnchor.constraint(equalTo: remindController.view.bottomAnchor, constant: -50).isActive = true
        }
        
        remindController.view.translatesAutoresizingMaskIntoConstraints = false
        remindController.view.heightAnchor.constraint(equalToConstant: Dimension.shared.reminderBoundHeight).isActive = true
        
        let doneBtn = UIAlertAction(title: "Done".localized, style: .default) { action in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "DatetimeFormat".localized
            let dateFromPicker = dateFormatter.string(from: datePicker.date)
            
            print(dateFromPicker)
            let alert = SPAlertView(title: "RemindSetTitle".localized, message: String(format: "RemindAt".localized, dateFromPicker), preset: .done)
            alert.duration = 2
            alert.haptic = .success
            alert.present()
        }
        let cancelBtn = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)

        remindController.pruneNegativeWidthConstraints()
        remindController.view.tintColor = Colors.shared.accentColor
        remindController.addAction(doneBtn)
        remindController.addAction(cancelBtn)
        
        if let popoverController = remindController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.any]
        }
        
        self.present(remindController, animated: true, completion: nil)
    }
}

extension MemoViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

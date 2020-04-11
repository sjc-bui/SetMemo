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
    let datePicker = UIDatePicker()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView(frame: .zero, style: .plain) // add options show list style.
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
        
        if defaults.integer(forKey: Resource.Defaults.theme) == 2 {
            tableView.separatorStyle = .singleLine
            
        } else {
            tableView.separatorStyle = .none
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchMemoFromCoreData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
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
        self.navigationController?.navigationBar.backgroundColor = UIColor.systemBackground
        self.navigationController?.navigationBar.barTintColor = UIColor.systemBackground
        self.navigationController?.navigationBar.tintColor = UIColor.colorFromString(from: defaults.integer(forKey: Resource.Defaults.defaultTintColor))
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        extendedLayoutIncludesOpaqueBars = true
    }
    
    func setupBarButton() {
        
        let createButton = UIBarButtonItem(image: Resource.Images.createButton, style: .plain, target: self, action: #selector(createNewMemo))
        let settingButton = UIBarButtonItem(image: Resource.Images.settingButton, style: .plain, target: self, action: #selector(settingPage))
        self.navigationItem.rightBarButtonItem = createButton
        self.navigationItem.leftBarButtonItem = settingButton
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        let countMemo = UILabel(frame: .zero)
        countMemo.textColor = UIColor(named: "mainTextColor")
        countMemo.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        countMemo.text = memoCountString(total: memoData.count)
        countMemo.textDropShadow()
        
        let sortBtn = UIButton(frame: .zero)
        let sortButtonTitle = showSortType()
        sortBtn.setTitle(sortButtonTitle, for: .normal)
        sortBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        sortBtn.titleLabel?.textDropShadow()
        sortBtn.setTitleColor(UIColor.colorFromString(from: defaults.integer(forKey: Resource.Defaults.defaultTintColor)), for: .normal)
        sortBtn.addTarget(self, action: #selector(sortBy), for: .touchUpInside)
        
        let items: [UIBarButtonItem] = [
            UIBarButtonItem(customView: countMemo),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(customView: sortBtn)
        ]
        self.navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        self.toolbarItems = items
    }
    
    func showSortType() -> String {
        
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
        
        alertController.view.tintColor = UIColor.colorFromString(from: defaults.integer(forKey: Resource.Defaults.defaultTintColor))
        
        alertController.addAction(sortByDateCreated)
        alertController.addAction(sortByDateEdited)
        alertController.addAction(sortByTitle)
        alertController.addAction(cancel)
        
        alertController.pruneNegativeWidthConstraints()
        alertController.safePosition()
        
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
            self.setupBarButton()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func memoCountString(total: Int) -> String {
        if total != 0 {
            return String(format: "TotalMemo".localized, total)
        }
        return ""
    }
    
    func reminderIsSetAtIndex(indexPath: IndexPath) -> Bool {
        
        if isFiltering() == true {
            if filterMemoData[indexPath.row].isReminder == true {
                return true
            } else {
                return false
            }
            
        } else {
            if memoData[indexPath.row].isReminder == true {
                return true
            } else {
                return false
            }
        }
    }
    
    func importantIsSetAtIndex(indexPath: IndexPath) -> Bool {
        
        if isFiltering() == true {
            if filterMemoData[indexPath.row].isImportant == true {
                return true
            } else {
                return false
            }
            
        } else {
            if memoData[indexPath.row].isImportant == true {
                return true
            } else {
                return false
            }
        }
    }
    
    func shareMemoAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            self.shareMemoHandle(indexPath: indexPath)
            completion(true)
        }
        action.image = Resource.Images.shareButton
        action.backgroundColor = .systemBlue
        return action
    }
    
    func deleteMemoAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            self.deleteMemoHandle(indexPath: indexPath)
            completion(true)
        }
        action.image = Resource.Images.trashButton
        action.backgroundColor = .systemRed
        return action
    }
    
    func remindMemoAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            self.setReminderForMemo(indexPath: indexPath)
            completion(true)
        }
        action.image = Resource.Images.alarmButton
        action.backgroundColor = Colors.shared.reminderBtn
        return action
    }
    
    func deleteReminderAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            self.deleteReminderHandle(indexPath: indexPath)
            completion(true)
        }
        action.image = Resource.Images.slashBellButton
        action.backgroundColor = Colors.shared.reminderBtn
        return action
    }
    
    func setImportantAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            self.updateImportant(isImportant: true, indexPath: indexPath)
            print("important")
            completion(true)
        }
        action.image = Resource.Images.setImportantButton
        action.backgroundColor = Colors.shared.importantBtn
        return action
    }
    
    func updateImportant(isImportant: Bool, indexPath: IndexPath) {
        
        if isFiltering() == true {
            let filterData = filterMemoData[indexPath.row]
            filterData.isImportant = isImportant
            
        } else if isFiltering() == false {
            let memo = memoData[indexPath.row]
            memo.isImportant = isImportant
        }
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        do {
            try context?.save()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.tableView.reloadData()
        }
    }
    
    func removeImportantAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            self.updateImportant(isImportant: false, indexPath: indexPath)
            print("remove important")
            completion(true)
        }
        action.image = Resource.Images.removeImportantButton
        action.backgroundColor = Colors.shared.importantBtn
        return action
    }
    
    func deleteReminderHandle(indexPath: IndexPath) {
        
        if isFiltering() == true {
            let filterData = filterMemoData[indexPath.row]
            let removeUUID = filterData.notificationUUID ?? "empty"
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [removeUUID])
            
            filterData.notificationUUID = "cleared"
            filterData.isReminder = false
            filterData.dateReminder = 0.0
            
        } else if isFiltering() == false {
            let memo = memoData[indexPath.row]
            let removeUUID = memo.notificationUUID ?? "empty"
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [removeUUID])
            
            memo.notificationUUID = "cleared"
            memo.isReminder = false
            memo.dateReminder = 0.0
        }
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        do {
            try context?.save()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        SPAlert().done(title: "ReminderDeleted".localized, message: nil, haptic: false, duration: 1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Delete memo
    func deleteMemoHandle(indexPath: IndexPath) {
        
        if defaults.bool(forKey: Resource.Defaults.firstTimeDeleted) == true {
            let alertController = UIAlertController(title: "DeletedMemoMoved".localized, message: "DeletedMemoMovedMess".localized, preferredStyle: .alert)
            
            let acceptButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            acceptButton.setValue(UIColor.colorFromString(from: defaults.integer(forKey: Resource.Defaults.defaultTintColor)), forKey: "titleTextColor")
            
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
            
            filteredMemo.setValue(true, forKey: "temporarilyDelete")
            filterMemoData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        } else {
            let memo = memoData[indexPath.row]
            
            let noficationUUID = memo.notificationUUID ?? "empty"
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [noficationUUID])
            
            memo.setValue(true, forKey: "temporarilyDelete")
            memoData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error) , \(error.userInfo)")
        }
        
        self.setupBarButton()
    }
    
    // MARK: - Share memo
    func shareMemoHandle(indexPath: IndexPath) {
        
        if isFiltering() == true {
            let filterData = filterMemoData[indexPath.row]
            let content = filterData.value(forKey: "content") as? String
            let hashTag = filterData.value(forKey: "hashTag") as? String
            self.shareActivityViewController(content: content!, hashTag: hashTag!)
            
        } else {
            let memo = memoData[indexPath.row]
            let content = memo.value(forKey: "content") as? String
            let hashTag = memo.value(forKey: "hashTag") as? String
            self.shareActivityViewController(content: content!, hashTag: hashTag!)
        }
    }
    
    func shareActivityViewController(content: String, hashTag: String) {
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
    func setReminderForMemo(indexPath: IndexPath) {
        let remindController = UIAlertController(title: "SetReminder".localized, message: nil, preferredStyle: .actionSheet)
        let customView = UIView()
        
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
            self.setReminderContent(indexPath: indexPath)
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)

        remindController.view.tintColor = UIColor.colorFromString(from: defaults.integer(forKey: Resource.Defaults.defaultTintColor))
        remindController.addAction(doneBtn)
        remindController.addAction(cancelBtn)
        
        remindController.pruneNegativeWidthConstraints()
        remindController.safePosition()
        
        self.present(remindController, animated: true, completion: nil)
    }
    
    func setReminderContent(indexPath: IndexPath) {
        
        if isFiltering() == true {
            let filterData = filterMemoData[indexPath.row]
            let content = filterData.value(forKey: "content") as? String
            let hashTag = filterData.value(forKey: "hashTag") as? String
            scheduleNotification(title: hashTag!, bodyContent: content!, index: indexPath.row)
            
        } else {
            let memo = memoData[indexPath.row]
            let content = memo.value(forKey: "content") as? String
            let hashTag = memo.value(forKey: "hashTag") as? String
            scheduleNotification(title: hashTag!, bodyContent: content!, index: indexPath.row)
        }
    }
    
    func scheduleNotification(title: String, bodyContent: String, index: Int) {
        
        let center = UNUserNotificationCenter.current()
        let uuid = UUID().uuidString
        
        let content = UNMutableNotificationContent()
        content.title = "#\(title)"
        content.body = bodyContent
        content.userInfo = ["reminderTitle": title]
        content.sound = UNNotificationSound.default
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        
        let components = datePicker.calendar?.dateComponents([.year, .month, .day, .hour, .minute], from: datePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components!, repeats: false)
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "DatetimeFormat".localized
        let dateFromPicker = dateFormatter.string(from: datePicker.date)
        
        center.add(request) { (error) in
            if error != nil {
                print("Reminder error: \(error!)")
            }
        }
        
        updateContentWithReminder(notificationUUID: uuid, dateReminder: datePicker.date.timeIntervalSinceReferenceDate, index: index)
        
        SPAlert().done(title: "RemindSetTitle".localized, message: String(format: "RemindAt".localized, dateFromPicker), haptic: true, duration: 2.0)
    }
    
    func updateContentWithReminder(notificationUUID: String, dateReminder: Double, index: Int) {
        
        if isFiltering() == true {
            let filterData = filterMemoData[index]
            filterData.notificationUUID = notificationUUID
            filterData.dateReminder = dateReminder
            filterData.isReminder = true
            
        } else {
            let memo = memoData[index]
            memo.notificationUUID = notificationUUID
            memo.dateReminder = dateReminder
            memo.isReminder = true
        }
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        do {
            try context?.save()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

class AirDropOnlyActivityItemSource: NSObject, UIActivityItemSource {
    ///The item you want to send via AirDrop.
    let item: Any

    init(item: Any) {
        self.item = item
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        //using NSURL here, since URL with an empty string would crash
        return NSURL(string: "")!
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return item
    }
}

// MARK: - Extension MemmoViewController
extension MemoViewController {
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteMemoAction(at: indexPath)
        let remind = remindMemoAction(at: indexPath)
        let deleteRemind = deleteReminderAction(at: indexPath)
        
        if reminderIsSetAtIndex(indexPath: indexPath) == true {
            return UISwipeActionsConfiguration(actions: [delete, deleteRemind])
        }
        
        return UISwipeActionsConfiguration(actions: [delete, remind])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let share = shareMemoAction(at: indexPath)
        let important = setImportantAction(at: indexPath)
        let removeImportant = removeImportantAction(at: indexPath)
        
        if importantIsSetAtIndex(indexPath: indexPath) == true {
            return UISwipeActionsConfiguration(actions: [share, removeImportant])
        }
        
        return UISwipeActionsConfiguration(actions: [share, important])
    }
    
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
        let isReminder = memo.value(forKey: "isReminder") as? Bool
        let isImportant = memo.value(forKey: "isImportant") as? Bool
        let hashTag = memo.value(forKey: "hashTag") as? String ?? "not defined"
        let color = memo.value(forKey: "color") as? String ?? "white"
        
        cell.backgroundColor = UIColor.getRandomColorFromString(color: color)
        let defaultFontSize = Dimension.shared.fontMediumSize

        cell.content.font = UIFont.systemFont(ofSize: defaultFontSize, weight: .medium)
        cell.content.text = content
        
        if defaults.bool(forKey: Resource.Defaults.displayDateTime) == true {
            let dateString = DatetimeUtil().convertDatetime(date: dateEdited)
            let detailTextSize = (defaultFontSize / 1.2).rounded(.down)
            
            cell.dateEdited.font = UIFont.systemFont(ofSize: detailTextSize)
            cell.dateEdited.text = dateString

            cell.hashTag.font = UIFont.systemFont(ofSize: detailTextSize)
            cell.hashTag.text = "#\(hashTag)"
            
        } else {
            cell.dateEdited.text = ""
        }
        
        if isReminder == true {
            cell.reminderIsSetIcon.isHidden = false
        } else {
            cell.reminderIsSetIcon.isHidden = true
        }
        
        if isImportant == true {
            cell.importantIcon.isHidden = false
        } else {
            cell.importantIcon.isHidden = true
        }
        
        cell.accessoryType = .none
        
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
        let isEdited = memo.value(forKey: "isEdited") as? Bool
        let isReminder = memo.value(forKey: "isReminder") as? Bool
        let dateReminder = memo.value(forKey: "dateReminder") as? Double ?? 0
        let color = memo.value(forKey: "color") as? String ?? "white"
        
        let dateCreatedString = DatetimeUtil().convertDatetime(date: dateCreated)
        let dateEditedString = DatetimeUtil().convertDatetime(date: dateEdited)
        let dateReminderString = DatetimeUtil().convertDatetime(date: dateReminder)
        
        updateView.backgroundColor = color
        updateView.dateLabelHeader = dateEditedString
        updateView.content = content!
        updateView.hashTag = hashTag!
        updateView.dateCreated = dateCreatedString
        updateView.dateEdited = dateEditedString
        updateView.isEdited = isEdited!
        updateView.isReminder = isReminder!
        updateView.dateReminder = dateReminderString
        updateView.index = indexPath.row
        
        self.navigationController?.pushViewController(updateView, animated: true)
    }
}

extension MemoViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

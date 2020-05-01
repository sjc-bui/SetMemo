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
import LocalAuthentication
import SwiftKeychainWrapper
import SmartToast

class MemoViewController: UICollectionViewController {
    
    var memoData: [Memo] = []
    var filterMemoData: [Memo] = []
    
    let notification = UINotificationFeedbackGenerator()
    let searchController = UISearchController(searchResultsController: nil)
    let emptyView = EmptyMemoView()
    let datePicker = UIDatePicker()
    let defaults = UserDefaults.standard
    let keychain = KeychainWrapper.standard
    
    let inset: CGFloat = 12
    let minimumLineSpacing: CGFloat = 12
    let minimumInteritemSpacing: CGFloat = 12
    var cellsPerRow: Int?
    let reuseCellId = "cellId"
    let themes = Themes()
    let theme = ThemesViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setBackButtonTitle(title: nil)
        setupView()
    }
    
    func setupView() {
        isLandscape()
        collectionView.frame = view.frame
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.collectionView.register(MemoViewCell.self, forCellWithReuseIdentifier: reuseCellId)
        view.addSubview(collectionView)
    }
    
    func isLandscape() {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation.isLandscape {
                cellsPerRow = 5
                
            } else {
                cellsPerRow = 4
            }
            
        } else {
            cellsPerRow = 2
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        resetIconBadges()
        requestReviewApp()
        setupDynamicElements()
    }
    
    func setupDynamicElements() {
        
        if theme.darkModeEnabled() == false {
            themes.setupDefaultTheme()
            setupDefaultPersistentNavigationBar()
            
            collectionView.backgroundColor = InterfaceColors.viewBackgroundColor
            
        } else {
            themes.setupPureDarkTheme()
            setupDarkPersistentNavigationBar()
            
            collectionView.backgroundColor = InterfaceColors.viewBackgroundColor
        }
    }
    
    func setupDefaultPersistentNavigationBar() {
        navigationController?.toolbar.barTintColor = InterfaceColors.navigationBarColor
        navigationController?.navigationBar.backgroundColor = InterfaceColors.navigationBarColor
        navigationController?.navigationBar.barTintColor = InterfaceColors.navigationBarColor
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setupDarkPersistentNavigationBar() {
        navigationController?.toolbar.barTintColor = InterfaceColors.navigationBarColor
        navigationController?.navigationBar.backgroundColor = InterfaceColors.navigationBarColor
        navigationController?.navigationBar.barTintColor = InterfaceColors.navigationBarColor
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSearchBar()
        fetchMemoFromCoreData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationItem.searchController = nil
    }
    
    func requestReviewApp() {
        
        let appVersion = Bundle().appVersion
        
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
        navigationController?.navigationBar.setColors(background: UIColor.secondarySystemBackground, text: Colors.shared.defaultTintColor)
        extendedLayoutIncludesOpaqueBars = true
    }
    
    func setupBarButton() {
        
        let createButton = UIBarButtonItem(image: Resource.Images.createButton, style: .plain, target: self, action: #selector(createNewMemo))
        let settingButton = UIBarButtonItem(image: Resource.Images.settingButton, style: .plain, target: self, action: #selector(settingPage))
        let flexibleSpace = UIBarButtonItem.flexibleSpace
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        let countMemo = UILabel(frame: .zero)
        countMemo.textColor = Colors.shared.defaultTintColor
        countMemo.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        countMemo.text = memoCountString(total: memoData.count)
        countMemo.textDropShadow()
        
        let sortBtn = UIButton(frame: .zero)
        let sortButtonTitle = showSortType()
        sortBtn.setTitle(sortButtonTitle, for: .normal)
        sortBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        sortBtn.titleLabel?.textDropShadow()
        sortBtn.setTitleColor(Colors.shared.defaultTintColor, for: .normal)
        sortBtn.addTarget(self, action: #selector(sortBy), for: .touchUpInside)
        
        settingButton.tintColor = Colors.shared.defaultTintColor
        createButton.tintColor = Colors.shared.defaultTintColor
        
        var items: [UIBarButtonItem] = []
        
        if memoData.count != 0 {
            items = [
            settingButton,
            flexibleSpace,
            UIBarButtonItem(customView: countMemo),
            flexibleSpace,
            UIBarButtonItem(customView: sortBtn),
            flexibleSpace,
            createButton
            ]
        } else {
            items = [
            settingButton,
            flexibleSpace,
            UIBarButtonItem(customView: countMemo),
            flexibleSpace,
            createButton
            ]
        }
        
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
            
        } else if sortBy == Resource.SortBy.color {
            sortText = "SortByColor".localized
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
            collectionView.reloadData()
            
        } else if searchController.searchBar.selectedScopeButtonIndex == 1 {
            filterMemoData = memoData.filter({ (memo: Memo) -> Bool in
                memo.hashTag!.lowercased().contains(searchText.lowercased())
            })
            collectionView.reloadData()
        }
    }
    
    @objc func sortBy() {
        
        DeviceControl().feedbackOnPress()
        self.showAlert(title: nil, message: nil, alertStyle: .actionSheet, actionTitles: ["SortByDateCreated".localized, "SortByDateEdited".localized, "SortByColor".localized, "SortByTitle".localized, "Cancel".localized], actionStyles: [.default, .default, .default, .default, .cancel], actions: [
            { _ in
                self.defaults.set(Resource.SortBy.dateCreated, forKey: Resource.Defaults.sortBy)
                self.fetchMemoFromCoreData()
            },
            { _ in
                self.defaults.set(Resource.SortBy.dateEdited, forKey: Resource.Defaults.sortBy)
                self.fetchMemoFromCoreData()
            },
            { _ in
                self.defaults.set(Resource.SortBy.color, forKey: Resource.Defaults.sortBy)
                self.fetchMemoFromCoreData()
            },
            { _ in
                self.defaults.set(Resource.SortBy.title, forKey: Resource.Defaults.sortBy)
                self.fetchMemoFromCoreData()
            },
            { _ in
                print("cancel")
            }
        ])
    }
    
    @objc func createNewMemo() {
        DeviceControl().feedbackOnPress()
        self.push(viewController: WriteMemoController())
    }
    
    @objc func settingPage() {
        DeviceControl().feedbackOnPress()
        self.push(viewController: SettingViewController(style: .insetGrouped))
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
            
        } else if sortBy == Resource.SortBy.color {
            sortDescriptor = NSSortDescriptor(key: Resource.SortBy.color, ascending: false)
        }
        
        fetchRequest.sortDescriptors = [sortDescriptor] as? [NSSortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "temporarilyDelete = %d", false)
        
        do {
            self.memoData = try managedContext.fetch(fetchRequest) as! [Memo]
            self.setupBarButton()
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func memoCountString(total: Int) -> String {
        if total != 0 {
            return String(format: "TotalMemo".localized, total)
        }
        return "EmptyLabel".localized
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
    
    func lockIsSetAtIndex(indexPath: IndexPath) -> Bool {
        
        if isFiltering() == true {
            if filterMemoData[indexPath.row].isLocked == true {
                return true
            } else {
                return false
            }
            
        } else {
            if memoData[indexPath.row].isLocked == true {
                return true
            } else {
                return false
            }
        }
    }
    
    func updateLocked(lockThisMemo: Bool, indexPath: IndexPath) {
        
        if isFiltering() == true {
            let filterData = filterMemoData[indexPath.row]
            filterData.isLocked = lockThisMemo
            
        } else if isFiltering() == false {
            let memo = memoData[indexPath.row]
            memo.isLocked = lockThisMemo
        }
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        do {
            try context?.save()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        var lockLabel: String?
        
        if lockThisMemo {
            lockLabel = "Locked".localized
            
        } else {
            lockLabel = "Unlocked".localized
        }
        
        ShowToast.toast(message: lockLabel, duration: 1.0)
    }
    
    func handleLockMemoWithBiometrics(reason: String, lockThisMemo: Bool, indexPath: IndexPath) {
        
        // using Local Authentication.
        let context = LAContext()
        context.localizedFallbackTitle = "EnterPassword".localized
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
                
                DispatchQueue.main.async {
                    
                    if success {
                        self.updateLocked(lockThisMemo: lockThisMemo, indexPath: indexPath)
                        print("lock & unlock memo")
                        
                    } else {
                        guard let err = evaluateError else {
                            return
                        }
                        
                        switch err {
                        case LAError.userCancel:
                            print("user cancel")
                        case LAError.userFallback:
                            self.enterPasswordToLockOrUnlock(lockThisMemo: lockThisMemo, indexPath: indexPath)
                        default:
                            print("not implement")
                        }
                    }
                }
            }
            
        } else {
            enterPasswordToLockOrUnlock(lockThisMemo: lockThisMemo, indexPath: indexPath)
        }
    }
    
    func enterPasswordToLockOrUnlock(lockThisMemo: Bool, indexPath: IndexPath) {
        
        var alertMessage = ""
        var alertTitle = ""
        
        if lockThisMemo {
            alertTitle = "LockMemo".localized
            alertMessage = "EnterPassToLockMemo".localized
            
        } else {
            alertTitle = "UnlockMemo".localized
            alertMessage = "EnterPassToUnlockMemo".localized
        }
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "******"
            textField.isSecureTextEntry = true
        }
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            
            let inputPassword = alertController.textFields?.first?.text ?? ""
            let keychainPassword = self.keychain.string(forKey: Resource.Defaults.passwordToUseBiometric) ?? ""
            
            if inputPassword.elementsEqual(keychainPassword) == true {
                self.updateLocked(lockThisMemo: lockThisMemo, indexPath: indexPath)
                
            } else {
                ShowToast.toast(message: "PasswordIncorrect".localized, duration: 1.0)
            }
        }
        
        alertController.addAction(cancel)
        alertController.addAction(ok)
        
        if defaults.bool(forKey: Resource.Defaults.useDarkMode) == true {
            alertController.overrideUserInterfaceStyle = .dark
            
        } else {
            alertController.overrideUserInterfaceStyle = .light
        }
        
        alertController.view.tintColor = Colors.shared.defaultTintColor
        
        present(alertController, animated: true, completion: nil)
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
        
        ShowToast.toast(message: "ReminderDeleted".localized, duration: 1.0)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Delete memo
    func deleteMemoHandle(indexPath: IndexPath) {
        
        if defaults.bool(forKey: Resource.Defaults.firstTimeDeleted) == true {
            
            self.showAlert(title: "DeletedMemoMoved".localized, message: "DeletedMemoMovedMess".localized, alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [
                { _ in
                    self.defaults.set(false, forKey: Resource.Defaults.firstTimeDeleted)
                }
            ])
        }
        
        if isFiltering() == true {
            let filteredMemo = filterMemoData[indexPath.row]
            
            // remove pending notification.
            let notificationUUID = filteredMemo.notificationUUID ?? "empty"
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [notificationUUID])
            
            filteredMemo.setValue(true, forKey: "temporarilyDelete")
            filteredMemo.setValue("cleared", forKey: "notificationUUID")
            filteredMemo.setValue(false, forKey: "isReminder")
            filteredMemo.setValue(0.0, forKey: "dateReminder")
            filterMemoData.remove(at: indexPath.row)
            
        } else {
            let memo = memoData[indexPath.row]
            
            let noficationUUID = memo.notificationUUID ?? "empty"
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [noficationUUID])
            
            memo.setValue(true, forKey: "temporarilyDelete")
            memo.setValue("cleared", forKey: "notificationUUID")
            memo.setValue(false, forKey: "isReminder")
            memo.setValue(0.0, forKey: "dateReminder")
            memoData.remove(at: indexPath.row)
            
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            try managedContext.save()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
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
        
        if defaults.bool(forKey: Resource.Defaults.useDarkMode) == true {
            activityViewController.overrideUserInterfaceStyle = .dark
            
        } else {
            activityViewController.overrideUserInterfaceStyle = .light
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if theme.darkModeEnabled() {
            return .lightContent
            
        } else {
            return .darkContent
        }
    }
}

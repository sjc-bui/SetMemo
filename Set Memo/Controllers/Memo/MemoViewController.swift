//
//  MemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

class MemoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, GADBannerViewDelegate {
    var tableView: UITableView = UITableView()
    var dt: Results<MemoItem>?
    let notification = UINotificationFeedbackGenerator()
    let searchController = UISearchController(searchResultsController: nil)
    let emptyView = EmptyMemoView()
    let defaults = UserDefaults.standard
    
    // Google Ads
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.whiteColor
        configureAds()
        // request user review app
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableView()
        fetchMemoFromDB()
        setupNavigation()
        //configureSearchBar()
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
    
    func configureAds() {
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = Const.UnitID
        bannerView.rootViewController = self
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        bannerView.load(GADRequest())
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
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
        self.navigationItem.title = NSLocalizedString("Memo", comment: "")
        self.navigationController?.navigationBar.tintColor = Colors.red2
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        
        // custom Right bar button
        let createButton = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(createNewMemo))
        let sortButton = UIBarButtonItem(image: UIImage(named: "sort"), style: .plain, target: self, action: #selector(sortBy))
        let settingButton = UIBarButtonItem(image: UIImage(named: "setting"), style: .plain, target: self, action: #selector(settingPage))
        self.navigationItem.rightBarButtonItems = [createButton, sortButton]
        self.navigationItem.leftBarButtonItem = settingButton
    }
    
    func configureSearchBar() {
        searchController.searchBar.placeholder = "Search !"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    @objc func sortBy() {
        DeviceControl().feedbackOnPress()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let sortByDateCreated = UIAlertAction(title: NSLocalizedString("SortByDateCreated", comment: ""), style: .default, handler: { (action) in
            print("sort by date created")
            self.defaults.set("dateCreated", forKey: Defaults.sortBy)
            self.fetchMemoFromDB()
        })
        
        let sortByDateEdited = UIAlertAction(title: NSLocalizedString("SortByDateEdited", comment: ""), style: .default) { (action) in
            print("sort by date edited")
            self.defaults.set("dateEdited", forKey: Defaults.sortBy)
            self.fetchMemoFromDB()
        }
        
        let sortByTitle = UIAlertAction(title: NSLocalizedString("SortByTitle", comment: ""), style: .default, handler: { (action) in
            print("sort by title")
            self.defaults.set("title", forKey: Defaults.sortBy)
            self.fetchMemoFromDB()
        })
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        let target = "titleTextColor"
        sortByDateCreated.setValue(Colors.red2, forKey: target)
        sortByDateEdited.setValue(Colors.red2, forKey: target)
        sortByTitle.setValue(Colors.red2, forKey: target)
        cancel.setValue(Colors.red2, forKey: target)
        
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
        let sortBy = defaults.string(forKey: Defaults.sortBy)
        var sortKeyPath: String?
        
        if sortBy == "dateCreated" {
            sortKeyPath = "dateCreated"
        } else if sortBy == "title" {
            sortKeyPath = "content"
        } else if sortBy == "dateEdited" {
            sortKeyPath = "dateEdited"
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
        let defaultFontSize = defaults.float(forKey: Defaults.fontSize)
        let myCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        myCell.backgroundColor = .clear
        myCell.textLabel?.text = dt![indexPath.row].content
        myCell.textLabel?.numberOfLines = 2
        myCell.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(defaultFontSize), weight: .regular)
        
        if defaults.bool(forKey: Defaults.displayDateTime) == true {
            let detailTextSize = (defaultFontSize / 1.5).rounded(.down)
            myCell.detailTextLabel?.text = DatetimeUtil().convertDatetime(datetime: dt![indexPath.row].dateEdited)
            myCell.detailTextLabel?.font = UIFont.systemFont(ofSize: CGFloat(detailTextSize))
        } else {
            myCell.detailTextLabel?.text = ""
        }
        
        myCell.tintColor = Colors.orangeColor
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
    
    // MARK: - Custom BannerView
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        tableView.tableHeaderView?.frame = bannerView.frame
        tableView.tableHeaderView = bannerView
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}

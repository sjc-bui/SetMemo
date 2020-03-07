//
//  MemoViewController.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/28.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import RealmSwift

class MemoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView = UITableView()
    var dt: Results<MemoItem>?
    let notification = UINotificationFeedbackGenerator()
    let emptyView = EmptyMemoView()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.whiteColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableView()
        
        let realm = try! Realm()
        dt = realm.objects(MemoItem.self).sorted(byKeyPath: "created", ascending: false)
        self.tableView.reloadData()
        setupNavigation()
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
        self.updateMemoItemCount()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.primaryText]
        self.navigationController?.navigationBar.tintColor = Colors.blueColor
        
        // custom Right bar button
        let createButton = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(CreateNewMemo))
        self.navigationItem.rightBarButtonItem = createButton
    }
    
    private func updateMemoItemCount() {
        let totalMemo: Int = dt!.count
        self.navigationItem.title = CustomTextView().navigationTitle(total: totalMemo)
    }
    
    @objc func CreateNewMemo(sender: UIButton) {
        DeviceControl().feedbackOnPress()
        self.navigationController?.pushViewController(WriteMemoController(), animated: true)
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
        //let myCell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let myCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        myCell.backgroundColor = .clear
        myCell.textLabel?.text = dt![indexPath.row].content
        myCell.textLabel?.numberOfLines = 2
        myCell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        myCell.textLabel?.textColor = Colors.darkColor
        
        if defaults.bool(forKey: Defaults.displayDateTime) == true {
            myCell.detailTextLabel?.text = DatetimeUtil().convertDatetime(datetime: dt![indexPath.row].created)
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
            self.updateMemoItemCount()
        }
    }
}

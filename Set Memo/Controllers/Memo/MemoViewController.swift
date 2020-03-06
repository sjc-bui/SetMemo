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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        tableView.pin(to: view)
        tableView.register(MyCell.self, forCellReuseIdentifier: "cellId")
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let realm = try! Realm()
        dt = realm.objects(MemoItem.self).sorted(byKeyPath: "created", ascending: false)
        self.tableView.reloadData()
        setupNavigation()
    }
    
    // table view configure
    private func configureTableView() {
        view.addSubview(tableView)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigation() {
        self.updateMemoItemCount()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.007843137255, green: 0.3137254902, blue: 0.7725490196, alpha: 1)
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MyCell
        myCell.backgroundColor = .clear
        myCell.content.text = dt![indexPath.row].content
        myCell.create.text = DatetimeUtil().convertDatetime(datetime: dt![indexPath.row].created)
        myCell.tintColor = .orange
        myCell.accessoryType = dt![indexPath.row].isImportant ? .checkmark : .none
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

// MARK: -Custom TableViewCell
class MyCell: UITableViewCell {
    var myTableViewController: MemoViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    // set up view cell constraint
    func setupView() {
        addSubview(cellView)
        cellView.addSubview(content)
        cellView.addSubview(create)
        self.selectionStyle = .none
        
        // Set constrain for cellView
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: self.topAnchor),
            cellView.leftAnchor.constraint(equalTo: self.leftAnchor),
            cellView.rightAnchor.constraint(equalTo: self.rightAnchor),
            cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        // content constraint
        content.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: 20).isActive = true
        content.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 0).isActive = true
        content.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -20).isActive = true
        content.heightAnchor.constraint(equalTo: cellView.heightAnchor, constant: -24).isActive = true
        
        // create constraint
        create.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: 20).isActive = true
        create.topAnchor.constraint(equalTo: content.bottomAnchor).isActive = true
        create.heightAnchor.constraint(equalToConstant: 15).isActive = true
        create.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true
    }
    
    // create view cell
    let cellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // create label inside view cell
    let content: UILabel = {
        let label = paddingLabel()
        label.text = "Loading..."
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let create: UILabel = {
        let label = paddingLabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

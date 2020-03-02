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
    var tableView = UITableView()
    var dt: Results<MemoItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        configureTableView()
        tableView.pin(to: view)
        tableView.register(MyCell.self, forCellReuseIdentifier: "cellId")
        
        let backgroundImage = UIImageView(frame: .zero)
        self.view.insertSubview(backgroundImage, at: 0)
        backgroundImage.pinImageView(to: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let realm = try! Realm()
        dt = realm.objects(MemoItem.self).sorted(byKeyPath: "created", ascending: false)
        self.tableView.reloadData()
    }
    
    // table view configure
    private func configureTableView() {
        view.addSubview(tableView)
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = .lightGray
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigation() {
        // Memo(int)
        self.navigationItem.title = String(format: NSLocalizedString("TotalMemo", comment: ""), 3)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // custom Right bar button
        let createButton = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(CreateNewMemo))
        let deleteButton = UIBarButtonItem(image: UIImage(named: "trash"), style: .plain, target: self, action: #selector(DeleteAll))
        self.navigationItem.leftBarButtonItem = deleteButton
        self.navigationItem.rightBarButtonItem = createButton
    }
    
    @objc func DeleteAll() {
        let deleteAllAlert = UIAlertController(title: "", message: NSLocalizedString("DeleteAll", comment: ""), preferredStyle: .alert)
        let delete = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { action in
            let realm = try! Realm()
            do {
                try realm.write {
                    realm.delete(self.dt!)
                }
            } catch {
                print(error)
            }
            
            self.tableView.reloadData()
        })
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        deleteAllAlert.addAction(cancel)
        deleteAllAlert.addAction(delete)
        
        if dt?.count != 0 {
            self.present(deleteAllAlert, animated: true)
        }
    }
    
    @objc func CreateNewMemo(sender: UIButton) {
        self.navigationController?.pushViewController(NewMemoViewController(), animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dt!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MyCell
        myCell.backgroundColor = .clear
        myCell.content.text = dt![indexPath.row].content
        myCell.create.text = "expect"
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
        content.topAnchor.constraint(equalTo: cellView.topAnchor).isActive = true
        content.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -40).isActive = true
        content.bottomAnchor.constraint(equalTo: create.topAnchor).isActive = true
        
        // create constraint
        create.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: 20).isActive = true
        create.topAnchor.constraint(equalTo: content.bottomAnchor).isActive = true
        create.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -40).isActive = true
        create.bottomAnchor.constraint(equalTo: cellView.bottomAnchor).isActive = true
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
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let create: UILabel = {
        let label = paddingLabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

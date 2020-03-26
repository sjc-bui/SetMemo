//
//  RecentlyDeletedController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/26.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import RealmSwift

class RecentlyDeletedController: UITableViewController {
    var dt: Results<MemoItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "RecentlyDeleted".localized
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        fetchMemoFromDB()
    }
    
    func setupNavigation() {
        self.navigationController?.navigationBar.tintColor = Colors.shared.accentColor
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        extendedLayoutIncludesOpaqueBars = true
    }
    
    func fetchMemoFromDB() {
        dt = RealmServices.shared.read(MemoItem.self, temporarilyDelete: true).sorted(byKeyPath: Resource.SortBy.dateEdited, ascending: false)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dt!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultFontSize: Double = 16
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        cell.backgroundColor = .clear
        cell.textLabel?.text = dt![indexPath.row].content
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(defaultFontSize), weight: .regular)
        
        cell.detailTextLabel?.text = DatetimeUtil().convertDatetime(datetime: dt![indexPath.row].dateEdited)
        
        cell.tintColor = Colors.shared.orangeColor
        cell.accessoryType = .none
        
        cell.contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longTapHandle(sender:))))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
    }
    
    @objc func longTapHandle(sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: location)
        
        let alertSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let restoreButton = UIAlertAction(title: "Restore".localized, style: .default) { (action) in
            let item = self.dt![indexPath!.row]
            let realm = try! Realm()
            let memoItem = realm.objects(MemoItem.self).filter("id = %@", item.id).first
            do {
                try realm.write({
                    memoItem!.temporarilyDelete = false
                    memoItem?.dateEdited = Date()
                })
            } catch {
                print(error)
            }
            
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        }
        let deleteButton = UIAlertAction(title: "Delete".localized, style: .default) { (action) in
            print("Delete")
        }
        let cancelButton = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        let target = "titleTextColor"
        restoreButton.setValue(Colors.shared.accentColor, forKey: target)
        deleteButton.setValue(Colors.shared.accentColor, forKey: target)
        cancelButton.setValue(Colors.shared.accentColor, forKey: target)
        
        alertSheetController.addAction(restoreButton)
        alertSheetController.addAction(deleteButton)
        alertSheetController.addAction(cancelButton)
        
        alertSheetController.popoverPresentationController?.sourceView = self.view
        alertSheetController.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        let screen = UIScreen.main.bounds
        alertSheetController.popoverPresentationController?.sourceRect = CGRect(x: screen.size.width / 2, y: screen.size.height, width: 1.0, height: 1.0)
        
        DispatchQueue.main.async {
            self.present(alertSheetController, animated: true, completion: nil)
        }
    }
}
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
    var data: [MemoItem] = []
    
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
        data = RealmServices.shared.read(MemoItem.self, temporarilyDelete: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultFontSize: Double = 16
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        cell.textLabel?.text = data[indexPath.row].content
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(defaultFontSize), weight: .regular)
        
        cell.detailTextLabel?.text = DatetimeUtil().convertDatetime(datetime: data[indexPath.row].dateEdited)
        
        cell.tintColor = Colors.shared.orangeColor
        cell.accessoryType = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectedBackground()
        tapHandler(indexPath: indexPath)
    }
    
    func tapHandler(indexPath: IndexPath) {
        let alertSheetController = UIAlertController(title: "RecentlyDeletedMemo".localized, message: "RecoverBodyContent".localized, preferredStyle: .actionSheet)
        
        let recoverButton = UIAlertAction(title: "Recover".localized, style: .default) { (action) in
            let item = self.data[indexPath.row]
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
            
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let deleteButton = UIAlertAction(title: "Delete".localized, style: .default) { (action) in
            let item = self.data[indexPath.row]
            RealmServices.shared.delete(item)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let cancelButton = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        let target = "titleTextColor"
        recoverButton.setValue(Colors.shared.accentColor, forKey: target)
        deleteButton.setValue(Colors.shared.accentColor, forKey: target)
        cancelButton.setValue(Colors.shared.accentColor, forKey: target)
        
        alertSheetController.addAction(recoverButton)
        alertSheetController.addAction(deleteButton)
        alertSheetController.addAction(cancelButton)
        
        alertSheetController.popoverPresentationController?.sourceView = self.view
        alertSheetController.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        let screen = UIScreen.main.bounds
        alertSheetController.popoverPresentationController?.sourceRect = CGRect(x: screen.size.width / 2, y: screen.size.height, width: 1.0, height: 1.0)
        
        if !(navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
            DeviceControl().feedbackOnPress()
            self.present(alertSheetController, animated: true, completion: nil)
        }
    }
}

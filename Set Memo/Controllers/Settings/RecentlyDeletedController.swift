//
//  RecentlyDeletedController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/26.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import CoreData

class RecentlyDeletedController: UITableViewController {
    var memoData: [Memo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "RecentlyDeleted".localized
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        fetchMemoFromDB()
        tableView.tableFooterView = UIView()
    }
    
    func setupNavigation() {
        self.navigationController?.navigationBar.tintColor = Colors.shared.accentColor
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        extendedLayoutIncludesOpaqueBars = true
    }
    
    func fetchMemoFromDB() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Memo")
        let sortDescriptor: NSSortDescriptor?
        sortDescriptor = NSSortDescriptor(key: Resource.SortBy.dateEdited, ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor] as? [NSSortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "\(Resource.FilterBy.temporarilyDelete) = %d", true)
        
        do {
            self.memoData = try managedContext?.fetch(fetchRequest) as! [Memo]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        let memo = memoData[indexPath.row]
        
        let content = memo.value(forKey: "content") as? String
        let dateEdited = memo.value(forKey: "dateEdited") as? Double ?? 0
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: Dimension.shared.fontMediumSize, weight: .medium)
        cell.textLabel?.numberOfLines = 1
        cell.textLabel?.textDropShadow()
        cell.textLabel?.text = content
        
        let dateString = DatetimeUtil().convertDatetime(date: dateEdited)
        cell.detailTextLabel!.text = "\(dateString)"
        cell.detailTextLabel?.textColor = Colors.shared.systemGrayColor
        cell.detailTextLabel?.textDropShadow()
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: Dimension.shared.fontSmallSize, weight: .regular)
        cell.accessoryType = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectedBackground()
        tapHandler(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Delete".localized) { (action, view, completion) in
            self.showAlertOnDelete(indexPath: indexPath)
            completion(true)
        }
        action.image = Resource.Images.trashButton
        action.backgroundColor = .red
        return action
    }
    
    func showAlertOnDelete(indexPath: IndexPath) {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: Resource.Defaults.showAlertOnDelete) == true {
            let alertController = UIAlertController(title: "Confirm".localized, message: "ConfirmDeleteMessage".localized, preferredStyle: .alert)
            
            let deleteBtn = UIAlertAction(title: "Delete".localized, style: .destructive) { (action) in
                self.deleteMemo(indexPath: indexPath)
            }
            let cancelBtn = UIAlertAction(title: "Cancel".localized, style: .default, handler: nil)
            
            alertController.view.tintColor = Colors.shared.accentColor
            alertController.addAction(cancelBtn)
            alertController.addAction(deleteBtn)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else if defaults.bool(forKey: Resource.Defaults.showAlertOnDelete) == false {
            // no alert on delete
            self.deleteMemo(indexPath: indexPath)
        }
    }
    
    func deleteMemo(indexPath: IndexPath) {
        let item = self.memoData[indexPath.row]
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        managedContext?.delete(item)
        
        self.memoData.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        
        do {
            try managedContext?.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let recover = recoverAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [recover])
    }
    
    func recoverAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Recover") { (action, view, completion) in
            self.recoverMemo(indexPath: indexPath)
            completion(true)
        }
        action.image = Resource.Images.recoverButton
        action.backgroundColor = Colors.shared.accentColor
        
        return action
    }
    
    func recoverMemo(indexPath: IndexPath) {
        let item = self.memoData[indexPath.row]
        
        item.setValue(false, forKey: "temporarilyDelete")
        memoData.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        do {
            try managedContext?.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func tapHandler(indexPath: IndexPath) {
        let alertSheetController = UIAlertController(title: "RecentlyDeletedMemo".localized, message: "RecoverBodyContent".localized, preferredStyle: .actionSheet)
        
        let recoverButton = UIAlertAction(title: "Recover".localized, style: .default) { (action) in
            self.recoverMemo(indexPath: indexPath)
        }
        let deleteButton = UIAlertAction(title: "Delete".localized, style: .default) { (action) in
            self.showAlertOnDelete(indexPath: indexPath)
        }
        let cancelButton = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        alertSheetController.view.tintColor = Colors.shared.accentColor
        
        alertSheetController.addAction(recoverButton)
        alertSheetController.addAction(deleteButton)
        alertSheetController.addAction(cancelButton)
        alertSheetController.pruneNegativeWidthConstraints()
        
        if let popoverController = alertSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.any]
        }
        
        if !(navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
            DeviceControl().feedbackOnPress()
            self.present(alertSheetController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titleHeaderMessage = "AutoDeleteMemo".localized
        return titleHeaderMessage
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .secondarySystemBackground
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: Dimension.shared.fontSmallSize, weight: .regular)
        header.textLabel?.textAlignment = NSTextAlignment.center
        header.textLabel?.numberOfLines = 0
        header.textLabel?.textColor = UIColor.systemGray
    }
}

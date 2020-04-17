//
//  RecentlyDeletedController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/26.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import CoreData

class RecentlyDeletedController: UICollectionViewController {
    
    var memoData: [Memo] = []
    fileprivate let cellID = "cellId"
    let defaults = UserDefaults.standard
    
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    var cellsPerRow = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "RecentlyDeleted".localized
        setupView()
    }
    
    func setupView() {
        isLandscape()
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .always
        self.collectionView.register(MemoViewCell.self, forCellWithReuseIdentifier: "cellId")
    }
    
    func isLandscape() {
        print("Call first")
        if UIDevice.current.orientation.isLandscape {
            cellsPerRow = 3
        } else {
            cellsPerRow = 2
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMemoFromDB()
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
                self.collectionView.reloadData()
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
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
            
            self.showAlert(title: "Confirm".localized, message: "ConfirmDeleteMessage".localized, alertStyle: .alert, actionTitles: ["Cancel".localized, "Delete".localized], actionStyles: [.cancel, .destructive], actions: [
                { _ in
                    print("Cancel delete")
                },
                { _ in
                    self.deleteMemo(indexPath: indexPath)
                }
            ])
            
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
        
        do {
            try managedContext?.save()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func recoverAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Recover") { (action, view, completion) in
            self.recoverMemo(indexPath: indexPath)
            completion(true)
        }
        
        action.image = Resource.Images.recoverButton
        action.backgroundColor = .systemGreen
        
        return action
    }
    
    func recoverMemo(indexPath: IndexPath) {
        let item = self.memoData[indexPath.row]
        
        item.setValue(false, forKey: "temporarilyDelete")
        memoData.remove(at: indexPath.row)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        do {
            try managedContext?.save()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func tapHandler(indexPath: IndexPath) {
        
        DeviceControl().feedbackOnPress()
        self.showAlert(title: "RecentlyDeletedMemo".localized, message: "RecoverBodyContent".localized, alertStyle: .actionSheet, actionTitles: ["Recover".localized, "Delete".localized, "Cancel".localized], actionStyles: [.default, .default, .cancel], actions: [
            { _ in
                self.recoverMemo(indexPath: indexPath)
            },
            { _ in
                self.showAlertOnDelete(indexPath: indexPath)
            },
            { _ in
                print("Cancelled recover or delete")
            }
        ])
        
//        if !(navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
//            self.present(alertSheetController, animated: true, completion: nil)
//        }
    }
}

extension RecentlyDeletedController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memoData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MemoViewCell
        
        let memo = memoData[indexPath.row]
        
        let content = memo.value(forKey: "content") as? String
        let dateEdited = memo.value(forKey: "dateEdited") as? Double ?? 0
        let hashTag = memo.value(forKey: "hashTag") as? String ?? "not defined"
        let color = memo.value(forKey: "color") as? String ?? "white"
        
        cell.content.font = UIFont.systemFont(ofSize: Dimension.shared.fontMediumSize, weight: .medium)
        cell.content.text = content
        
        let dateString = DatetimeUtil().convertDatetime(date: dateEdited)
        cell.dateEdited.text = "\(dateString)"
        cell.dateEdited.font = UIFont.systemFont(ofSize: Dimension.shared.subLabelSize, weight: .regular)
        
        cell.hashTag.text = "#\(hashTag)"
        cell.hashTag.font = UIFont.systemFont(ofSize: Dimension.shared.subLabelSize, weight: .regular)
        cell.backgroundColor = UIColor.getRandomColorFromString(color: color)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        print("id - \(indexPath.row)")
        tapHandler(indexPath: indexPath)
    }
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let titleHeaderMessage = "AutoDeleteMemo".localized
//        return titleHeaderMessage
//    }
    
//    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let recover = recoverAction(at: indexPath)
//        return UISwipeActionsConfiguration(actions: [recover])
//    }
//
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let delete = deleteAction(at: indexPath)
//        return UISwipeActionsConfiguration(actions: [delete])
//    }
//
}

extension RecentlyDeletedController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        
        return CGSize(width: itemWidth, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
}

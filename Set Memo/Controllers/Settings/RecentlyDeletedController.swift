//
//  RecentlyDeletedController.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/26.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import CoreData
import XLActionController
import EMAlertController

class RecentlyDeletedController: UICollectionViewController {
    
    var memoData: [Memo] = []
    fileprivate let cellID = "cellId"
    let defaults = UserDefaults.standard
    
    let inset: CGFloat = 12
    let minimumLineSpacing: CGFloat = 12
    let minimumInteritemSpacing: CGFloat = 12
    var cellsPerRow = 2
    let themes = Themes()
    let theme = ThemesViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "RecentlyDeleted".localized
        setupView()
    }
    
    func setupView() {
        isLandscape()
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .always
        self.collectionView.register(MemoViewCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    func isLandscape() {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation.isLandscape {
                cellsPerRow = 5
                
            } else {
                cellsPerRow = 4
            }
            
        } else {
            if UIDevice.current.orientation.isLandscape {
                cellsPerRow = 4
                
            } else {
                cellsPerRow = 2
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDynamicElements()
        fetchMemoFromDB()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRightBarItem()
    }
    
    func setupRightBarItem() {
        let deleteBtn = UIBarButtonItem(image: Resource.Images.trashButton, style: .plain, target: self, action: #selector(deleteAll))
        self.navigationItem.rightBarButtonItem = deleteBtn
    }
    
    @objc func deleteAll() {
        DeviceControl().feedbackOnPress()
        let alert = EMAlertController(title: nil, message: "Do you want to delete all memo in this folder?")
        
        let cancel = EMAlertAction(title: "Cancel".localized, style: .cancel)
        let delete = EMAlertAction(title: "Delete".localized, style: .normal) {
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedContext = appDelegate?.persistentContainer.viewContext
            
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Memo")
            let predicate = NSPredicate(format: "temporarilyDelete = %d", true)
            deleteFetch.predicate = predicate
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            
            do {
                try managedContext?.execute(deleteRequest)
                try managedContext?.save()
                self.pop()
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true, completion: nil)
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
        navigationController?.navigationBar.backgroundColor = InterfaceColors.navigationBarColor
        navigationController?.navigationBar.barTintColor = InterfaceColors.navigationBarColor
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setupDarkPersistentNavigationBar() {
        navigationController?.navigationBar.backgroundColor = InterfaceColors.navigationBarColor
        navigationController?.navigationBar.barTintColor = InterfaceColors.navigationBarColor
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
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
    
    func showAlertOnDelete(indexPath: IndexPath) {
        
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: Resource.Defaults.showAlertOnDelete) == true {
            
            let alert = EMAlertController(title: "Confirm".localized, message: "ConfirmDeleteMessage".localized)
            let cancel = EMAlertAction(title: "Cancel".localized, style: .cancel)
            let delete = EMAlertAction(title: "Delete".localized, style: .normal) {
                self.deleteMemo(indexPath: indexPath)
            }
            alert.addAction(cancel)
            alert.addAction(delete)
            present(alert, animated: true, completion: nil)
            
        } else if defaults.bool(forKey: Resource.Defaults.showAlertOnDelete) == false {
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
        
        let memo = memoData[indexPath.row]
        let color = memo.value(forKey: "color") as? String ?? "white"
        
        let actionController = SkypeActionController()
        actionController.backgroundColor = UIColor.getRandomColorFromString(color: color)
        
        actionController.addAction(Action("Recover".localized, style: .default, handler: { _ in
            self.recoverMemo(indexPath: indexPath)
        }))
        actionController.addAction(Action("Delete".localized, style: .default, handler: { _ in
            self.showAlertOnDelete(indexPath: indexPath)
        }))
        actionController.addAction(Action("Cancel".localized, style: .cancel, handler: nil))
        
        present(actionController, animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation.isLandscape {
                cellsPerRow = 5
            } else {
                cellsPerRow = 4
            }
            
        } else {
            if UIDevice.current.orientation.isLandscape {
                cellsPerRow = 4
                
            } else {
                cellsPerRow = 2
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if theme.darkModeEnabled() == true {
            return .lightContent
            
        } else {
            return .darkContent
        }
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
        
        let cellBackground = UIColor.getRandomColorFromString(color: color)
        cell.setCellStyle(background: cellBackground)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tapHandler(indexPath: indexPath)
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let titleHeaderMessage = "AutoDeleteMemo".localized
//        return titleHeaderMessage
//    }
}

extension RecentlyDeletedController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        
        return CGSize(width: itemWidth, height: 105)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
}

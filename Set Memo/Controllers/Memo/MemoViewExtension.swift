//
//  MemoViewExtension.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/13.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

// MARK: - Extension MemmoViewController
extension MemoViewController {
    
    @objc func showIntro(_ sender: UITapGestureRecognizer) {
        let settingViewController = SettingViewController()
        settingViewController.presentTutorial(view: self, tintColor: Colors.shared.defaultTintColor)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let updateView = UpdateMemoViewController()
        var memo = memoData[indexPath.row]
        
        if isFiltering() {
            memo = filterMemoData[indexPath.row]
            updateView.filterMemoData = filterMemoData
            updateView.isFiltering = true
        } else {
            memo = memoData[indexPath.row]
            updateView.memoData = memoData
        }
        
        let content = memo.value(forKey: "content") as? String
        let hashTag = memo.value(forKey: "hashTag") as? String
        let dateCreated = memo.value(forKey: "dateCreated") as? Double ?? 0
        let dateEdited = memo.value(forKey: "dateEdited") as? Double ?? 0
        let isEdited = memo.value(forKey: "isEdited") as? Bool
        let isReminder = memo.value(forKey: "isReminder") as? Bool
        let isLocked = memo.value(forKey: "isLocked") as? Bool
        let dateReminder = memo.value(forKey: "dateReminder") as? Double ?? 0
        let color = memo.value(forKey: "color") as? String ?? "white"
        
        let dateCreatedString = DatetimeUtil().convertDatetime(date: dateCreated)
        let dateEditedString = DatetimeUtil().convertDatetime(date: dateEdited)
        let dateReminderString = DatetimeUtil().convertDatetime(date: dateReminder)
        
        updateView.backgroundColor = color
        updateView.dateLabelHeader = dateEditedString
        updateView.content = content!
        updateView.hashTag = hashTag!
        updateView.dateCreated = dateCreatedString
        updateView.dateEdited = dateEditedString
        updateView.isEdited = isEdited!
        updateView.isReminder = isReminder!
        updateView.isLocked = isLocked!
        updateView.dateReminder = dateReminderString
        updateView.index = indexPath.row
        
        self.push(viewController: updateView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if memoData.isEmpty {
            collectionView.backgroundView = emptyView
            emptyView.showTutorialLabel.textColor = Colors.shared.defaultTintColor
            emptyView.showTutorialLabel.addTapGesture(target: self, action: #selector(showIntro(_:)))
            
        } else {
            collectionView.backgroundView = nil
            if isFiltering() {
                return filterMemoData.count
                
            } else {
                return memoData.count
            }
        }
        return memoData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCellId, for: indexPath) as! MemoViewCell
        
        var memo = memoData[indexPath.row]
        if isFiltering() {
            memo = filterMemoData[indexPath.row]
            
        } else {
            memo = memoData[indexPath.row]
        }
        
        let content = memo.value(forKey: "content") as? String
        let dateEdited = memo.value(forKey: "dateEdited") as? Double ?? 0
        let isReminder = memo.value(forKey: "isReminder") as? Bool
        let isLocked = memo.value(forKey: "isLocked") as? Bool
        let hashTag = memo.value(forKey: "hashTag") as? String ?? "not defined"
        let color = memo.value(forKey: "color") as? String ?? "white"
        
        cell.backgroundColor = UIColor.getRandomColorFromString(color: color)
        let defaultFontSize = Dimension.shared.fontMediumSize
        
        cell.content.font = UIFont.systemFont(ofSize: defaultFontSize, weight: .medium)
        cell.content.text = content
        
        if defaults.bool(forKey: Resource.Defaults.displayDateTime) == true {
            let dateString = DatetimeUtil().convertDatetime(date: dateEdited)
            let detailTextSize = (defaultFontSize / 1.2).rounded(.down)
            
            cell.dateEdited.font = UIFont.systemFont(ofSize: detailTextSize)
            cell.dateEdited.text = dateString

            cell.hashTag.font = UIFont.systemFont(ofSize: detailTextSize)
            cell.hashTag.text = "#\(hashTag)"
            
        } else {
            cell.dateEdited.text = nil
            cell.hashTag.text = nil
        }
        
        if isReminder == true {
            cell.reminderIsSetIcon.isHidden = false
        } else {
            cell.reminderIsSetIcon.isHidden = true
        }
        
        if isLocked == true {
            cell.lockIcon.isHidden = false
        } else {
            cell.lockIcon.isHidden = true
        }
        
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.addLongPress(target: self, action: #selector(longPressMemoItem(sender:)))
        
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation.isLandscape {
                cellsPerRow = 4
            } else {
                cellsPerRow = 3
            }
            
        } else {
            if UIDevice.current.orientation.isLandscape {
                cellsPerRow = 3
                
            } else {
                cellsPerRow = 2
            }
        }
    }
    
    @objc func longPressMemoItem(sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: location)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if reminderIsSetAtIndex(indexPath: indexPath!) == false {
            
            if lockIsSetAtIndex(indexPath: indexPath!) == true {
                alert.addAction(UIAlertAction(title: "UnlockMemo".localized, style: .default, handler: { _ in
                    print("Unlock")
                    self.handleLockMemoWithBiometrics(reason: "ReasonToUnlockMemo".localized, lockThisMemo: false, indexPath: indexPath!)
                }))
                
            } else {
                alert.addAction(UIAlertAction(title: "LockMemo".localized, style: .default, handler: { _ in
                    print("Lock")
                    self.handleLockMemoWithBiometrics(reason: "ReasonToLockMemo".localized, lockThisMemo: true, indexPath: indexPath!)
                }))
            }
        }
        
        if lockIsSetAtIndex(indexPath: indexPath!) == false {
            
            if reminderIsSetAtIndex(indexPath: indexPath!) == true {
                alert.addAction(UIAlertAction(title: "DeleteReminder".localized, style: .default, handler: { _ in
                    print("delete reminder")
                    self.deleteReminderHandle(indexPath: indexPath!)
                }))
                
            } else {
                alert.addAction(UIAlertAction(title: "Reminder".localized, style: .default, handler: { _ in
                    print("set reminder")
                    self.setReminderForMemo(indexPath: indexPath!)
                }))
            }
            
            alert.addAction(UIAlertAction(title: "Share".localized, style: .default, handler: { _ in
                print("Share memo")
                self.shareMemoHandle(indexPath: indexPath!)
            }))
            
            alert.addAction(UIAlertAction(title: "Delete".localized, style: .default, handler: { _ in
                print("Delete memo")
                self.deleteMemoHandle(indexPath: indexPath!)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        
        alert.view.tintColor = Colors.shared.defaultTintColor
        
        alert.pruneNegativeWidthConstraints()
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.any]
        }
        
        if !(navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
            DeviceControl().feedbackOnPress()
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension MemoViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension MemoViewController: UICollectionViewDelegateFlowLayout {
    
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

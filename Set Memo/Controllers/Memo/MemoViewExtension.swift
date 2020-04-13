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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteMemoAction(at: indexPath)
        let remind = remindMemoAction(at: indexPath)
        let deleteRemind = deleteReminderAction(at: indexPath)
        
        if reminderIsSetAtIndex(indexPath: indexPath) == true {
            return UISwipeActionsConfiguration(actions: [delete, deleteRemind])
        }
        
        return UISwipeActionsConfiguration(actions: [delete, remind])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let share = shareMemoAction(at: indexPath)
        let important = setLockAction(at: indexPath)
        let removeImportant = removeLockedAction(at: indexPath)
        
        if importantIsSetAtIndex(indexPath: indexPath) == true {
            return UISwipeActionsConfiguration(actions: [share, removeImportant])
        }
        
        return UISwipeActionsConfiguration(actions: [share, important])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if memoData.isEmpty {
            tableView.backgroundView = emptyView
        } else {
            tableView.backgroundView = nil
            if isFiltering() {
                return filterMemoData.count
                
            } else {
                return memoData.count
            }
        }
        return memoData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MemoViewCell
        cell.selectedBackground()
        
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
            cell.dateEdited.text = ""
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
        
        cell.accessoryType = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        
        self.navigationController?.pushViewController(updateView, animated: true)
    }
}

extension MemoViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

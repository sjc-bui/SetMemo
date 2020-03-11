//
//  MemoItem.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/29.
//  Copyright © 2020 popcorn. All rights reserved.
//

import RealmSwift

class MemoItem : Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var color: String = ""
    @objc dynamic var content:String = ""
    @objc dynamic var createdDate:Date = Date()
    @objc dynamic var modifiedDate:Date = Date()
    @objc dynamic var isReminder:Bool = false
    @objc dynamic var reminderDate:Date = Date()
    @objc dynamic var notificationUUID: String = ""
}

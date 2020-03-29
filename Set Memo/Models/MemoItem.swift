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
    @objc dynamic var dateCreated:Date = Date()
    @objc dynamic var dateEdited:Date = Date()
    @objc dynamic var isReminder:Bool = false
    @objc dynamic var dateReminder:Date = Date()
    @objc dynamic var temporarilyDelete:Bool = false
    @objc dynamic var hashTag: String = "Todo"
    @objc dynamic var notificationUUID: String = ""
}

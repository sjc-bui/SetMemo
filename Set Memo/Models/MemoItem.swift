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
    @objc dynamic var content = ""
    @objc dynamic var created = Date()
    @objc dynamic var isImportant = false
}

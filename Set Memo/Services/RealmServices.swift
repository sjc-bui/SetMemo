//
//  RealmServices.swift
//  Set Memo
//
//  Created by popcorn on 2020/02/29.
//  Copyright © 2020 popcorn. All rights reserved.
//

import RealmSwift

class RealmServices {
    static let shared = RealmServices()
    
    let realm: Realm = try! Realm()
    
    func read<T: Object> (_ object: T.Type, temporarilyDelete: Bool) -> [T] {
        let result = realm.objects(object.self).filter("temporarilyDelete = %@", temporarilyDelete)
        return Array(result)
    }
    
    func recentlyDeletedItemCount<T: Object> (_ object: T.Type, temporarilyDelete: Bool) -> Int {
        let total = realm.objects(object.self).filter("temporarilyDelete = %@", temporarilyDelete)
        return total.count
    }
    
    /*Testing...*/
    func readById<T: Object> (_ object: T.Type, id: String) -> Results<T> {
        return realm.objects(object.self).filter("id = %@", id)
    }
    
    func create<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print(error)
        }
    }

    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print(error)
        }
    }
    
    func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print(error)
        }
    }
}

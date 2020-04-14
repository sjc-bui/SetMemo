//
//  KeychainService.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/04/14.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit
import Security

let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

class KeychainService: NSObject {
    
    class func savePasswordToKeychain(service: String, account: String, data: String) {
        
        if let inputPassword = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            
            let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects:
                [kSecClassGenericPasswordValue, service, account, inputPassword], forKeys:
                [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue]
            )
            
            let status = SecItemAdd(keychainQuery as CFDictionary, nil)
            
            if status != errSecSuccess {
                if let err = SecCopyErrorMessageString(status, nil) {
                    print("\(err)")
                }
            }
            print("Save success")
        }
    }
    
    class func loadPasswordFromKeychain(service: String, account:String, data: String) -> String? {
        
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, account, kCFBooleanTrue!, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])

        var dataTypeRef :AnyObject?

        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: String?

        if status == errSecSuccess {
            
            if let retrievedData = dataTypeRef as? Data {
                contentsOfKeychain = String(data: retrievedData, encoding: String.Encoding.utf8)
                
                if data == contentsOfKeychain {
                    print("Same")
                } else {
                    print("Not same")
                }
            }
            
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
}

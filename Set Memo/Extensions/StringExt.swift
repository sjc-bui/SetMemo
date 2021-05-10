//
//  StringExt.swift
//  Set Memo
//
//  Created by popcorn on 2020/03/01.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

extension String {
    
    func isNullOrWhiteSpace() -> Bool {
        if self.isEmpty {
            return true
        }
        return self.trimmingCharacters(in: .whitespaces) == ""
    }
    
    // "hello".localized
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    // viet name -> VietNam
    var camelCasedString: String {
        return self.components(separatedBy: " ")
            .map { return $0.lowercased().capitalizingFirstLetter() }
            .joined()
    }
    
    var stripped: String {
        return self.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
    }
    
    func countWords() -> Int {
        let charSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let component = self.components(separatedBy: charSet)
        let words = component.filter { !$0.isEmpty }
        return words.count
    }
}

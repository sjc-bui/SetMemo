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
}

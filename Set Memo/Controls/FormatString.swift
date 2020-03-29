//
//  FormatString.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/29.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

class FormatString {
    func formatHashTag(text: String) -> String {
        let trimText = text.trimmingCharacters(in: .whitespacesAndNewlines).camelCasedString
        return trimText.stripped
    }
}

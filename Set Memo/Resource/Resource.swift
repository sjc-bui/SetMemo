//
//  Resource.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/15.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

public class Resource {
    public class Images {
        public static var createButton: UIImage? = UIImage(named: "plus")
        public static var sortButton: UIImage? = UIImage(named: "sort")
        public static var settingButton: UIImage? = UIImage(named: "setting")
        public static var backButton: UIImage? = UIImage(named: "back")
        public static var alarmButton: UIImage? = UIImage(named: "alarm")
        public static var searchButton: UIImage? = UIImage(named: "search")
        public static var keyboardButton: UIImage? = UIImage(systemName: "keyboard.chevron.compact.down")
        public static var hashTagButton: UIImage? = UIImage(systemName: "tag")
    }
    
    public class SortBy {
        public static var title = "title"
        public static var dateCreated = "dateCreated"
        public static var dateEdited = "dateEdited"
        public static var content = "content"
    }
    
    public class Defaults {
        public static let vibrationOnTouch = "vibrationOnTouch"
        public static let showIconBadges = "showIconBadges"
        public static let displayDateTime = "displayDateTime"
        public static let writeMemoPlaceholder = "Write something"
        public static let useBiometrics = "useBiometrics"
        public static let iconType = "iconType"
        public static let fontSize = "fontSize"
        public static let sortBy = "sortBy"
        public static let lastReview = "lastReview"
        public static let remindEveryDay = "remindEveryDay"
        public static let remindAt = "remindAt"
        public static let useDarkMode = "useDarkMode"
        public static let firstTimeDeleted = "firstTimeDeleted"
    }
}

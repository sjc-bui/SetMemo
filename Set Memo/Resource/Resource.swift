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
    }
    
    public class SortBy {
        public static var title = "title"
        public static var content = "content"
        public static var dateCreated = "dateCreated"
        public static var dateEdited = "dateEdited"
    }
    
    public class Defaults {
        public static let vibrationOnTouch = "vibrationOnTouch"
        public static let randomColor = "randomColor"
        public static let displayDateTime = "displayDateTime"
        public static let writeNotePlaceholder = "Write something"
        public static let useBiometrics = "useBiometrics"
        public static let iconType = "iconType"
        public static let fontSize = "fontSize"
        public static let sortBy = "sortBy"
    }
}

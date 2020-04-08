//
//  Resource.swift
//  Set Memo
//
//  Created by Quan Bui Van on 2020/03/15.
//  Copyright © 2020 popcorn. All rights reserved.
//

import UIKit

public class Resource {
    
    public class FontFamily {
        public static let HelveticaNeue = "HelveticaNeue"
    }
    
    public class Images {
        public static var createButton: UIImage? = UIImage(systemName: "plus.circle")
        public static var settingButton: UIImage? = UIImage(systemName: "gear")
        public static var keyboardButton: UIImage? = UIImage(systemName: "keyboard.chevron.compact.down")
        public static var sortButton: UIImage? = UIImage(systemName: "arrow.up.arrow.down.circle")
        public static var hashTagButton: UIImage? = UIImage(systemName: "tag")
        public static var trashButton: UIImage? = UIImage(systemName: "trash")
        public static var recoverButton: UIImage? = UIImage(systemName: "arrowshape.turn.up.left")
        public static var alarmButton: UIImage? = UIImage(systemName: "bell")
        public static var slashBellButton: UIImage? = UIImage(systemName: "bell.slash")
        public static var shareButton: UIImage? = UIImage(systemName: "square.and.arrow.up")
        public static var unlockButton: UIImage? = UIImage(systemName: "lock")
        public static var infoButton: UIImage? = UIImage(systemName: "info.circle")
        public static var moveLeftButton: UIImage? = UIImage(systemName: "chevron.left")
        public static var moveRightButton: UIImage? = UIImage(systemName: "chevron.right")
        public static var addCalendarButton: UIImage? = UIImage(systemName: "calendar.badge.plus")
        public static var sharpButton: UIImage? = UIImage(systemName: "number")
        public static var moveToBeginButton: UIImage? = UIImage(systemName: "arrow.up.to.line")
        public static var moveToEndButton: UIImage? = UIImage(systemName: "arrow.down.to.line")
        public static var addTabSpace: UIImage? = UIImage(systemName: "arrow.right.to.line.alt")
        
        public static var smallBellButton: UIImage? = UIImage(systemName: "bell.fill")
        public static var smallStarFillButton: UIImage? = UIImage(systemName: "star.fill")
        public static var setImportantButton: UIImage? = UIImage(systemName: "star")
        public static var removeImportantButton: UIImage? = UIImage(systemName: "star.slash")
    }
    
    public class SortBy {
        public static var title = "title"
        public static var dateCreated = "dateCreated"
        public static var dateEdited = "dateEdited"
        public static var content = "content"
    }
    
    public class Defaults {
        public static let vibrationOnTouch = "vibrationOnTouch"
        public static let showAlertOnDelete = "showAlertOnDelete"
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
        public static let titleTextColor = "titleTextColor"
        public static let theme = "theme"
    }
    
    public class FilterBy {
        public static let temporarilyDelete = "temporarilyDelete"
    }
}

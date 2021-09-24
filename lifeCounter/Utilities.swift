//
//  Utilities.swift
//  lifeCounter
//
//  Created by 倉知諒 on 2021/09/24.
//  Copyright © 2021 kurachi. All rights reserved.
//

import UIKit
class Utilities {
    static func dateFormatChangeYYYYMMDD(date: Date?) -> String {
        if date == nil {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = Consts.FORMAT_DATE_HIS
        return formatter.string(from: date!)
    }
}

//
//  Utilities.swift
//  lifeCounter
//
//  Created by 倉知諒 on 2021/09/24.
//  Copyright © 2021 kurachi. All rights reserved.
//

import UIKit
import CoreData
class Utilities {
    static func dateFormatChangeYYYYMMDD(date: Date?) -> String {
        if date == nil {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = Consts.FORMAT_DATE_HIS
        return formatter.string(from: date!)
    }
    static func isSmall() -> Bool{
        return UIScreen.main.bounds.size.width <= 320//4インチiPhoneの横幅（iPhone 5,5s,5c,SE）
    }
    static func getMaxId(viewContext:NSManagedObjectContext) -> Int32? {
        var max_id:Int32?
        do{
            let request_max: NSFetchRequest<Background> = Background.fetchRequest()
            request_max.fetchLimit = 1
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
            let sortDescriptors = [sortDescriptor]
            request_max.sortDescriptors = sortDescriptors
            let fetchResults = try viewContext.fetch(request_max)
            if fetchResults.count != 0 {
                max_id = fetchResults[0].id
            }
        } catch let e as NSError{
            print("error !!! : \(e)")
        }
        return max_id
    }
    static func getNextId(viewContext:NSManagedObjectContext) -> Int32 {
        var max_id = getMaxId(viewContext: viewContext)
        if max_id == nil {
            max_id = 0
        }
        else{
            max_id = max_id! + 1
        }
//        print("max id : \(String(describing: max_id))")
        return max_id!
    }
}

//
//  Setting+CoreDataProperties.swift
//  lifeCounter
//
//  Created by 倉知諒 on 2021/09/25.
//  Copyright © 2021 kurachi. All rights reserved.
//
//

import Foundation
import CoreData


extension Setting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Setting> {
        return NSFetchRequest<Setting>(entityName: "Setting")
    }

    @NSManaged public var recode: Bool

}

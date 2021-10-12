//
//  Life+CoreDataProperties.swift
//  lifeCounter
//
//  Created by 倉知諒 on 2021/09/24.
//  Copyright © 2021 kurachi. All rights reserved.
//
//

import Foundation
import CoreData


extension Life {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Life> {
        return NSFetchRequest<Life>(entityName: "Life")
    }

    @NSManaged public var life: Int16
    @NSManaged public var stage: Int16
    @NSManaged public var player: Int16
    @NSManaged public var game: Game?

}

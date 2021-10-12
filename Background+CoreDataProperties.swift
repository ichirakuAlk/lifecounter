//
//  Background+CoreDataProperties.swift
//  lifeCounter
//
//  Created by 倉知諒 on 2021/08/07.
//  Copyright © 2021 kurachi. All rights reserved.
//
//

import Foundation
import CoreData


extension Background {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Background> {
        return NSFetchRequest<Background>(entityName: "Background")
    }

    @NSManaged public var picture: Data?
    @NSManaged public var player: Int16
    @NSManaged public var scale: Float

}

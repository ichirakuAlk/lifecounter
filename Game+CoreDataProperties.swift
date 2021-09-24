//
//  Game+CoreDataProperties.swift
//  lifeCounter
//
//  Created by 倉知諒 on 2021/09/24.
//  Copyright © 2021 kurachi. All rights reserved.
//
//

import Foundation
import CoreData


extension Game {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var gameDate: Date?
    @NSManaged public var time: String?
    @NSManaged public var name: String?
    @NSManaged public var life: NSSet?

}

// MARK: Generated accessors for life
extension Game {

    @objc(addLifeObject:)
    @NSManaged public func addToLife(_ value: Life)

    @objc(removeLifeObject:)
    @NSManaged public func removeFromLife(_ value: Life)

    @objc(addLife:)
    @NSManaged public func addToLife(_ values: NSSet)

    @objc(removeLife:)
    @NSManaged public func removeFromLife(_ values: NSSet)

}

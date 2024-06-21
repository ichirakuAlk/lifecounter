//
//  Setting+CoreDataProperties.swift
//  
//
//  Created by 倉知諒 on 2024/06/21.
//
//

import Foundation
import CoreData


extension Setting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Setting> {
        return NSFetchRequest<Setting>(entityName: "Setting")
    }

    @NSManaged public var defaultLifeP1: Int16
    @NSManaged public var defaultLifep2: Int16
    @NSManaged public var recode: Bool
    @NSManaged public var rotateDirection: Int16
    @NSManaged public var bgopacity: Float

}

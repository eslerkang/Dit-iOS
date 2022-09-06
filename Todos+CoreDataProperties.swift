//
//  Todos+CoreDataProperties.swift
//  Dit
//
//  Created by 강태준 on 2022/09/06.
//
//

import Foundation
import CoreData


extension Todos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todos> {
        return NSFetchRequest<Todos>(entityName: "Todos")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var isDone: Bool
    @NSManaged public var text: String?
    @NSManaged public var uuid: UUID?

}

extension Todos : Identifiable {

}

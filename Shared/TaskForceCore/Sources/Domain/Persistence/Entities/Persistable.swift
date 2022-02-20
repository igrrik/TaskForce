//
//  Persistable.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import CoreData

public protocol Persistable {
    associatedtype PersistableObject: NSFetchRequestResult

    init?(object: PersistableObject)

    @discardableResult
    func makePersistableObject(in context: ManagedObjectContext) -> PersistableObject?

    func identifyingPredicate() -> NSPredicate

    static func fetchRequest() throws -> NSFetchRequest<PersistableObject>
}

public extension Persistable where PersistableObject: NSManagedObject {
    static func fetchRequest() throws -> NSFetchRequest<PersistableObject> {
        let entity = PersistableObject.entity()
        guard let entityName = entity.name else {
            throw CoreDataPersistenceController.Failure.failedToObtainEntityName(entity)
        }
        return NSFetchRequest<PersistableObject>(entityName: entityName)
    }
}

//
//  ManagedObjectContext.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import CoreData

public protocol ManagedObjectContext {
    var hasChanges: Bool { get }

    func obtain<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T]
    func delete<T: Persistable>(object: T.PersistableObject, ofPersistableType: T.Type) throws
    func save() throws
}

struct ManagedObjectDeletionError<T: Persistable>: Error {
    let objectToDelete: T.PersistableObject
}

extension NSManagedObjectContext: ManagedObjectContext {
    public func obtain<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T] {
        try fetch(request)
    }

    public func delete<T: Persistable>(object: T.PersistableObject, ofPersistableType: T.Type) throws {
        guard let managedObject = object as? NSManagedObject else {
            throw ManagedObjectDeletionError<T>(objectToDelete: object)
        }
        delete(managedObject)
    }
}

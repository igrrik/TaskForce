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
    func delete(_ object: NSManagedObject)
    func save() throws
}

extension NSManagedObjectContext: ManagedObjectContext {
    public func obtain<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T] {
        try fetch(request)
    }
}

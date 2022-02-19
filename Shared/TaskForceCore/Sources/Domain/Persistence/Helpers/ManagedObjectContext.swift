//
//  ManagedObjectContext.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import CoreData

// swiftlint:disable:next final_class
open class ManagedObjectContext: NSManagedObjectContext {
    func obtain<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T] {
        try fetch(request)
    }
}

final class MockManagedObjectContext: ManagedObjectContext {
    var obtainResult: Result<Any, Error>!

    override func obtain<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T] {
        switch obtainResult {
        case .success(let output):
            // swiftlint:disable:next force_cast
            return output as! [T]
        case .failure(let error):
            throw error
        case .none:
            fatalError("obtainResult shouldn't be nil")
        }
    }

    override func delete(_ object: NSManagedObject) {
    }

    override func save() throws {
    }
}

//
//  PersistentContainer.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import CoreData

open class PersistentContainer: NSPersistentContainer {
    func performBackgroundWork(_ work: @escaping (ManagedObjectContext) -> Void) {
        performBackgroundTask { context in
            work(context as! ManagedObjectContext)
        }
    }
}

final class MockPersistentContainer: PersistentContainer {
    override func performBackgroundWork(_ work: @escaping (ManagedObjectContext) -> Void) {

    }
}

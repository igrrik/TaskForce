//
//  PersistentContainer.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import CoreData

// swiftlint:disable:next final_class
open class PersistentContainer: NSPersistentContainer {
    public convenience init() {
        guard let modelURL = Bundle.module.url(forResource: .managedObjectModelName, withExtension: "momd") else {
            fatalError("Failed to locate url for \(String.managedObjectModelName)")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to initialize NSManagedObjectModel with url: \(modelURL)")
        }
        self.init(name: .managedObjectModelName, managedObjectModel: model)
    }

    func performBackgroundWork(_ work: @escaping (ManagedObjectContext) -> Void) {
        performBackgroundTask { context in
            // swiftlint:disable:next force_cast
            work(context as! ManagedObjectContext)
        }
    }
}

final class MockPersistentContainer: PersistentContainer {
    override func performBackgroundWork(_ work: @escaping (ManagedObjectContext) -> Void) {
    }
}

private extension String {
    static let managedObjectModelName = "TaskForceDataModel"
}

//
//  CoreDataPersistentContainer.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import CoreData

public final class CoreDataPersistentContainer: PersistentContainer {
    private lazy var container: NSPersistentContainer = {
        guard let modelURL = Bundle.module.url(forResource: .managedObjectModelName, withExtension: "momd") else {
            fatalError("Failed to locate url for \(String.managedObjectModelName)")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to initialize NSManagedObjectModel with url: \(modelURL)")
        }
        let container = NSPersistentContainer(name: .managedObjectModelName, managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    public init() {}

    public func performBackgroundTask(_ block: @escaping (ManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }
}

private extension String {
    static let managedObjectModelName = "TaskForceDataModel"
}

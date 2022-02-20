//
//  CoreDataPersistenceController.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import Combine
import CoreData

public final class CoreDataPersistenceController: PersistenceController {
    enum Failure: Error {
        case failedToFindObjectWithPredicate(NSPredicate)
        case failedToObtainEntityName(NSEntityDescription)
        case failedToCreatePersistableObject
    }

    private let delegateQueue: DispatchQueue
    private let persistentContainer: PersistentContainer

    public init(container: PersistentContainer, delegateQueue: DispatchQueue) {
        self.persistentContainer = container
        self.delegateQueue = delegateQueue
    }

    public func obtainItems<T: Persistable>(ofType: T.Type) -> AnyPublisher<[T], Error> {
        wrapInDeferredSubject { context, subject in
            do {
                let fetchRequest = try T.fetchRequest()
                let items = try context.obtain(fetchRequest)
                let objects = items.compactMap(T.init(object:))
                subject.send(objects)
                subject.send(completion: .finished)
            } catch {
                subject.send(completion: .failure(error))
            }
        }
    }

    public func save<T: Persistable>(_ item: T) -> AnyPublisher<Never, Error> {
        wrapInDeferredSubject { context, subject in
            do {
                guard item.makePersistableObject(in: context) != nil else {
                    subject.send(completion: .failure(Failure.failedToCreatePersistableObject))
                    return
                }
                try self.save(context: context)
                subject.send(completion: .finished)
            } catch {
                subject.send(completion: .failure(error))
            }
        }
    }

    public func delete<T: Persistable>(_ item: T) -> AnyPublisher<Never, Error> {
        wrapInDeferredSubject { context, subject in
            do {
                let fetchRequest = try T.fetchRequest()
                let predicate = item.identifyingPredicate()
                fetchRequest.fetchLimit = 1
                fetchRequest.predicate = predicate

                guard let object = try context.obtain(fetchRequest).first else {
                    subject.send(completion: .failure(Failure.failedToFindObjectWithPredicate(predicate)))
                    return
                }
                context.delete(object)
                try self.save(context: context)
                subject.send(completion: .finished)
            } catch {
                subject.send(completion: .failure(error))
            }
        }
    }

    private func save(context: ManagedObjectContext) throws {
        guard context.hasChanges else {
            return
        }
        try context.save()
    }

    private func wrapInDeferredSubject<Output>(
        _ block: @escaping (ManagedObjectContext, PassthroughSubject<Output, Error>) -> Void
    ) -> AnyPublisher<Output, Error> {
        Deferred { [persistentContainer] () -> PassthroughSubject<Output, Error> in
            let subject = PassthroughSubject<Output, Error>()
            persistentContainer.performBackgroundTask { context in
                block(context, subject)
            }
            return subject
        }
        .receive(on: delegateQueue)
        .eraseToAnyPublisher()
    }
}

private extension Persistable {
    static func fetchRequest() throws -> NSFetchRequest<PersistableObject> {
        let entity = PersistableObject.entity()
        guard let entityName = entity.name else {
            throw CoreDataPersistenceController.Failure.failedToObtainEntityName(entity)
        }
        return NSFetchRequest<PersistableObject>(entityName: entityName)
    }
}

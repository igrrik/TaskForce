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
    private let delegateQueue: DispatchQueue
    private let persistentContainer: PersistentContainer

    public init(container: PersistentContainer, delegateQueue: DispatchQueue) {
        self.persistentContainer = container
        self.delegateQueue = delegateQueue
//        let container = NSPersistentContainer(name: "TaskForceDataModel")
//        container.loadPersistentStores { _, error in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        }
//        return container
    }

    enum Failure: Error {
        case failedToFindObjectWithPredicate(NSPredicate)
        case failedToObtainEntityName(NSEntityDescription)
    }

    public func obtainItems<T: Persistable>(ofType: T.Type) -> AnyPublisher<[T], Error> {
        Deferred {
            Future<[T], Error> { subscriber in
                self.persistentContainer.performBackgroundWork { context in
                    do {
                        let fetchRequest = try T.fetchRequest()
                        let items = try context.obtain(fetchRequest)
                        let objects = items.compactMap(T.init(object:))
                        subscriber(.success(objects))
                    } catch {
                        subscriber(.failure(error))
                    }
                }
            }
        }
        .receive(on: delegateQueue)
        .eraseToAnyPublisher()
    }

    public func save<T: Persistable>(_ item: T) -> AnyPublisher<Never, Error> {
        Deferred { () -> PassthroughSubject<Never, Error> in
            let subject = PassthroughSubject<Never, Error>()

            self.persistentContainer.performBackgroundWork { context in
                do {
                    item.makePersistableObject(in: context)
                    try self.save(context: context)
                    subject.send(completion: .finished)
                } catch {
                    subject.send(completion: .failure(error))
                }
            }

            return subject
        }
        .receive(on: delegateQueue)
        .eraseToAnyPublisher()
    }

    public func delete<T: Persistable>(_ item: T) -> AnyPublisher<Never, Error> {
        Deferred { () -> PassthroughSubject<Never, Error> in
            let subject = PassthroughSubject<Never, Error>()

            self.persistentContainer.performBackgroundWork { context in
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

            return subject
        }
        .receive(on: delegateQueue)
        .eraseToAnyPublisher()
    }

    private func save(context: NSManagedObjectContext) throws {
        guard context.hasChanges else {
            return
        }
        try context.save()
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

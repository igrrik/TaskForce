//
//  PersistenceController.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 17.02.2022.
//

import Foundation
import CoreData
import TaskForceCore
import Combine

extension Character: Persistable {
    typealias PersistableObject = CharacterMO

    convenience init?(object: PersistableObject) {
        guard
            let name = object.name,
            let info = object.info,
            let thumbnailMO = object.thumbnail,
            let thumbnail = Thumbnail(thumbnailMO: thumbnailMO)
        else {
            return nil
        }
        self.init(id: UInt(object.id), name: name, info: info, thumbnail: thumbnail)
    }

    @discardableResult
    func makePersistableObject(in context: NSManagedObjectContext) -> PersistableObject {
        let thumbnailMO = ThumbnailMO(context: context)
        thumbnailMO.path = thumbnail.path
        thumbnailMO.fileExtension = thumbnail.fileExtension

        let characterMO = CharacterMO(context: context)
        characterMO.id = Int64(id)
        characterMO.name = name
        characterMO.info = info
        characterMO.isRecruited = true
        characterMO.thumbnail = thumbnailMO

        return characterMO
    }

    func identifyingPredicate() -> NSPredicate {
        NSPredicate(format: "id == %d", Int64(id))
    }
}

protocol Persistable {
    associatedtype PersistableObject: NSManagedObject

    init?(object: PersistableObject)

    @discardableResult
    func makePersistableObject(in context: NSManagedObjectContext) -> PersistableObject

    func identifyingPredicate() -> NSPredicate
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

class ManagedObjectContext: NSManagedObjectContext {
    func obtain<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T] {
        try fetch(request)
    }
}

class PersistentContainer: NSPersistentContainer {
    func performBackgroundWork(_ work: @escaping (ManagedObjectContext) -> Void) {
        performBackgroundTask { context in
            work(context as! ManagedObjectContext)
        }
    }
}

protocol PersistenceController {
    func obtainItems<T: Persistable>(ofType: T.Type) -> AnyPublisher<[T], Error>
    func save<T: Persistable>(_ item: T) -> AnyPublisher<Never, Error>
    func delete<T: Persistable>(_ item: T) -> AnyPublisher<Never, Error>
}

final class CoreDataPersistenceController: PersistenceController {
    private let delegateQueue: DispatchQueue
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskForceDataModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    enum Failure: Error {
        case failedToFindObjectWithPredicate(NSPredicate)
        case failedToObtainEntityName(NSEntityDescription)
    }

    init(delegateQueue: DispatchQueue) {
        self.delegateQueue = delegateQueue
    }

    func obtainItems<T: Persistable>(ofType: T.Type) -> AnyPublisher<[T], Error> {
        Deferred {
            Future<[T], Error> { subscriber in
                self.persistentContainer.performBackgroundTask { context in
                    do {
                        let fetchRequest = try T.fetchRequest()
                        let items = try context.fetch(fetchRequest)
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

    func save<T: Persistable>(_ item: T) -> AnyPublisher<Never, Error> {
        Deferred { () -> PassthroughSubject<Never, Error> in
            let subject = PassthroughSubject<Never, Error>()

            self.persistentContainer.performBackgroundTask { context in
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

    func delete<T: Persistable>(_ item: T) -> AnyPublisher<Never, Error> {
        Deferred { () -> PassthroughSubject<Never, Error> in
            let subject = PassthroughSubject<Never, Error>()

            self.persistentContainer.performBackgroundTask { context in
                do {
                    let fetchRequest = try T.fetchRequest()
                    let predicate = item.identifyingPredicate()
                    fetchRequest.fetchLimit = 1
                    fetchRequest.predicate = predicate

                    guard let object = try context.fetch(fetchRequest).first else {
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

// final class PersistenceController {
//    static let shared = PersistenceController()
//
//    private lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "TaskForceDataModel")
//        container.loadPersistentStores { _, error in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        }
//        return container
//    }()
//
//    private init() {}
//
//    func obtainRecruitedCharacters() -> [Character] {
//        let moc = persistentContainer.viewContext
//        let charactersFetch = CharacterMO.fetchRequest()
//
//        do {
//            let characters = try moc.fetch(charactersFetch)
//            return characters.compactMap(Character.init(characterMO:))
//        } catch {
//            fatalError("Failed to fetch employees: \(error)")
//        }
//    }
//
//    func add(character: Character) {
//        let thumbnailMO = ThumbnailMO(context: persistentContainer.viewContext)
//        thumbnailMO.path = character.thumbnail.path
//        thumbnailMO.fileExtension = character.thumbnail.fileExtension
//
//        let characterMO = CharacterMO(context: persistentContainer.viewContext)
//        characterMO.id = Int64(character.id)
//        characterMO.name = character.name
//        characterMO.info = character.info
//        characterMO.isRecruited = true
//        characterMO.thumbnail = thumbnailMO
//
//        saveContext()
//    }
//
//    func deleteCharacter(with id: UInt) {
//        let moc = persistentContainer.viewContext
//        let characterToDeleteFetchRequest = CharacterMO.fetchRequest()
//        characterToDeleteFetchRequest.predicate = NSPredicate(format: "id == %d", Int64(id))
//        do {
//            guard let characterMO = try moc.fetch(characterToDeleteFetchRequest).first else {
//                return
//            }
//            moc.delete(characterMO)
//            saveContext()
//        } catch {
//            fatalError("Failed to fetch character with id: \(error)")
//        }
//    }
//
//    func saveContext() {
//        let context = persistentContainer.viewContext
//        guard context.hasChanges else {
//            return
//        }
//        do {
//            try context.save()
//        } catch {
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
//    }
// }

typealias SinglePublisher<Output, Failure: Error> = Deferred<Future<Output, Failure>>

extension SinglePublisher {
    static func create(
        _ block: @escaping ((Result<Output, Failure>) -> Void) -> Void
    ) -> SinglePublisher<Output, Failure> {
        Publishers.single(block)
    }
}

private extension Publishers {
    static func single<Output, Failure: Error>(
        _ block: @escaping ((Result<Output, Failure>) -> Void) -> Void
    ) -> SinglePublisher<Output, Failure> {
        Deferred {
            Future<Output, Failure> { subscriber in
                block(subscriber)
            }
        }
    }
}

private extension Character {
    convenience init?(characterMO: CharacterMO) {
        guard
            let name = characterMO.name,
            let info = characterMO.info,
            let thumbnailMO = characterMO.thumbnail,
            let thumbnail = Thumbnail(thumbnailMO: thumbnailMO)
        else {
            return nil
        }
        self.init(id: UInt(characterMO.id), name: name, info: info, thumbnail: thumbnail)
    }
}

private extension Thumbnail {
    init?(thumbnailMO: ThumbnailMO) {
        guard let path = thumbnailMO.path, let fileExtension = thumbnailMO.fileExtension else {
            return nil
        }
        self.init(path: path, fileExtension: fileExtension)
    }
}

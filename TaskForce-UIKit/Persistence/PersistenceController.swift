//
//  PersistenceController.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 17.02.2022.
//

import Foundation
import CoreData
import TaskForceCore

final class PersistenceController {
    static let shared = PersistenceController()

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskForceDataModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    private init() {}

    func obtainRecruitedCharacters() -> [Character] {
        let moc = persistentContainer.viewContext
        let charactersFetch = CharacterMO.fetchRequest()

        do {
            let characters = try moc.fetch(charactersFetch)
            return characters.compactMap(Character.init(characterMO:))
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }

    func add(character: Character) {
        let thumbnailMO = ThumbnailMO(context: persistentContainer.viewContext)
        thumbnailMO.path = character.thumbnail.path
        thumbnailMO.fileExtension = character.thumbnail.fileExtension

        let characterMO = CharacterMO(context: persistentContainer.viewContext)
        characterMO.id = Int64(character.id)
        characterMO.name = character.name
        characterMO.info = character.info
        characterMO.isRecruited = true
        characterMO.thumbnail = thumbnailMO

        saveContext()
    }

    func deleteCharacter(with id: UInt) {
        let moc = persistentContainer.viewContext
        let characterToDeleteFetchRequest = CharacterMO.fetchRequest()
        characterToDeleteFetchRequest.predicate = NSPredicate(format: "id == %d", Int64(id))
        do {
            guard let characterMO = try moc.fetch(characterToDeleteFetchRequest).first else {
                return
            }
            moc.delete(characterMO)
            saveContext()
        } catch {
            fatalError("Failed to fetch character with id: \(error)")
        }
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else {
            return
        }
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
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

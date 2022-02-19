//
//  Character+Persistable.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import CoreData

extension Character: Persistable {
    public typealias PersistableObject = CharacterMO

    public convenience init?(object: PersistableObject) {
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
    public func makePersistableObject(in context: NSManagedObjectContext) -> PersistableObject {
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

    public func identifyingPredicate() -> NSPredicate {
        NSPredicate(format: "id == %d", Int64(id))
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

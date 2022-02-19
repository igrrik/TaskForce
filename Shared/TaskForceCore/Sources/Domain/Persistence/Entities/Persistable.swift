//
//  Persistable.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import CoreData

public protocol Persistable {
    associatedtype PersistableObject: NSManagedObject

    init?(object: PersistableObject)

    @discardableResult
    func makePersistableObject(in context: ManagedObjectContext) -> PersistableObject?

    func identifyingPredicate() -> NSPredicate
}

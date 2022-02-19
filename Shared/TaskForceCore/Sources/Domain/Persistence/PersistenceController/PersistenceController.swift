//
//  PersistenceController.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import Combine

public protocol PersistenceController {
    func obtainItems<T: Persistable>(ofType: T.Type) -> AnyPublisher<[T], Error>
    func save<T: Persistable>(_ item: T) -> AnyPublisher<Never, Error>
    func delete<T: Persistable>(_ item: T) -> AnyPublisher<Never, Error>
}

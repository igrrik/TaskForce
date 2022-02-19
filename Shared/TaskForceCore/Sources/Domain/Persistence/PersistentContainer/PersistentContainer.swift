//
//  PersistentContainer.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation

public protocol PersistentContainer {
    func performBackgroundTask(_ block: @escaping (ManagedObjectContext) -> Void)
}

//
//  SquadManager.swift
//  
//
//  Created by Igor Kokoev on 17.02.2022.
//

import Foundation
import Combine

public protocol SquadManager {
    var squadMembers: AnyPublisher<Set<Character>, Never> { get }

    func recruit(_ character: Character)
    func fire(_ character: Character)
}

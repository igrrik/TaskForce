//
//  InMemorySquadManager.swift
//  
//
//  Created by Igor Kokoev on 17.02.2022.
//

import Foundation
import Combine

public final class InMemorySquadManager: SquadManager {
    public let squadMembers: AnyPublisher<Set<Character>, Never>
    
    private let squadMembersSubject: CurrentValueSubject<Set<Character>, Never>

    public init(squad: Set<Character>) {
        squadMembersSubject = .init(squad)
        squadMembers = squadMembersSubject.eraseToAnyPublisher()
    }

    public func recruit(_ character: Character) {
        character.isRecruited = true

        var squad = squadMembersSubject.value
        squad.insert(character)
        squadMembersSubject.send(squad)
    }

    public func fire(_ character: Character) {
        character.isRecruited = false

        var squad = squadMembersSubject.value
        squad.remove(character)
        squadMembersSubject.send(squad)
    }
}

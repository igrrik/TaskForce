//
//  InMemorySquadManager.swift
//  
//
//  Created by Igor Kokoev on 17.02.2022.
//

import Foundation
import Combine

public final class InMemorySquadManager: SquadManager {
    private let squadMembersSubject: CurrentValueSubject<Squad, Never>

    public init(squad: Squad = []) {
        squadMembersSubject = .init(squad)
    }

    public func observeSquadMembers() -> AnyPublisher<Squad, Error> {
        squadMembersSubject.setFailureType(to: Error.self).eraseToAnyPublisher()
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

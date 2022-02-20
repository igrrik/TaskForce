//
//  PersistentSquadManager.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import Combine

// TODO alias for squad

public final class PersistentSquadManager: SquadManager {
    private let persistenceController: PersistenceController
    private let squadMembersSubject = CurrentValueSubject<Set<Character>, Never>([])
    private var cancellableBag = Set<AnyCancellable>()
    private var hasLoadedPersistenCharacters = false

    public init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }

    public func observeSquadMembers() -> AnyPublisher<Set<Character>, Error> {
        guard !hasLoadedPersistenCharacters else {
            return squadMembersSubject.setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        hasLoadedPersistenCharacters.toggle()

        return persistenceController
            .obtainItems(ofType: Character.self)
            .map(Set<Character>.init)
            .eraseToAnyPublisher()
            .flatMap { [squadMembersSubject] characters -> AnyPublisher<Set<Character>, Error> in
                squadMembersSubject.send(characters)
                return squadMembersSubject.setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func recruit(_ character: Character) {
        guard !character.isRecruited else {
            return
        }
        character.isRecruited = true

        persistenceController
            .save(character)
            .sink(
                receiveCompletion: { completion in
                    guard case let .failure(error) = completion else {
                        return
                    }
                    assertionFailure("Failed to save character: \(character) due to error: \(error)")
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellableBag)

        var squad = squadMembersSubject.value
        squad.insert(character)
        squadMembersSubject.send(squad)
    }

    public func fire(_ character: Character) {
        guard character.isRecruited else {
            return
        }
        character.isRecruited = false

        persistenceController
            .delete(character)
            .sink(
                receiveCompletion: { completion in
                    guard case let .failure(error) = completion else {
                        return
                    }
                    assertionFailure("Failed to save character: \(character) due to error: \(error)")
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellableBag)

        var squad = squadMembersSubject.value
        squad.remove(character)
        squadMembersSubject.send(squad)
    }

    private func obtainPersistentCharacters() -> AnyPublisher<Set<Character>, Error> {
        persistenceController
            .obtainItems(ofType: Character.self)
            .map(Set<Character>.init)
            .eraseToAnyPublisher()
    }
}

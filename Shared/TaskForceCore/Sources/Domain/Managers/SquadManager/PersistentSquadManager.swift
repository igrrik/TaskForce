//
//  PersistentSquadManager.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import Combine

public final class PersistentSquadManager: SquadManager {
    public let squadMembers: AnyPublisher<Set<Character>, Never>

    private let persistenceController: PersistenceController
    private let squadMembersSubject = CurrentValueSubject<Set<Character>, Never>([])
    private var cancellableBag = Set<AnyCancellable>()

    public init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        squadMembers = squadMembersSubject.eraseToAnyPublisher()
        loadPersistentCharacters()
    }

    public func recruit(_ character: Character) {
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

    private func loadPersistentCharacters() {
        persistenceController
            .obtainItems(ofType: Character.self)
            .map(Set<Character>.init)
            .sink { completion in
                guard case let .failure(error) = completion else {
                    return
                }
                assertionFailure("Failed to load persistent items due to error: \(error)")
            } receiveValue: { [weak self] characters in
                self?.squadMembersSubject.send(characters)
            }
            .store(in: &cancellableBag)
    }
}

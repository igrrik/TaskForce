//
//  PersistentSquadManager.swift
//  
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import Combine
import CombineExt

// TODO alias for squad

public final class PersistentSquadManager: SquadManager {
    private let persistenceController: PersistenceController
    private let squadMembersSubject = ReplaySubject<Set<Character>, Error>(bufferSize: 1)
    private var cancellableBag = Set<AnyCancellable>()
    private var hasLoadedPersistenCharacters = false

    public init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }

    public func observeSquadMembers() -> AnyPublisher<Set<Character>, Error> {
        if !hasLoadedPersistenCharacters {
            hasLoadedPersistenCharacters.toggle()

            obtainPersistentCharacters()
                .sink { [weak self] completion in
                    guard case let .failure(error) = completion else {
                        return
                    }
                    self?.squadMembersSubject.send(completion: .failure(error))
                } receiveValue: { [weak self] squad in
                    self?.squadMembersSubject.send(squad)
                }
                .store(in: &cancellableBag)
        }

        return squadMembersSubject.eraseToAnyPublisher()
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

        squadMembersSubject
            .prefix(1)
            .ignoreFailure()
            .sink(receiveValue: { [weak self] squad in
                var squad = squad
                squad.insert(character)
                self?.squadMembersSubject.send(squad)
            })
            .store(in: &cancellableBag)
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

        squadMembersSubject
            .prefix(1)
            .ignoreFailure()
            .sink(receiveValue: { [weak self] squad in
                var squad = squad
                squad.remove(character)
                self?.squadMembersSubject.send(squad)
            })
            .store(in: &cancellableBag)
    }

    private func obtainPersistentCharacters() -> AnyPublisher<Set<Character>, Error> {
        persistenceController
            .obtainItems(ofType: Character.self)
            .map(Set<Character>.init)
            .eraseToAnyPublisher()
    }
}

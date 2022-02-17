//
//  CharactersListViewModel.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 04.02.2022.
//

import Foundation
import Combine
import TaskForceCore
import ImageDownloader

final class CharactersListViewModel: ObservableObject, Routable {
    enum RoutableEvent {
        case didSelectCharacter(Character)
    }

    let routingAction: AnyPublisher<RoutableEvent, Never>
    let error: AnyPublisher<String, Never>

    @Published private(set) var isLoading: Bool = true
    @Published private(set) var squad: [CharactersListCellModel] = []
    @Published private(set) var allCharacters: [CharactersListCellModel] = []

    private let charactersRepository: CharactersRepository
    private let imageDownloader: ImageDownloader
    private let routingSubject = PassthroughSubject<RoutableEvent, Never>()
    private let errorSubject = PassthroughSubject<String, Never>()
    private var charactersLatestPagingParameters = PagingParameters()
    private var cancellableBag = Set<AnyCancellable>()
    private var characters: [UInt: Character] = .init()
    private var isLoadingNextPage: Bool = false
    private var squadCancellable: AnyCancellable?

    init(charactersRepository: CharactersRepository, imageDownloader: ImageDownloader) {
        self.charactersRepository = charactersRepository
        self.imageDownloader = imageDownloader
        self.routingAction = routingSubject.eraseToAnyPublisher()
        self.error = errorSubject.eraseToAnyPublisher()
    }

    deinit {
        squadCancellable?.cancel()
    }

    func obtainInitialData() {
        observeSquad()
        obtainFirstBunchOfCharacters()
    }

    func obtainMoreData() {
        guard !isLoadingNextPage, !isLoading else {
            return
        }
        isLoadingNextPage = true
        charactersRepository
            .obtainCharacters(pagingParams: charactersLatestPagingParameters.nextPageParameters())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoadingNextPage = false
                guard case let .failure(error) = completion else {
                    return
                }
                self?.errorSubject.send(error.localizedDescription)
            }, receiveValue: { [weak self] response in
                self?.process(response)
            })
            .store(in: &cancellableBag)
    }

    func didSelectCharacter(with id: UInt) {
        guard let character = characters[id] else {
            assertionFailure("Failed to obtain character with id: \(id)")
            return
        }
        routingSubject.send(.didSelectCharacter(character))
    }

    private func obtainFirstBunchOfCharacters() {
        charactersRepository
            .obtainCharacters(pagingParams: charactersLatestPagingParameters)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                guard case let .failure(error) = completion else {
                    return
                }
                self?.errorSubject.send(error.localizedDescription)
            }, receiveValue: { [weak self] response in
                self?.process(response)
            })
            .store(in: &cancellableBag)
    }

    private func observeSquad() {
        charactersRepository
            .observeSquadMembers()
            .map { [weak self] characters in
                guard let imageDownloader = self?.imageDownloader else {
                    assertionFailure("Self shouldn't be nil")
                    return [CharactersListCellModel]()
                }
                return characters
                    .sorted(by: { $0.name < $1.name })
                    .map { CharactersListCellModel(character: $0, imageDownloader: imageDownloader) }
            }
            .sink { [weak self] squad in
                self?.squad = squad
            }
            .store(in: &cancellableBag)
    }

    private func process(_ response: PageableResponse<Character>) {
        charactersLatestPagingParameters = response.pagingParameters
        let newCharacters = response.results

        newCharacters.forEach { character in
            characters[character.id] = character
        }

        let cellModels = newCharacters.map { CharactersListCellModel(character: $0, imageDownloader: imageDownloader) }
        allCharacters.append(contentsOf: cellModels)
    }
}

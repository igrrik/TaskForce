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

enum CharactersListSection: Int, CaseIterable {
    case squad
    case allCharacters
}

final class CharactersListViewModel: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var squad: [CharactersListCellModel] = []
    @Published private(set) var allCharacters: [CharactersListCellModel] = []

    private let charactersRepository: CharactersRepository
    private let imageDownloader: ImageDownloader
    private var charactersLatestPagingParameters = PagingParameters()
    private var cancellableBag = Set<AnyCancellable>()
    private var characters: Set<Character> = .init()

    init(charactersRepository: CharactersRepository, imageDownloader: ImageDownloader) {
        self.charactersRepository = charactersRepository
        self.imageDownloader = imageDownloader
    }

    func obtainInitialData() {
        isLoading = true
        charactersRepository
            .obtainCharacters(pagingParams: charactersLatestPagingParameters)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                guard case let .failure(error) = completion else { return }
                self?.error = error
            }, receiveValue: { [weak self] value in
                self?.processNewCharacters(value)
            })
            .store(in: &cancellableBag)
    }

    func obtainMoreData() {
        charactersRepository
            .obtainCharacters(pagingParams: charactersLatestPagingParameters.nextPageParameters())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard case let .failure(error) = completion else { return }
                self?.error = error
            }, receiveValue: { [weak self] value in
                self?.processNewCharacters(value)
            })
            .store(in: &cancellableBag)
    }

    private func processNewCharacters(_ newCharacters: PageableResponse<Character>) {
        charactersLatestPagingParameters = newCharacters.pagingParameters
        characters.formUnion(newCharacters.results)

        squad.append(contentsOf: newCharacters.squadMembersCellModels(imageDownloader: imageDownloader))
        allCharacters.append(contentsOf: newCharacters.cellModels(imageDownloader: imageDownloader))
    }
}

private extension PageableResponse where Result == Character {
    func squadMembersCellModels(imageDownloader: ImageDownloader) -> [CharactersListCellModel] {
        results
            .filter { $0.isRecruited }
            .map { CharactersListCellModel(character: $0, imageDownloader: imageDownloader) }
    }

    func cellModels(imageDownloader: ImageDownloader) -> [CharactersListCellModel] {
        results.map { CharactersListCellModel(character: $0, imageDownloader: imageDownloader) }
    }
}

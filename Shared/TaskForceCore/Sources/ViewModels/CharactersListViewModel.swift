//
//  CharactersListViewModel.swift
//  
//
//  Created by Igor Kokoev on 04.02.2022.
//

import Foundation
import Combine

final class CharactersListViewModel: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var characters: [Character] = []

    private let charactersRepository: CharactersRepository
    private var charactersLatestPagingParameters = PagingParameters()
    private var cancellableBag = Set<AnyCancellable>()

    init(charactersRepository: CharactersRepository) {
        self.charactersRepository = charactersRepository
    }

    func loadInitialData() {
        charactersRepository
            .obtainCharacters(pagingParams: charactersLatestPagingParameters)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard case let .failure(error) = completion else { return }
                self?.error = error
            }, receiveValue: { [weak self] value in
                self?.charactersLatestPagingParameters = value.pagingParameters
                self?.characters.append(contentsOf: value.results)
            })
            .store(in: &cancellableBag)
    }

    func loadMoreData() {
        charactersRepository
            .obtainCharacters(pagingParams: charactersLatestPagingParameters.nextPageParameters())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard case let .failure(error) = completion else { return }
                self?.error = error
            }, receiveValue: { [weak self] value in
                self?.charactersLatestPagingParameters = value.pagingParameters
                self?.characters.append(contentsOf: value.results)
            })
            .store(in: &cancellableBag)
    }
}

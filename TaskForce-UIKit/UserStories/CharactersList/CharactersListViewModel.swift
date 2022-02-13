//
//  CharactersListViewModel.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 04.02.2022.
//

import Foundation
import Combine
import TaskForceCore

final class CharactersListViewModel: ObservableObject {
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var error: Error?
    @Published public private(set) var characters: [Character] = []

    private let charactersRepository: CharactersRepository
    private var charactersLatestPagingParameters = PagingParameters()
    private var cancellableBag = Set<AnyCancellable>()

    init(charactersRepository: CharactersRepository) {
        self.charactersRepository = charactersRepository
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
                self?.charactersLatestPagingParameters = value.pagingParameters
                self?.characters.append(contentsOf: value.results)
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
                self?.charactersLatestPagingParameters = value.pagingParameters
                self?.characters.append(contentsOf: value.results)
            })
            .store(in: &cancellableBag)
    }
}

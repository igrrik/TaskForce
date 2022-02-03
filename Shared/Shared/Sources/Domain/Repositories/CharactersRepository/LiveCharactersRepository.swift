//
//  LiveCharactersRepository.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation
import Combine

final class LiveCharactersRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
}

extension LiveCharactersRepository: CharactersRepository {
    func obtainCharacters(pagingParams: PagingParameters) -> AnyPublisher<PageableResponse<Character>, Error> {
        apiClient.execute(request: ObtainCharactersRequest(limit: pagingParams.limit, offset: pagingParams.offset))
            .map(PageableResponse.init(apiResponse:))
            .eraseToAnyPublisher()
    }

    func obtainCharacter(with id: Int) -> AnyPublisher<Character, Error> {
        fatalError()
    }
}

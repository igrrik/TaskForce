//
//  LiveCharactersRepository.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation
import Combine

public final class LiveCharactersRepository {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
}

extension LiveCharactersRepository: CharactersRepository {
    public func obtainCharacters(pagingParams: PagingParameters) -> AnyPublisher<PageableResponse<Character>, Error> {
        apiClient.execute(request: ObtainCharactersRequest(limit: pagingParams.limit, offset: pagingParams.offset))
            .handleEvents(receiveOutput: { response in
                print(response)
            })
            .map(PageableResponse.init(apiResponse:))
            .eraseToAnyPublisher()
    }

    public func obtainCharacter(with id: UInt) -> AnyPublisher<Character, Error> {
        apiClient.execute(request: ObtainCharacterRequest(characterId: id))
            .map(\.result)
            .eraseToAnyPublisher()
    }
}

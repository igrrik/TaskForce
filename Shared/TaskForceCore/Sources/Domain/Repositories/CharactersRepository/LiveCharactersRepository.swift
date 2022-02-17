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
    private let squadManager: SquadManager

    public init(apiClient: APIClient, squadManager: SquadManager) {
        self.apiClient = apiClient
        self.squadManager = squadManager
    }
}

extension LiveCharactersRepository: CharactersRepository {
    public func observeSquadMembers() -> AnyPublisher<Set<Character>, Never> {
        squadManager.squadMembers
    }

    public func obtainCharacters(pagingParams: PagingParameters) -> AnyPublisher<PageableResponse<Character>, Error> {
        let squadPublisher = observeSquadMembers().setFailureType(to: Error.self)

        return apiClient
            .execute(request: ObtainCharactersRequest(limit: pagingParams.limit, offset: pagingParams.offset))
            .map(PageableResponse.init(apiResponse:))
            .zip(squadPublisher)
            .map { response, squad in
                let characters = response
                    .results
                    .map { Character.modifyingRecruitmentStatus(character: $0, squad: squad) }
                return PageableResponse(results: characters, offset: response.offset, limit: response.limit)
            }
            .eraseToAnyPublisher()
    }

    public func obtainCharacter(with id: UInt) -> AnyPublisher<Character, Error> {
        let squadPublisher = observeSquadMembers().setFailureType(to: Error.self)

        return apiClient.execute(request: ObtainCharacterRequest(characterId: id))
            .map(\.result)
            .zip(squadPublisher)
            .map(Character.modifyingRecruitmentStatus(character:squad:))
            .eraseToAnyPublisher()
    }
}

private extension Character {
    static func modifyingRecruitmentStatus(character: Character, squad: Set<Character>) -> Character {
        character.isRecruited = squad.contains(character)
        return character
    }
}

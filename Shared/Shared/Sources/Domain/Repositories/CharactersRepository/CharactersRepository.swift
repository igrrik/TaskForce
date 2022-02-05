//
//  CharactersRepository.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation
import Combine

protocol CharactersRepository {
    func obtainCharacters(pagingParams: PagingParameters) -> AnyPublisher<PageableResponse<Character>, Error>
    func obtainCharacter(with id: Int) -> AnyPublisher<Character, Error>
}
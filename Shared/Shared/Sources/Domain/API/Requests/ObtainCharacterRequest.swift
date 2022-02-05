//
//  ObtainCharacterRequest.swift
//  
//
//  Created by Igor Kokoev on 04.02.2022.
//

import Foundation

struct ObtainCharacterRequest: APIRequest {
    typealias ResultElement = Character
    typealias Response = APISingleElementResponse<ResultElement>

    let endpoint: APIEndpoint
    let queryItems: [URLQueryItem] = []

    init(characterId: UInt) {
        self.endpoint = .init(resource: .characters, lastPathComponent: String(describing: characterId))
    }
}

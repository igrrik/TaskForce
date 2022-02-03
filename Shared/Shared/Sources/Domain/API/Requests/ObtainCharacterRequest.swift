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

    let resource: APIResource = .characters
    let queryItems: [URLQueryItem] = []
    let characterId: UInt
    var path: String? { String(describing: characterId) }
}

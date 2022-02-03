//
//  ObtainCharactersRequest.swift
//  
//
//  Created by Igor Kokoev on 04.02.2022.
//

import Foundation

struct ObtainCharactersRequest: APIPageableRequest {
    typealias ResultElement = Character
    typealias Response = APIMultipleElementsResponse<ResultElement>

    let resource: APIResource = .characters
    let path: String? = nil
    let limit: UInt
    let offset: UInt

    var queryItems: [URLQueryItem] {[
        .init(name: "limit", value: String(describing: limit)),
        .init(name: "offset", value: String(describing: offset))
    ]}
}

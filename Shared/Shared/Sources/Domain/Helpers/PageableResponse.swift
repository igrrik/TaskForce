//
//  PageableResponse.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

struct PageableResponse<Result: Decodable> {
    let offset: UInt
    let limit: UInt
    let results: [Result]

    var pagingParameters: PagingParameters { .init(limit: limit, offset: offset) }
}

extension PageableResponse {
    init(apiResponse: APIMultipleElementsResponse<Result>) {
        self.limit = apiResponse.limit
        self.offset = apiResponse.offset
        self.results = apiResponse.results
    }
}

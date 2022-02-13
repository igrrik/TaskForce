//
//  PageableResponse.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

public struct PageableResponse<Result>: Equatable where Result: Decodable & Equatable {
    public let results: [Result]
    public var pagingParameters: PagingParameters { .init(limit: limit, offset: offset) }

    let offset: UInt
    let limit: UInt
}

extension PageableResponse {
    init(apiResponse: APIMultipleElementsResponse<Result>) {
        self.limit = apiResponse.limit
        self.offset = apiResponse.offset
        self.results = apiResponse.results
    }
}

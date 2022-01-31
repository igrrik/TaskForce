//
//  PageableResponse.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

struct PageableResponse<Result> {
    let offset: UInt
    let limit: UInt
    let result: Result

    func nextPageParameters() -> PagingParameters {
        return PagingParameters(limit: limit, offset: offset + limit)
    }
}

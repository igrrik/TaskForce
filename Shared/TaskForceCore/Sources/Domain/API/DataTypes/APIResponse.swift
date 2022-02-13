//
//  APIResponse.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

public class APIResponse<ResultElement: Decodable>: Decodable {
    struct Data: Decodable {
        let offset: UInt
        let limit: UInt
        let total: UInt
        let count: UInt
        let results: [ResultElement]
    }

    let code: Int
    let status: String
    let data: APIResponse.Data

    var offset: UInt { data.offset }
    var limit: UInt { data.limit }

    init(code: Int, status: String, data: APIResponse.Data) {
        self.code = code
        self.status = status
        self.data = data
    }
}

final class APISingleElementResponse<ResultElement: Decodable>: APIResponse<ResultElement> {
    var result: ResultElement {
        guard let first = data.results.first else {
            fatalError("Expected to have one element")
        }
        return first
    }
}

final class APIMultipleElementsResponse<ResultElement: Decodable>: APIResponse<ResultElement> {
    var results: [ResultElement] { data.results }
}

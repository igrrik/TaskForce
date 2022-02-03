//
//  APIResponse.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

struct APIResponse<ResultElement: Decodable>: Decodable {
    let code: Int
    let status: String
    let data: APIResponse.Data

    struct Data: Decodable {
        let offset: UInt
        let limit: UInt
        let total: UInt
        let count: UInt
        let results: [ResultElement]
    }
}

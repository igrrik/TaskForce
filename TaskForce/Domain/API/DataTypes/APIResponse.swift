//
//  APIResponse.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

struct APIResponse<Result: Decodable>: Decodable {
    let code: Int
    let status: String
    let data: APIResponse.Data

    struct Data: Decodable {
        let offset: Int
        let limit: Int
        let total: Int
        let count: Int
        let results: [Result]
    }
}

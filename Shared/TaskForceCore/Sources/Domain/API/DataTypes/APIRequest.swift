//
//  APIRequest.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

public protocol APIRequest {
    associatedtype ResultElement: Decodable
    associatedtype Response: APIResponse<ResultElement>

    var method: HTTPMethod { get }
    var endpoint: APIEndpoint { get }
    var queryItems: [URLQueryItem] { get }
}

extension APIRequest {
    var method: HTTPMethod { .GET }
}

protocol APIPageableRequest: APIRequest {
    var limit: UInt { get }
    var offset: UInt { get }
}

public enum HTTPMethod: String {
    case GET
    case POST

    var value: String { rawValue.uppercased() }
}

public struct APIEndpoint: Equatable {
    enum Resource: String {
        case characters
        case comics
    }

    let path: String

    init(base: String = "/v1/public", resource: Resource, lastPathComponent: String? = nil) {
        self.path = [base, resource.rawValue, lastPathComponent]
            .compactMap { $0 }
            .joined(separator: "/")
    }
}

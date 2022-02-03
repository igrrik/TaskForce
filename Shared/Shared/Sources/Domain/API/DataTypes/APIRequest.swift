//
//  APIRequest.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

protocol APIRequest {
    associatedtype Response: Decodable

    var method: HTTPMethod { get }
    var resource: APIResource { get }
    var path: String? { get }
    var queryItems: [URLQueryItem] { get }
}

extension APIRequest {
    var method: HTTPMethod { .GET }
}

protocol APIPageableRequest: APIRequest {
    var limit: UInt { get }
    var offset: UInt { get }
}

enum HTTPMethod: String {
    case GET
    case POST

    var value: String { rawValue.uppercased() }
}

enum APIResource: String {
    case characters
    case comics
}

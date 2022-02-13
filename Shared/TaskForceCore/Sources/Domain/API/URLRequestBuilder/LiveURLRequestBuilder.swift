//
//  LiveURLRequestBuilder.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation
import Combine

public final class LiveURLRequestBuilder: URLRequestBuilder {
    private let scheme: String
    private let host: String
    private let privateKey: String
    private let publicKey: String
    private let headers: [String: String] = ["Accept": "application/json"]
    private let randomStringProvider: () -> String
    private let hasher: APIHasher
    private let timeoutInterval: TimeInterval = 10.0
    private let cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy

    public init(
        scheme: String,
        host: String,
        privateKey: String,
        publicKey: String,
        hasher: APIHasher,
        randomStringProvider: @escaping () -> String
    ) {
        self.scheme = scheme
        self.host = host
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.hasher = hasher
        self.randomStringProvider = randomStringProvider
    }

    public func makeURLRequest<T: APIRequest>(from request: T) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = request.endpoint.path
        components.queryItems = try generalQueryItems() + request.queryItems

        guard let url = components.url else {
            throw URLConstructionFailure(components: components)
        }
        var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        urlRequest.httpMethod = request.method.value
        urlRequest.allHTTPHeaderFields = headers
        return urlRequest
    }

    private func generalQueryItems() throws -> [URLQueryItem] {
        let tsParameter = randomStringProvider()
        let stringToHash = "\(tsParameter)\(privateKey)\(publicKey)"
        let hash = try hasher.hash(stringToHash)

        return [
            .init(name: "apikey", value: publicKey),
            .init(name: "ts", value: tsParameter),
            .init(name: "hash", value: hash)
        ]
    }
}

extension LiveURLRequestBuilder {
    struct URLConstructionFailure: LocalizedError {
        let components: URLComponents
        var errorDescription: String? { "Failed to obtain URL from components: \(components)"}
    }
}

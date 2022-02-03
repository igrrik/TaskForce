//
//  LiveURLRequestBuilder.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation
import Combine
import CryptoKit

final class LiveURLRequestBuilder: URLRequestBuilder {
    private let scheme: String
    private let host: String
    private let privateKey: String
    private let publicKey: String
    private let headers: [String: String] = ["Accept": "application/json"]
    private let randomStringProvider: () -> String
    private let hasher: (String) -> String

    init(
        scheme: String,
        host: String,
        privateKey: String,
        publicKey: String,
        hasher: @escaping (String) -> String,
        randomStringProvider: @escaping () -> String
    ) {
        self.scheme = scheme
        self.host = host
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.hasher = hasher
        self.randomStringProvider = randomStringProvider
    }

    func makeURLRequest<T: APIRequest>(from request: T) -> URLRequest? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = request.path
        components.queryItems = request.queryItems + generalQueryItems()
        guard let url = components.url else {
            return nil
        }
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        urlRequest.httpMethod = request.method.value
        urlRequest.allHTTPHeaderFields = headers
        return urlRequest
    }

    private func generalQueryItems() -> [URLQueryItem] {
        let tsParameter = randomStringProvider()
        var hash = "\(tsParameter)\(privateKey)\(publicKey)"
        hash = hasher(hash)

        return [
            .init(name: "apikey", value: publicKey),
            .init(name: "ts", value: tsParameter),
            .init(name: "hash", value: hash)
        ]
    }
}

extension String {
    func md5() -> String? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        return Insecure.MD5
            .hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

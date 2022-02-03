//
//  LiveAPIClient.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation
import Combine

final class LiveAPIClient: APIClient {
    private let session: URLSession
    private let urlRequestBuilder: URLRequestBuilder
    private let decoder: JSONDecoder
    private let delegateQueue: DispatchQueue

    init(
        session: URLSession,
        urlRequestBuilder: URLRequestBuilder,
        decoder: JSONDecoder,
        delegateQueue: DispatchQueue
    ) {
        self.session = session
        self.urlRequestBuilder = urlRequestBuilder
        self.decoder = decoder
        self.delegateQueue = delegateQueue
    }

    func execute<T: APIRequest>(request: T) -> AnyPublisher<T.Response, Error> {
        guard let urlRequest = urlRequestBuilder.makeURLRequest(from: request) else {
            return Fail(error: Failure.failedToCreateURLRequest).eraseToAnyPublisher()
        }
        return session
            .dataTaskPublisher(for: urlRequest)
            .mapError { $0 as Error }
            .handleEvents(
                receiveOutput: { output in
                    print(output.response)
                },
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        break
                    }
                }
            )
            .map(\.data)
            .decode(type: T.Response.self, decoder: decoder)
            .receive(on: delegateQueue)
            .eraseToAnyPublisher()
    }
}

extension LiveAPIClient {
    enum Failure: LocalizedError {
        case failedToCreateURLRequest
        case urlError(URLError)
    }
}

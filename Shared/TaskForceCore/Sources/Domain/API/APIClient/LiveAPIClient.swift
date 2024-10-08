//
//  LiveAPIClient.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation
import Combine

public typealias DataTaskPublisher = AnyPublisher<(data: Data, response: URLResponse), Error>

public final class LiveAPIClient: APIClient {
    private let urlRequestBuilder: URLRequestBuilder
    private let decoder: JSONDecoder
    private let delegateQueue: DispatchQueue
    private let dataTaskPublisherProducer: (URLRequest) -> DataTaskPublisher

    public init(
        urlRequestBuilder: URLRequestBuilder,
        dataTaskPublisherProducer: @escaping (URLRequest) -> DataTaskPublisher,
        decoder: JSONDecoder,
        delegateQueue: DispatchQueue
    ) {
        self.urlRequestBuilder = urlRequestBuilder
        self.dataTaskPublisherProducer = dataTaskPublisherProducer
        self.decoder = decoder
        self.delegateQueue = delegateQueue
    }

    public convenience init(
        urlRequestBuilder: URLRequestBuilder,
        session: URLSession,
        decoder: JSONDecoder,
        delegateQueue: DispatchQueue
    ) {
        let producer: (URLRequest) -> DataTaskPublisher = { request in
            session.dataTaskPublisher(for: request)
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        self.init(
            urlRequestBuilder: urlRequestBuilder,
            dataTaskPublisherProducer: producer,
            decoder: decoder,
            delegateQueue: delegateQueue
        )
    }

    public func execute<T: APIRequest>(request: T) -> AnyPublisher<T.Response, Error> {
        urlRequestBuilder
            .makeURLRequestPublisher(from: request)
            .makeDataTaskPublisher(dataTaskPublisherProducer)
            .map(\.data)
            .decode(type: T.Response.self, decoder: decoder)
            .receive(on: delegateQueue)
            .eraseToAnyPublisher()
    }
}

private extension Publisher where Output == URLRequest, Failure == Error {
    func makeDataTaskPublisher(_ producer: @escaping (URLRequest) -> DataTaskPublisher) -> DataTaskPublisher {
        flatMap { producer($0) }.eraseToAnyPublisher()
    }
}

private extension URLRequestBuilder {
    func makeURLRequestPublisher<T: APIRequest>(from request: T) -> AnyPublisher<URLRequest, Error> {
        Deferred {
            Just(request)
                .tryMap(makeURLRequest(from:))
        }
        .eraseToAnyPublisher()
    }
}

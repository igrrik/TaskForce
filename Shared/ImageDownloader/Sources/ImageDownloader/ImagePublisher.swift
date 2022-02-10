//
//  ImagePublisher.swift
//  
//
//  Created by Igor Kokoev on 11.02.2022.
//

import UIKit
import Combine
import Kingfisher

struct ImagePublisher: Publisher {
    typealias Output = UIImage
    typealias Failure = Error

    enum Configuration {
        case failure(Error)
        case url(URL, KingfisherManager)
    }

    let configuration: Configuration

    func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = ImageProviderSubscription(subscriber: subscriber, configuration: configuration)
        subscriber.receive(subscription: subscription)
    }
}

private final class ImageProviderSubscription<S: Subscriber>: Subscription
where S.Input == UIImage, S.Failure == Error {
    private let configuration: ImagePublisher.Configuration
    private var subscriber: S?
    private var downloadTask: DownloadTask?

    init(subscriber: S, configuration: ImagePublisher.Configuration) {
        self.subscriber = subscriber
        self.configuration = configuration
    }

    func request(_ demand: Subscribers.Demand) {
        switch configuration {
        case let .failure(error):
            _ = subscriber?.receive(completion: .failure(error))
        case let .url(url, kingfisher):
            downloadTask = kingfisher.retrieveImage(with: url) { [weak self] result in
                switch result {
                case .success(let imageResult):
                    _ = self?.subscriber?.receive(imageResult.image)
                    self?.subscriber?.receive(completion: .finished)
                case .failure(let error):
                    _ = self?.subscriber?.receive(completion: .failure(error))
                }
            }
        }
    }

    func cancel() {
        downloadTask?.cancel()
        subscriber = nil
    }
}

//
//  ImagePublisher.swift
//  
//
//  Created by Igor Kokoev on 11.02.2022.
//

import UIKit
import Combine
import Kingfisher

protocol ImageDownloadTask {
    func cancel()
}

protocol ImageRetriver {
    func retrieveImage(with url: URL, completionHandler: ((Result<UIImage, Error>) -> Void)?) -> ImageDownloadTask?
}

extension Kingfisher.DownloadTask: ImageDownloadTask {}

extension KingfisherManager: ImageRetriver {
    func retrieveImage(with url: URL, completionHandler: ((Result<UIImage, Error>) -> Void)?) -> ImageDownloadTask? {
        retrieveImage(with: url, options: nil, progressBlock: nil, downloadTaskUpdated: nil) { result in
            switch result {
            case .success(let imageResult):
                completionHandler?(.success(imageResult.image))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
}

struct ImagePublisher: Publisher {
    typealias Output = UIImage
    typealias Failure = Error

    let url: URL
    let imageRetriever: ImageRetriver

    func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = ImageProviderSubscription(
            subscriber: subscriber,
            url: url,
            imageRetriever: imageRetriever
        )
        subscriber.receive(subscription: subscription)
    }
}

private final class ImageProviderSubscription<S: Subscriber>: Subscription
where S.Input == UIImage, S.Failure == Error {
    private let url: URL
    private let imageRetriever: ImageRetriver
    private var subscriber: S?
    private var downloadTask: ImageDownloadTask?

    init(subscriber: S, url: URL, imageRetriever: ImageRetriver) {
        self.subscriber = subscriber
        self.url = url
        self.imageRetriever = imageRetriever
    }

    func request(_ demand: Subscribers.Demand) {        
        downloadTask = imageRetriever.retrieveImage(with: url) { [weak self] result in
            switch result {
            case .success(let image):
                _ = self?.subscriber?.receive(image)
                self?.subscriber?.receive(completion: .finished)
            case .failure(let error):
                _ = self?.subscriber?.receive(completion: .failure(error))
            }
        }
    }

    func cancel() {
        downloadTask?.cancel()
        subscriber = nil
    }
}

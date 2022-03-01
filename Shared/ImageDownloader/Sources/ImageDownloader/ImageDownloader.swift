//
//  ImageDownloader.swift
//
//
//  Created by Igor Kokoev on 07.02.2022.
//

import UIKit
import Combine
import Kingfisher

public protocol ImageDownloader {
    func downloadImage(with url: URL) -> AnyPublisher<UIImage, Error>
    func prefetchImages(with urls: [URL])
}

public final class KingfisherImageDownloader: ImageDownloader {
    private let kingfisher: KingfisherManager

    public init(kingfisher: KingfisherManager = .shared) {
        self.kingfisher = kingfisher
    }

    public func downloadImage(with url: URL) -> AnyPublisher<UIImage, Error> {
        ImagePublisher(url: url, imageRetriever: kingfisher)
            .eraseToAnyPublisher()
    }

    public func prefetchImages(with urls: [URL]) {
        ImagePrefetcher(urls: urls, options: [.downloader(kingfisher.downloader)])
            .start()
    }
}

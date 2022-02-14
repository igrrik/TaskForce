//
//  CharactersListCellModel.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 13.02.2022.
//

import UIKit
import ImageDownloader
import Combine
import TaskForceCore

final class CharactersListCellModel: ObservableObject, Hashable {
    let name: String
    let characterId: UInt

    @Published private(set) var image: UIImage?

    private let id = UUID()
    private let imageURL: URL?
    private let imageDownloader: ImageDownloader
    private var cancellableBag = Set<AnyCancellable>()

    init(characterId: UInt, name: String, imageURL: URL?, imageDownloader: ImageDownloader) {
        self.characterId = characterId
        self.name = name
        self.imageURL = imageURL
        self.imageDownloader = imageDownloader
    }

    convenience init(character: Character, imageDownloader: ImageDownloader) {
        self.init(
            characterId: character.id,
            name: character.name,
            imageURL: character.thumbnail.urlForVariant(.square(.medium)),
            imageDownloader: imageDownloader
        )
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CharactersListCellModel, rhs: CharactersListCellModel) -> Bool {
        lhs.id == rhs.id
    }

    func downloadImage() {
        guard image == nil, let imageURL = imageURL else {
            return
        }
        imageDownloader
            .downloadImage(with: imageURL)
            .sink { completion in
                guard case .failure(let error) = completion else {
                    return
                }
                assertionFailure("Failed to download image due to: \(error)")
            } receiveValue: { [weak self] image in
                self?.image = image
            }
            .store(in: &cancellableBag)
    }
}

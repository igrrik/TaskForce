//
//  CharacterDetailsViewModel.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 07.02.2022.
//

import UIKit
import Combine
import TaskForceCore
import ImageDownloader

final class CharacterDetailsViewModel: ObservableObject {
    let name: String
    let info: String

    @Published private(set) var image: UIImage?
    @Published private(set) var isRecruited: Bool

    private let character: Character
    private let squadManager: SquadManager
    private let imageDownloader: ImageDownloader
    private var cancellableBag = Set<AnyCancellable>()

    init(character: Character, squadManager: SquadManager, imageDownloader: ImageDownloader) {
        self.character = character
        self.name = character.name
        self.info = character.info.isEmpty ? L10n.characterDetailsNoDescription : character.info
        self.isRecruited = character.isRecruited
        self.squadManager = squadManager
        self.imageDownloader = imageDownloader
        downloadImage()
    }

    public func toggleRecruitmentStatus() {
        if isRecruited {
            squadManager.fire(character)
        } else {
            squadManager.recruit(character)
        }
        isRecruited.toggle()
    }

    private func downloadImage() {
        let mediumImage = imageDownloader.downloadImage(with: character.thumbnail.urlForVariant(.square(.medium)))
        let fullsizeImage = imageDownloader.downloadImage(with: character.thumbnail.urlForVariant(.square(.fantastic)))
        mediumImage
            .merge(with: fullsizeImage)
            .sink { completion in
                guard case .failure(let error) = completion else {
                    return
                }
                assertionFailure("Failed to obtain image due to error: \(error)")
            } receiveValue: { [weak self] image in
                self?.image = image
            }
            .store(in: &cancellableBag)
    }
}

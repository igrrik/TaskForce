//
//  CharactersListCell.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 13.02.2022.
//

import UIKit
import Combine

final class CharactersListCell: UICollectionViewListCell {
    typealias Model = CharactersListCellModel

    private var cancellableBag = Set<AnyCancellable>()

    static func cellRegistration() -> UICollectionView.CellRegistration<CharactersListCell, Model> {
        .init { cell, _, model in
            cell.configure(with: model)
        }
    }

    override func prepareForReuse() {
        cancellableBag = .init()
        super.prepareForReuse()
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        guard var backgroundConfiguration = backgroundConfiguration else {
            return
        }
        if state.isSelected || state.isHighlighted {
            backgroundConfiguration.backgroundColor = Asset.Colors.marvelGreyMedium.color
        } else {
            backgroundConfiguration.backgroundColor = Asset.Colors.marvelGreyLight.color
        }
        self.backgroundConfiguration = backgroundConfiguration
        super.updateConfiguration(using: state)
    }

    private func configure(with model: Model) {
        var content = UIListContentConfiguration.valueCell()
        content.text = model.name
        content.textProperties.color = .white
        content.textProperties.font = .systemFont(ofSize: Constants.textFontSize, weight: .semibold)

        content.imageProperties.maximumSize = Constants.imageSize
        content.imageProperties.cornerRadius = Constants.imageCornerRadius
        contentConfiguration = content

        var background = UIBackgroundConfiguration.listPlainCell()
        background.cornerRadius = Constants.cornerRadius
        backgroundConfiguration = background

        var options = UICellAccessory.DisclosureIndicatorOptions()
        options.tintColor = Constants.disclosureIndicatorTintColor
        accessories = [.disclosureIndicator(options: options)]

        downloadImage(model: model)
    }

    private func downloadImage(model: Model) {
        guard var contentConfiguration = contentConfiguration as? UIListContentConfiguration else {
            assertionFailure("Content configuration can't be nil")
            return
        }
        model.$image
            .sink { completion in
                guard case .failure(let error) = completion else {
                    return
                }
                assertionFailure("Failed to download image due to: \(error)")
            } receiveValue: { [weak self] image in
                contentConfiguration.image = image
                self?.contentConfiguration = contentConfiguration
            }
            .store(in: &cancellableBag)
        model.downloadImage()
    }
}

private enum Constants {
    static let disclosureIndicatorTintColor: UIColor = .init(white: 1.0, alpha: 0.2)
    static let imageSize: CGSize = CGSize(width: 48, height: 48)
    static let imageCornerRadius: CGFloat = 24
    static let cornerRadius: CGFloat = 8
    static let textFontSize: CGFloat = 17
}

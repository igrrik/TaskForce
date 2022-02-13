//
//  SquadMemberCell.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 13.02.2022.
//

import UIKit
import Combine

final class SquadMemberCell: UICollectionViewCell {
    typealias Model = CharactersListCellModel

    private lazy var imageView = UIImageView()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    private var cancellableBag = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        cancellableBag = .init()
        super.prepareForReuse()
    }

    static func cellRegistration() -> UICollectionView.CellRegistration<SquadMemberCell, Model> {
        .init { cell, _, model in
            cell.configure(with: model)
        }
    }

    private func configure(with model: Model) {
        titleLabel.text = model.name
        model.$image
            .assign(to: \.image, on: imageView)
            .store(in: &cancellableBag)
        model.downloadImage()
    }

    private func configureLayout() {
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = (contentView.frame.width / 2.0).rounded()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])

        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
    }
}

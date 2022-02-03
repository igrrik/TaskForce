//
//  CharacterDetailsViewController.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 03.02.2022.
//

import UIKit

final class CharacterDetailsViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case image
        case description
    }
    private let dataSource: [CharacterDetailsCellModel]
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())

    init(hero: Hero) {
        self.dataSource = [
            ImageCellModel(image: hero.image),
            NameCellModel(name: hero.name),
            DescriptionCellModel(descriptionText: hero.descriptionText)
        ]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }

    func configureCollectionView() {
        collectionView.backgroundColor = .marvelBackground
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCellModel.reuseIdentifier)
        collectionView.register(NameCell.self, forCellWithReuseIdentifier: NameCellModel.reuseIdentifier)
        collectionView.register(DescriptionCell.self, forCellWithReuseIdentifier: DescriptionCellModel.reuseIdentifier)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { index, env in
            guard let sectionKind = Section(rawValue: index) else { fatalError() }

            let section: NSCollectionLayoutSection

            if sectionKind == .image {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                section = .init(group: group)
            } else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                section = .init(group: group)
                section.contentInsets = .init(top: 24, leading: 16, bottom: 16, trailing: 16)
            }

            return section
        }
    }
}

extension CharacterDetailsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = dataSource[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: type(of: item).reuseIdentifier, for: indexPath)

        if let imageCellModel = item as? ImageCellModel, let imageCell = cell as? ImageCell {
            imageCell.imageView.image = imageCellModel.image
        } else if let nameCellModel = item as? NameCellModel, let nameCell = cell as? NameCell {
            nameCell.nameLabel.text = nameCellModel.name
        } else if let textCellModel = item as? DescriptionCellModel, let textCell = cell as? DescriptionCell {
            textCell.descriptionLabel.text = textCellModel.descriptionText
        } else {
            fatalError()
        }

//        let descriptionCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DescriptionCellModel> { cell, _, model in
//            var content = UIListContentConfiguration.cell()
//            content.text = model.descriptionText
//            content.textProperties.numberOfLines = 0
//            content.textProperties.color = .white
//            content.textProperties.font = .systemFont(ofSize: 17, weight: .regular)
//            cell.contentConfiguration = content
//        }

        return cell
    }
}

protocol CharacterDetailsCellModel {
    static var reuseIdentifier: String { get }
}

extension CharacterDetailsCellModel {
    static var reuseIdentifier: String { String(describing: type(of: self)) }
}

struct ImageCellModel: CharacterDetailsCellModel {
    let image: UIImage
}

struct NameCellModel: CharacterDetailsCellModel {
    let name: String
}

struct DescriptionCellModel: CharacterDetailsCellModel {
    let descriptionText: String
}

private final class ImageCell: UICollectionViewCell {
    private(set) lazy var imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureLayout() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

private final class NameCell: UICollectionViewCell {
    private(set) lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureLayout() {
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

private final class DescriptionCell: UICollectionViewCell {
    private(set) lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureLayout() {
        contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

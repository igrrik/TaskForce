//
//  ViewController.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 01.02.2022.
//

import UIKit

class ViewController: UIViewController {

    enum Section: Int, CaseIterable {
        case squad
        case allCharacters
    }

    private lazy var dataSource = createDataSource()
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        applyInitialSnapshots()
    }

    func configureNavigationBar() {
        title = "Marvel"

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .marvelBackground

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        navigationItem.titleView = UIImageView(image: UIImage(named: "marvel_logo"))
    }

    func configureCollectionView() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .marvelBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

    private func createDataSource() -> UICollectionViewDiffableDataSource<Section, Hero> {
        let gridCellRegistration = UICollectionView.CellRegistration<SquadCell, Hero> { cell, _, hero in
            cell.configure(with: hero)
        }
        let listCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Hero> { cell, _, hero in
            var content = UIListContentConfiguration.valueCell()
            content.text = hero.name
            content.textProperties.color = .white
            content.textProperties.font = .systemFont(ofSize: 17, weight: .semibold)
            content.image = hero.image
            content.imageProperties.maximumSize = CGSize(width: 48, height: 48)
            content.imageProperties.cornerRadius = 24

            var background = UIBackgroundConfiguration.listPlainCell()
            background.cornerRadius = 8
            background.backgroundColor = .marvelGreyLight

            cell.contentConfiguration = content
            cell.backgroundConfiguration = background
            var options = UICellAccessory.DisclosureIndicatorOptions()
            options.tintColor = .init(white: 1.0, alpha: 0.2)
            cell.accessories = [.disclosureIndicator(options: options)]
        }
        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: .squadSectionHeaderKind) {
            (supplementaryView, string, indexPath) in
            supplementaryView.label.text = "My Squad"
        }

        let dataSource = UICollectionViewDiffableDataSource<Section, Hero>(collectionView: collectionView) { collectionView, indexPath, hero in
            guard let sectionKind = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }
            switch sectionKind {
            case .squad:
                return collectionView.dequeueConfiguredReusableCell(
                    using: gridCellRegistration,
                    for: indexPath,
                    item: hero
                )
            case .allCharacters:
                return collectionView.dequeueConfiguredReusableCell(
                    using: listCellRegistration,
                    for: indexPath,
                    item: hero
                )
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, index in
            guard kind == .squadSectionHeaderKind else { fatalError() }
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }

        return dataSource
    }

    private func createLayout() -> UICollectionViewLayout {
        let provider: UICollectionViewCompositionalLayoutSectionProvider = { sectionIndex, environment in
            guard let sectionKind = Section(rawValue: sectionIndex) else {
                return nil
            }

            let section: NSCollectionLayoutSection

            if sectionKind == .squad {

                let leadingInset: CGFloat = 16.0
                let groupWidth = (environment.container.contentSize.width - leadingInset) * 0.225

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(groupWidth), heightDimension: .absolute(116))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: leadingInset, bottom: 16, trailing: 16)

                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(25)
                    ),
                    elementKind: .squadSectionHeaderKind,
                    alignment: .topLeading
                )
                section.boundarySupplementaryItems = [sectionHeader]

            } else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 16
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
//                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
//                configuration.backgroundColor = .marvelBackground
//                section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            }

            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: provider)
    }

    private func applyInitialSnapshots() {
        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, Hero>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)

        // recents (orthogonal scroller)

        let squadHeroes: [Hero] = [
            .spiderMan,
            .ironMan,
            .blackPanther,
            .hulk,
            .thor,
            .hawkEye,
            .blackWidow,
            .wolverine,
            .dareDevil,
            .magneto
        ]
        var squadSnaphot = NSDiffableDataSourceSectionSnapshot<Hero>()
        squadSnaphot.append(squadHeroes)
        dataSource.apply(squadSnaphot, to: .squad, animatingDifferences: false)

        // list of all + outlines

        let allHeroes: [Hero] = [
            .spiderMan,
            .ironMan,
            .blackPanther,
            .hulk,
            .thor,
            .hawkEye,
            .blackWidow,
            .wolverine,
            .dareDevil,
            .magneto
        ]
        var allSnapshot = NSDiffableDataSourceSectionSnapshot<Hero>()
        allSnapshot.append(allHeroes)
        dataSource.apply(allSnapshot, to: .allCharacters, animatingDifferences: false)
    }
}

extension ViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let hero = dataSource.itemIdentifier(for: indexPath) else { fatalError() }
        let viewController = CharacterDetailsViewController(hero: hero)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

private extension UIImage {
    static let batman = UIImage(named: "batman")!
    static let superman = UIImage(named: "superman")!
}

struct Hero: Hashable {
    let identifier: UUID = .init()
    let name: String
    let image: UIImage
    let descriptionText: String = "Rick Jones has been Hulk's best bud since day one, but now he's more than a friend...he's a teammate! Transformed by a Gamma energy explosion, A-Bomb's thick, armored skin is just as strong and powerful as it is blue. And when he curls into action, he uses it like a giant bowling ball of destruction!Rick Jones has been Hulk's best bud since day one, but now he's more than a friend...he's a teammate! Transformed by a Gamma energy explosion, A-Bomb's thick, armored skin is just as strong and powerful as it is blue. And when he curls into action, he uses it like a giant bowling ball of destruction!Rick Jones has been Hulk's best bud since day one, but now he's more than a friend...he's a teammate! Transformed by a Gamma energy explosion, A-Bomb's thick, armored skin is just as strong and powerful as it is blue. And when he curls into action, he uses it like a giant bowling ball of destruction!Rick Jones has been Hulk's best bud since day one, but now he's more than a friend...he's a teammate! Transformed by a Gamma energy explosion, A-Bomb's thick, armored skin is just as strong and powerful as it is blue. And when he curls into action, he uses it like a giant bowling ball of destruction!Rick Jones has been Hulk's best bud since day one, but now he's more than a friend...he's a teammate! Transformed by a Gamma energy explosion, A-Bomb's thick, armored skin is just as strong and powerful as it is blue. And when he curls into action, he uses it like a giant bowling ball of destruction!Rick Jones has been Hulk's best bud since day one, but now he's more than a friend...he's a teammate! Transformed by a Gamma energy explosion, A-Bomb's thick, armored skin is just as strong and powerful as it is blue. And when he curls into action, he uses it like a giant bowling ball of destruction!he uses it like a giant bowling ball of destruction!"

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: Hero, rhs: Hero) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    static var spiderMan: Hero { Hero(name: "Spider-Man", image: .batman) }
    static var ironMan: Hero { Hero(name: "Iron Man", image: .superman) }
    static var blackPanther: Hero { Hero(name: "Black Panther", image: .batman) }
    static var hulk: Hero { Hero(name: "Hulk", image: .superman) }
    static var thor: Hero { Hero(name: "Thor", image: .batman) }
    static var hawkEye: Hero { Hero(name: "Hawkeye", image: .superman) }
    static var blackWidow: Hero { Hero(name: "Black Widow", image: .batman) }
    static var wolverine: Hero { Hero(name: "Wolverine", image: .superman) }
    static var dareDevil: Hero { Hero(name: "Daredevil", image: .batman) }
    static var magneto: Hero { Hero(name: "Magneto", image: .superman) }
}

private final class SquadCell: UICollectionViewCell {
    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with hero: Hero) {
        imageView.image = hero.image
        titleLabel.text = hero.name
    }

    private func configureLayout() {
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textAlignment = .center

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

private final class TitleSupplementaryView: UICollectionReusableView {
    let label = UILabel()
    static let reuseIdentifier = "title-supplementary-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure() {
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension UIColor {
    static let marvelBackground: UIColor = #colorLiteral(red: 0.1774274111, green: 0.1937928796, blue: 0.2227301598, alpha: 0.9)
    static let marvelGreyLight: UIColor = #colorLiteral(red: 0.2941176471, green: 0.3176470588, blue: 0.368627451, alpha: 1)
    static let marvelGreyDark: UIColor = #colorLiteral(red: 0.2117647059, green: 0.231372549, blue: 0.2705882353, alpha: 1)
}

private extension String {
    static let squadSectionHeaderKind = "squadSectionHeaderKind"
}

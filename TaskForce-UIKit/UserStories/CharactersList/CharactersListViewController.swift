//
//  CharactersListViewController.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 01.02.2022.
//

import UIKit
import Combine
import TaskForceCore
import ImageDownloader

extension UIColor {
    static let marvelBackground: UIColor = #colorLiteral(red: 0.1774274111, green: 0.1937928796, blue: 0.2227301598, alpha: 0.9)
    static let marvelGreyLight: UIColor = #colorLiteral(red: 0.2941176471, green: 0.3176470588, blue: 0.368627451, alpha: 1)
    static let marvelGreyDark: UIColor = #colorLiteral(red: 0.2117647059, green: 0.231372549, blue: 0.2705882353, alpha: 1)
}

final class CharactersListViewController: UIViewController {
    private let viewModel: CharactersListViewModel
    private var cancellableBag = Set<AnyCancellable>()
    private lazy var dataSource: DataSource = DataSource.create(collectionView: collectionView)
    private lazy var collectionView = UICollectionView(
        frame: view.bounds,
        collectionViewLayout: CharactersListSection.makeCompositionalLayout()
    )

    init(viewModel: CharactersListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        applyInitialSnapshots()
        configureBindings()
        viewModel.obtainInitialData()
    }
}

extension CharactersListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = CharacterDetailsViewController(hero: .blackPanther)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

private extension CharactersListViewController {
    func configureNavigationBar() {

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .marvelBackground

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        // TODO: swiftgen
        navigationItem.titleView = UIImageView(image: UIImage(named: "marvel_logo"))
    }

    func configureCollectionView() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .marvelBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

    func applyInitialSnapshots() {
        let sections = CharactersListSection.allCases
        var snapshot = NSDiffableDataSourceSnapshot<CharactersListSection, CharactersListCellModel>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func configureBindings() {
        viewModel.$squad
            .makeSnapshot()
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, to: .squad, animatingDifferences: true)
            }
            .store(in: &cancellableBag)

        viewModel.$allCharacters
            .makeSnapshot()
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, to: .allCharacters, animatingDifferences: true)
            }
            .store(in: &cancellableBag)
    }
}

private typealias DataSource = UICollectionViewDiffableDataSource<CharactersListSection, CharactersListCellModel>

private extension DataSource {
    static func create(collectionView: UICollectionView) -> DataSource {
        let squadCellRegistration = SquadMemberCell.cellRegistration()
        let listCellRegistration = CharactersListCell.cellRegistration()
        let headerRegistration = CharactersListTitleView.headerRegistration { titleView, _, _ in
            // TODO: Replace with localized string
            titleView.label.text = "My Squad"
        }

        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, model in
            guard let sectionKind = CharactersListSection(rawValue: indexPath.section) else {
                fatalError("Unknown section")
            }
            switch sectionKind {
            case .squad:
                return collectionView.dequeueConfiguredReusableCell(
                    using: squadCellRegistration,
                    for: indexPath,
                    item: model
                )
            case .allCharacters:
                return collectionView.dequeueConfiguredReusableCell(
                    using: listCellRegistration,
                    for: indexPath,
                    item: model
                )
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, index in
            guard kind == CharactersListTitleView.kind else { fatalError() }
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }

        return dataSource
    }
}

private extension CharactersListSection {
    static func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let provider: UICollectionViewCompositionalLayoutSectionProvider = { sectionIndex, environment in
            guard let section = Self(rawValue: sectionIndex) else {
                return nil
            }
            switch section {
            case .squad:
                return makeSquadLayout(environment: environment)
            case .allCharacters:
                return makeAllCharactersLayout()
            }
        }

        return UICollectionViewCompositionalLayout(sectionProvider: provider)
    }

    private static func makeSquadLayout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let leadingInset: CGFloat = 16.0
        let groupWidth = (environment.container.contentSize.width - leadingInset) * 0.225

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(groupWidth), heightDimension: .absolute(116))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: leadingInset, bottom: 16, trailing: 16)

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(25)
            ),
            elementKind: CharactersListTitleView.kind,
            alignment: .topLeading
        )
        sectionLayout.boundarySupplementaryItems = [sectionHeader]
        return sectionLayout
    }

    private static func makeAllCharactersLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.interGroupSpacing = 16
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        return sectionLayout
    }
}

private extension Publisher where Output == [CharactersListCellModel], Failure == Never {
    func makeSnapshot() -> AnyPublisher<NSDiffableDataSourceSectionSnapshot<CharactersListCellModel>, Never> {
        map { models -> NSDiffableDataSourceSectionSnapshot<CharactersListCellModel> in
            var snapshot = NSDiffableDataSourceSectionSnapshot<CharactersListCellModel>()
            snapshot.append(models)
            return snapshot
        }
        .eraseToAnyPublisher()
    }
}

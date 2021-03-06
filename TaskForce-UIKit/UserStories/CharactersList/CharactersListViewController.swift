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

final class CharactersListViewController: UIViewController {
    private let viewModel: CharactersListViewModel
    private var cancellableBag = Set<AnyCancellable>()
    private var selectedItemIndexPath: IndexPath?
    private var numberOfSections: Int = 1
    private lazy var dataSource = DataSource.create(collectionView: collectionView)
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        return indicator
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = CharactersListSection.makeCompositionalLayout(numberOfSections: { [weak self] in
            self?.numberOfSections ?? 1
        })
        return UICollectionView(frame: view.bounds, collectionViewLayout: layout)
    }()

    init(viewModel: CharactersListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureLoadingIndicator()
        applyInitialSnapshots()
        configureBindings()
        viewModel.obtainInitialData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let indexPath = selectedItemIndexPath else {
            return
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension CharactersListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: indexPath) else {
            assertionFailure("Failed to obtain CharactersListCellModel")
            return
        }
        selectedItemIndexPath = indexPath
        viewModel.didSelectCharacter(with: model.characterId)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            viewModel.obtainMoreData()
        }
    }
}

private extension CharactersListViewController {
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Asset.Colors.marvelNavigationBarBackground.color
        appearance.shadowColor = Asset.Colors.marvelGreyLight.color

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        navigationItem.titleView = UIImageView(image: Asset.Images.marvelLogo.image)
    }

    func configureCollectionView() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = Asset.Colors.marvelBackground.color
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

    func configureBindings() {
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellableBag)

        viewModel.$squad
            .makeSnapshot()
            .sink { [weak self] snapshot in
                let numberOfItems = snapshot?.items.count ?? 0
                self?.numberOfSections = numberOfItems > 0 ? 2 : 1
                self?.applySquadSnaphot(snapshot)
            }
            .store(in: &cancellableBag)

        viewModel.$allCharacters
            .makeSnapshot()
            .compactMap { $0 }
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, to: .allCharacters, animatingDifferences: true)
            }
            .store(in: &cancellableBag)

        viewModel.error
            .sink { [weak self] errorString in
                self?.presentError(errorString)
            }
            .store(in: &cancellableBag)
    }

    func configureLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func applyInitialSnapshots() {
        var snapshot = NSDiffableDataSourceSnapshot<CharactersListSection, CharactersListCellModel>()
        snapshot.appendSections([.allCharacters])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func applySquadSnaphot(_ snapshot: NSDiffableDataSourceSectionSnapshot<CharactersListCellModel>?) {
        guard let snapshot = snapshot else {
            var currentSnapshot = dataSource.snapshot()
            currentSnapshot.deleteSections([.squad])
            dataSource.apply(currentSnapshot, animatingDifferences: true)
            return
        }
        if collectionView.numberOfSections > 1 {
            dataSource.apply(snapshot, to: .squad, animatingDifferences: true)
        } else {
            var currentSnapshot = dataSource.snapshot()
            currentSnapshot.insertSections([.squad], beforeSection: .allCharacters)
            dataSource.apply(currentSnapshot, animatingDifferences: true) { [weak self] in
                self?.dataSource.apply(snapshot, to: .squad, animatingDifferences: true)
            }
        }
    }

    func presentError(_ error: String) {
        let controller = UIAlertController(title: L10n.error, message: error, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: L10n.ok, style: .default, handler: nil))
        present(controller, animated: true)
    }
}

private typealias DataSource = UICollectionViewDiffableDataSource<CharactersListSection, CharactersListCellModel>

private extension DataSource {
    static func create(collectionView: UICollectionView) -> DataSource {
        let squadCellRegistration = SquadMemberCell.cellRegistration()
        let listCellRegistration = CharactersListCell.cellRegistration()
        let headerRegistration = CharactersListTitleView.headerRegistration { titleView, _, _ in
            titleView.label.text = L10n.charactersListSquadHeaderTitle
        }

        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, model in
            guard collectionView.numberOfSections > 1 else {
                return collectionView.dequeueConfiguredReusableCell(
                    using: listCellRegistration,
                    for: indexPath,
                    item: model
                )
            }
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
            guard collectionView.numberOfSections > 1 else {
                return nil
            }
            guard kind == CharactersListTitleView.kind else {
                fatalError("Unexpected supplementary view kind: \(kind)")
            }
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }

        return dataSource
    }
}

private extension CharactersListSection {
    enum Constants {
        static let defaultOffset: CGFloat = 16.0
        static let titleHeight: NSCollectionLayoutDimension = .absolute(41.0)
        static let squadGroupHeight: NSCollectionLayoutDimension = .absolute(116.0)
        static let squadGroupWidthMultiplier: CGFloat = 0.225
        static let squadGroupContentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
        static let squadSectionContentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
        static let allCharactersGroupHeight: NSCollectionLayoutDimension = .absolute(80)
        static let allCharactersSectionContentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
    }

    static func makeCompositionalLayout(
        numberOfSections: @escaping () -> Int
    ) -> UICollectionViewCompositionalLayout {
        let provider: UICollectionViewCompositionalLayoutSectionProvider = { sectionIndex, environment in
            guard numberOfSections() > 1 else {
                return makeAllCharactersLayout()
            }
            guard let section = Self(rawValue: sectionIndex) else {
                fatalError("Unexpected sectionIndex: \(sectionIndex)")
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
        let leadingInset = Constants.defaultOffset
        let groupWidth = (environment.container.contentSize.width - leadingInset) * Constants.squadGroupWidthMultiplier

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(groupWidth),
            heightDimension: Constants.squadGroupHeight
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = Constants.squadGroupContentInsets
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        sectionLayout.contentInsets = Constants.squadSectionContentInsets

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: Constants.titleHeight
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
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: Constants.allCharactersGroupHeight
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.interGroupSpacing = Constants.defaultOffset
        sectionLayout.contentInsets = Constants.allCharactersSectionContentInsets
        return sectionLayout
    }
}

private extension Publisher where Output == [CharactersListCellModel], Failure == Never {
    func makeSnapshot() -> AnyPublisher<NSDiffableDataSourceSectionSnapshot<CharactersListCellModel>?, Never> {
        map { models -> NSDiffableDataSourceSectionSnapshot<CharactersListCellModel>? in
            guard !models.isEmpty else {
                return nil
            }
            var snapshot = NSDiffableDataSourceSectionSnapshot<CharactersListCellModel>()
            snapshot.append(models)
            return snapshot
        }
        .eraseToAnyPublisher()
    }
}

//
//  AppModulesFactory.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 13.02.2022.
//

import UIKit
import TaskForceCore

public final class AppModulesFactory {
    private lazy var registry = DependenciesRegistry()

    func makeCharactersListModule() -> (CharactersListViewModel, UIViewController) {
        let viewModel = CharactersListViewModel(
            charactersRepository: registry.charactersRepository,
            imageDownloader: registry.imageDownloader
        )
        let controller = CharactersListViewController(viewModel: viewModel)
        return (viewModel, controller)
    }

    func makeCharacterDetailsModule(_ character: Character) -> (CharacterDetailsViewModel, UIViewController) {
        let viewModel = CharacterDetailsViewModel(
            character: character,
            squadManager: registry.squadManager,
            imageDownloader: registry.imageDownloader
        )
        let controller = CharacterDetailsViewController(viewModel: viewModel)
        return (viewModel, controller)
    }
}

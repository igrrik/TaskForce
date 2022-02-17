//
//  AppModulesFactory.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 13.02.2022.
//

import UIKit
import ImageDownloader
import TaskForceCore

public final class AppModulesFactory {
    private lazy var requestBuilder = LiveURLRequestBuilder(
        scheme: "https",
        host: "gateway.marvel.com",
        privateKey: CredentialsStore.shared.privateKey,
        publicKey: CredentialsStore.shared.publicKey,
        hasher: MD5Hasher(),
        randomStringProvider: Date.provideTimestampString
    )
    private lazy var apiClient = LiveAPIClient(
        urlRequestBuilder: requestBuilder,
        session: .shared,
        decoder: JSONDecoder(),
        delegateQueue: .main
    )
    private lazy var squadManager = InMemorySquadManager()
    private lazy var charactersRepository = LiveCharactersRepository(apiClient: apiClient, squadManager: squadManager)
    private lazy var imageDownloader = KingfisherImageDownloader()

    func makeCharactersListModule() -> (CharactersListViewModel, UIViewController) {
        let viewModel = CharactersListViewModel(
            charactersRepository: charactersRepository,
            imageDownloader: imageDownloader
        )
        let controller = CharactersListViewController(viewModel: viewModel)
        return (viewModel, controller)
    }

    func makeCharacterDetailsModule(_ character: Character) -> (CharacterDetailsViewModel, UIViewController) {
        let viewModel = CharacterDetailsViewModel(
            character: character,
            squadManager: squadManager,
            imageDownloader: imageDownloader
        )
        let controller = CharacterDetailsViewController(viewModel: viewModel)
        return (viewModel, controller)
    }
}

private extension Date {
    static func provideTimestampString() -> String {
        "\(Date().timeIntervalSince1970)"
    }
}

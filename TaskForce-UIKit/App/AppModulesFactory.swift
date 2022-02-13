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
    private lazy var charactersRepository = LiveCharactersRepository(apiClient: apiClient)
    private lazy var imageDownloader = KingfisherImageDownloader()

    func makeCharactersListModule() -> UIViewController {
        let viewModel = CharactersListViewModel(
            charactersRepository: charactersRepository,
            imageDownloader: imageDownloader
        )
        return CharactersListViewController(viewModel: viewModel)
    }

    func makeCharacterDetailsModule(_ character: Character) -> UIViewController {
        fatalError()
    }
}

private extension Date {
    static func provideTimestampString() -> String {
        "\(Date().timeIntervalSince1970)"
    }
}

//
//  DependenciesRegistry.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 19.02.2022.
//

import Foundation
import ImageDownloader
import TaskForceCore

final class DependenciesRegistry {
    private(set) lazy var imageDownloader: ImageDownloader = KingfisherImageDownloader()
    private(set) lazy var squadManager: SquadManager = PersistentSquadManager(
        persistenceController: persistenceController
    )
    private(set) lazy var charactersRepository: CharactersRepository = LiveCharactersRepository(
        apiClient: apiClient,
        squadManager: squadManager
    )

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
    private lazy var persistenceController = CoreDataPersistenceController(
        container: persistentContainer,
        delegateQueue: .main
    )
    private lazy var persistentContainer = CoreDataPersistentContainer()
}

private extension Date {
    static func provideTimestampString() -> String {
        "\(Date().timeIntervalSince1970)"
    }
}

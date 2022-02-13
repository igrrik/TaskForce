//
//  SceneDelegate.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 01.02.2022.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let appModulesFactory = AppModulesFactory()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        // TODO: move to coordinator
        let listController = appModulesFactory.makeCharactersListModule()
        window.rootViewController = UINavigationController(rootViewController: listController)
        window.makeKeyAndVisible()
        self.window = window
    }
}


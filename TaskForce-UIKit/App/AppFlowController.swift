//
//  AppFlowController.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 13.02.2022.
//

import Combine
import UIKit
import TaskForceCore

final class AppFlowController: UINavigationController {
    private let appModulesFactory: AppModulesFactory
    private var cancellableBag = Set<AnyCancellable>()

    init(appModulesFactory: AppModulesFactory) {
        self.appModulesFactory = appModulesFactory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        let (viewModel, controller) = appModulesFactory.makeCharactersListModule()
        handle(routingAction: viewModel.routingAction)
        show(controller, sender: self)
    }

    func showCharacterDetails(character: Character) {
        let (_, controller) = appModulesFactory.makeCharacterDetailsModule(character)
        pushViewController(controller, animated: true)
    }

    private func handle(routingAction: AnyPublisher<CharactersListViewModel.RoutableEvent, Never>) {
        routingAction
            .sink { [weak self] event in
                switch event {
                case .didSelectCharacter(let character):
                    self?.showCharacterDetails(character: character)
                }
            }
            .store(in: &cancellableBag)
    }
}

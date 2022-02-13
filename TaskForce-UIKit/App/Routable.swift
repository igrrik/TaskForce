//
//  Routable.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 13.02.2022.
//

import Foundation
import Combine

protocol Routable {
    associatedtype RoutableEvent

    var routingAction: AnyPublisher<RoutableEvent, Never> { get }
}

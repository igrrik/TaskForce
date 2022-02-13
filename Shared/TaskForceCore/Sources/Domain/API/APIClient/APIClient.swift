//
//  APIClient.swift
//  TaskForce
//
//  Created by Igor Kokoev on 30.01.2022.
//

import Foundation
import Combine

public protocol APIClient {
    func execute<T: APIRequest>(request: T) -> AnyPublisher<T.Response, Error>
}

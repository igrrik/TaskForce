//
//  APIClient.swift
//  TaskForce
//
//  Created by Igor Kokoev on 30.01.2022.
//

import Foundation
import Combine

protocol APIClient {
    func execute<T: APIRequest>(request: T) -> AnyPublisher<APIResponse<T.Response>, Error>
}

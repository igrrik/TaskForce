//
//  URLRequestBuilder.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation
import Combine

public protocol URLRequestBuilder {
    func makeURLRequest<T: APIRequest>(from request: T) throws -> URLRequest
}

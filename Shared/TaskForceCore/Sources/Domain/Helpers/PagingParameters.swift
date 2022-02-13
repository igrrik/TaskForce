//
//  PagingParameters.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

public struct PagingParameters {
    @Clamping(1...100) var limit: UInt = 20
    var offset: UInt = 0

    func nextPageParameters() -> PagingParameters {
        return PagingParameters(limit: limit, offset: offset + limit)
    }
}

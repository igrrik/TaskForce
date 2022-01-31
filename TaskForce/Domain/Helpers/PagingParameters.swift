//
//  PagingParameters.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

struct PagingParameters {
    @Clamping(1...100) var limit: UInt = 20
    var offset: UInt = 0
}

//
//  Hasher.swift
//  
//
//  Created by Igor Kokoev on 05.02.2022.
//

import Foundation

public protocol Hasher {
    func hash(_ string: String) throws -> String
}

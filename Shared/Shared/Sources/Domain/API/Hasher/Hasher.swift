//
//  Hasher.swift
//  
//
//  Created by Igor Kokoev on 05.02.2022.
//

import Foundation

protocol Hasher {
    func hash(_ string: String) throws -> String
}

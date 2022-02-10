//
//  Character.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

struct Character: Identifiable, Decodable, Equatable {
    let id: UInt
    let name: String
    let description: String
    let thumbnail: Thumbnail
    let isRecruited: Bool = false

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case thumbnail
    }
}
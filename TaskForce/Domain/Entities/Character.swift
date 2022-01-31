//
//  Character.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

struct Character: Decodable {
    let id: Int
    let name: String
    let description: String
    let thumbnail: Thumbnail
    let isHired: Bool = false

    struct Thumbnail: Decodable {
        let path: String
        let `extension`: String
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case thumbnail
    }
}

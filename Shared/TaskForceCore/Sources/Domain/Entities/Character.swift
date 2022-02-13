//
//  Character.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

public struct Character: Identifiable, Decodable, Equatable {
    public let id: UInt
    public let name: String
    public let description: String
    public let thumbnail: Thumbnail
    public let isRecruited: Bool = false

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case thumbnail
    }
}

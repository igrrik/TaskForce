//
//  Character.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

public struct Character: Hashable {
    public let id: UInt
    public let name: String
    public let info: String
    public let thumbnail: Thumbnail
    public let isRecruited: Bool = false

    public init(id: UInt, name: String, info: String, thumbnail: Thumbnail) {
        self.id = id
        self.name = name
        self.info = info
        self.thumbnail = thumbnail
    }

    public static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id        
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Character: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case info = "description"
        case thumbnail
    }
}

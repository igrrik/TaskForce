//
//  Thumbnail.swift
//  
//
//  Created by Igor Kokoev on 07.02.2022.
//

import Foundation

public struct Thumbnail: Equatable {
    public let path: String
    public let fileExtension: String

    public init(path: String, fileExtension: String) {
        self.path = path
        self.fileExtension = fileExtension
    }

    public func urlForVariant(_ variant: Variant) -> URL {
        let urlString = path + variant.stringValue + "." + fileExtension
        guard let url = URL(string: urlString) else {
            fatalError("URL cannot be nil")
        }
        return url
    }
}

extension Thumbnail: Decodable {
    private enum CodingKeys: String, CodingKey {
        case path
        case fileExtension = "extension"
    }
}

public extension Thumbnail {
    enum Variant {
        case portrait(PortraitSize)
        case square(SquareSize)
        case landscape(LandscapeSize)
        case fullSize

        var stringValue: String {
            var string: String = "/"

            switch self {
            case .portrait(let portraitSize):
                return string + "portrait_" + portraitSize.rawValue
            case .square(let squareSize):
                return string + "standard_" + squareSize.rawValue
            case .landscape(let landscapeSize):
                return string + "landscape_" + landscapeSize.rawValue
            case .fullSize:
                string = ""
            }

            return string
        }
    }

    enum PortraitSize: String {
        case small
        case medium
        case xlarge
        case fantastic
        case uncanny
        case incredible
    }

    enum SquareSize: String {
        case small
        case medium
        case large
        case xlarge
        case fantastic
        case amazing
    }

    enum LandscapeSize: String {
        case small
        case medium
        case large
        case xlarge
        case amazing
        case incredible
    }
}

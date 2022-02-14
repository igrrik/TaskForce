//
//  Thumbnail.swift
//  
//
//  Created by Igor Kokoev on 07.02.2022.
//

import Foundation

public struct Thumbnail: Decodable, Equatable {
    let path: String
    let `extension`: String

    public func urlForVariant(_ variant: Variant) -> URL {
        let urlString = path + variant.stringValue + "." + self.extension
        guard let url = URL(string: urlString) else {
            fatalError("URL cannot be nil")
        }
        return url
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

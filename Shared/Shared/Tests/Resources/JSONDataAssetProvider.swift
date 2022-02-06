//
//  JSONDataAssetProvider.swift
//  
//
//  Created by Igor Kokoev on 06.02.2022.
//

import UIKit

final class JSONDataAssetProvider {
    enum JSON: String {
        case obtainCharactersResponse = "ObtainCharactersResponse"
        case obtainCharacterResponse = "ObtainCharacterResponse"
    }

    func obtainAsset(_ assetName: JSON) -> NSDataAsset {
        let responseFileName = assetName.rawValue
        guard let asset = NSDataAsset(name: responseFileName, bundle: .module) else {
            fatalError("Failed to locate json file named: \(responseFileName)")
        }
        return asset
    }
}

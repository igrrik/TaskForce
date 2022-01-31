//
//  CredentialsStore.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import Foundation

final class CredentialsStore: Decodable {
    let privateKey: String
    let publicKey: String
}

extension CredentialsStore {
    static let shared = CredentialsStore.obtainCredsFromPlist()

    private static func obtainCredsFromPlist() -> Self {
        guard let path = Bundle.main.path(forResource: "Credentials", ofType: "plist") else {
            fatalError("Failed to obtain Credentials.plist")
        }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            return try decoder.decode(Self.self, from: data)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

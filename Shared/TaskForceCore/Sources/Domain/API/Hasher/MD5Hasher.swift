//
//  MD5Hasher.swift
//  
//
//  Created by Igor Kokoev on 05.02.2022.
//

import Foundation
import CryptoKit

public final class MD5Hasher: Hasher {
    public init() {}

    public func hash(_ string: String) throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw DataConversionFailure(string: string, encoding: .utf8)
        }
        return Insecure.MD5
            .hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

extension MD5Hasher {
    struct DataConversionFailure: LocalizedError {
        let string: String
        let encoding: String.Encoding

        var errorDescription: String? { "Failed to convert string: \(string) to Data using encoding: \(encoding)" }
    }
}

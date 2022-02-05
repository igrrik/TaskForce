//
//  LiveURLRequestBuilderTests.swift
//  
//
//  Created by Igor Kokoev on 05.02.2022.
//

import XCTest
@testable import Shared

final class LiveURLRequestBuilderTests: XCTestCase {
    private var sut: LiveURLRequestBuilder!
    private var hasher: ((String) -> String)!
    private var randomStringProvider: (() -> String)!
    private let publicKey = "123"
    private let privateKey = "abc"
    private let scheme = "https"
    private let host = "example.com"

    override func setUpWithError() throws {
        try super.setUpWithError()
        hasher = { $0.uppercased() }
        randomStringProvider = { "z42" }
        sut = LiveURLRequestBuilder(
            scheme: scheme,
            host: host,
            privateKey: privateKey,
            publicKey: publicKey,
            hasher: { $0.md5()! },
            randomStringProvider: randomStringProvider
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testThatURLRequestIsNil() {}

    func testThatURLRequestIsCreated() {
        // arrange        
        let expectedString = "https://example.com/v1/public/characters?apikey=123&ts=z42&hash=Z42ABC123&limit=10&offset=350"

        // act
        let urlRequest = sut.makeURLRequest(from: ObtainCharactersRequest(limit: 10, offset: 350))

        // assert
        guard let urlRequest = urlRequest else {
            XCTFail("URLRequest shouldn't be nil")
            return
        }
        XCTAssertEqual(urlRequest.url!.absoluteString, expectedString)
        XCTAssertEqual(urlRequest.httpMethod, HTTPMethod.GET.rawValue)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["Accept": "application/json"])
    }
}

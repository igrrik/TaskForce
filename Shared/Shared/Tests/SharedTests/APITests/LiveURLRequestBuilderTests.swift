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
    private var hasher: StubHasher!
    private var randomStringProvider: (() -> String)!
    private let publicKey = "123"
    private let privateKey = "abc"
    private let scheme = "https"
    private let host = "example.com"

    override func setUpWithError() throws {
        try super.setUpWithError()
        hasher = .init()
        randomStringProvider = { "z42" }
        sut = LiveURLRequestBuilder(
            scheme: scheme,
            host: host,
            privateKey: privateKey,
            publicKey: publicKey,
            hasher: hasher,
            randomStringProvider: randomStringProvider
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testThatURLRequestIsCreated() {
        // arrange
        hasher.hashFunction = { $0.uppercased() }
        let expectedString = "https://example.com/v1/public/characters?apikey=123&ts=z42&hash=Z42ABC123&limit=10&offset=350"

        // act
        let urlRequest = try! sut.makeURLRequest(from: ObtainCharactersRequest(limit: 10, offset: 350))

        // assert
        XCTAssertEqual(urlRequest.url!.absoluteString, expectedString)
        XCTAssertEqual(urlRequest.httpMethod, HTTPMethod.GET.rawValue)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["Accept": "application/json"])
    }

    func testThatURLConstructionFailureIsThrownWhenURLCannotBeObtainedFromComponents() {
        // arrange
        hasher.hashFunction = { $0.uppercased() }

        // act
        do {
            let _ = try sut.makeURLRequest(from: FailingRequest())
            XCTFail("Make URL request should throw error")
        } catch let error as LiveURLRequestBuilder.URLConstructionFailure {
            // assert
            XCTAssertNotNil(error.errorDescription)
        } catch {
            XCTFail("Unexpected error")
        }
    }
}

private final class StubHasher: Hasher {
    var hashFunction: ((String) -> String)!

    func hash(_ string: String) throws -> String {
        hashFunction(string)
    }
}

private struct FailingRequest: APIRequest {
    typealias ResultElement = Character
    typealias Response = APISingleElementResponse<ResultElement>

    let endpoint: APIEndpoint = .init(base: "v1/public", resource: .characters)
    let queryItems: [URLQueryItem] = []
}

//
//  LiveAPIClientTests.swift
//  
//
//  Created by Igor Kokoev on 06.02.2022.
//

import XCTest
import Combine
@testable import TaskForceCore

final class LiveAPIClientTests: XCTestCase {
    private var sut: LiveAPIClient!
    private var urlRequestBuilder: MockURLRequestBuilder!
    private var dataTaskPublisherProducer: StubDataTaskPublisherProducer!
    private var cancellableBag: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellableBag = .init()
        dataTaskPublisherProducer = .init()
        urlRequestBuilder = .init()
        sut = .init(
            urlRequestBuilder: urlRequestBuilder,
            dataTaskPublisherProducer: dataTaskPublisherProducer.publisher(for:),
            decoder: JSONDecoder(),
            delegateQueue: .main
        )
    }

    func testThatAPIMultipleElementsResponseIsParsedCorrectly() {
        // arrange
        urlRequestBuilder.makeURLrequestReturnValue = .success(URLRequest(url: URL(string: "https://example.com")!))
        dataTaskPublisherProducer.publisherResult = .success(.obtainCharactersResponse)
        let expectedCharacters: [Character] = [.adamWarlock, .agathaHarkness]
        var receivedCharacters: [Character] = []

        // act
        let expectation = XCTestExpectation(description: "Obtain characters")
        sut.execute(request: ObtainCharactersRequest(limit: 20, offset: 0))
            .sink { completion in
                guard case let .failure(error) = completion else {
                    return
                }
                XCTFail("Unexpected error: \(error)")
            } receiveValue: { response in
                receivedCharacters = response.results
                expectation.fulfill()
            }
            .store(in: &cancellableBag)
        wait(for: [expectation], timeout: 1.0)

        // assert
        XCTAssertEqual(expectedCharacters, receivedCharacters)
    }

    func testThatAPISingleElementResponseIsParsedCorrectly() {
        // arrange
        urlRequestBuilder.makeURLrequestReturnValue = .success(URLRequest(url: URL(string: "https://example.com")!))
        dataTaskPublisherProducer.publisherResult = .success(.obtainCharacterResponse)
        let expectedCharacter: Character = .adamWarlock
        var receivedCharacter: Character!

        // act
        let expectation = XCTestExpectation(description: "Obtain character")
        sut.execute(request: ObtainCharacterRequest(characterId: expectedCharacter.id))
            .sink { completion in
                guard case let .failure(error) = completion else {
                    return
                }
                XCTFail("Unexpected error: \(error)")
            } receiveValue: { response in
                receivedCharacter = response.result
                expectation.fulfill()
            }
            .store(in: &cancellableBag)
        wait(for: [expectation], timeout: 1.0)

        // assert
        XCTAssertEqual(expectedCharacter, receivedCharacter)
    }

    func testThatErrorIsForwardedFromAPIClient() {
        // arrange
        struct DummyError: Error, Equatable {
            let id = UUID()
        }
        let expectedError = DummyError()
        var receivedError: DummyError!
        urlRequestBuilder.makeURLrequestReturnValue = .failure(expectedError)
        dataTaskPublisherProducer.publisherResult = .success(.obtainCharacterResponse)

        // act
        let expectation = XCTestExpectation(description: "Obtain character")
        sut.execute(request: ObtainCharacterRequest(characterId: 123))
            .sink { completion in
                guard case let .failure(error) = completion else {
                    return
                }
                receivedError = (error as? DummyError)!
                expectation.fulfill()
            } receiveValue: { response in
                XCTFail("Unexpected response: \(response)")
            }
            .store(in: &cancellableBag)
        wait(for: [expectation], timeout: 1.0)

        // assert
        XCTAssertEqual(expectedError, receivedError)
    }
}

private final class MockURLRequestBuilder: URLRequestBuilder {
    var makeURLrequestReturnValue: Result<URLRequest, Error>!

    func makeURLRequest<T: APIRequest>(from request: T) throws -> URLRequest {
        switch makeURLrequestReturnValue {
        case .success(let request):
            return request
        case .failure(let error):
            throw error
        case .none:
            fatalError("Result should be initialized")
        }
    }
}

private final class StubDataTaskPublisherProducer {
    var publisherResult: Result<JSONDataAssetProvider.JSON, Error>!

    private let assetProvider = JSONDataAssetProvider()

    func publisher(for request: URLRequest) -> DataTaskPublisher {
        switch publisherResult {
        case .success(let jsonName):
            let asset = assetProvider.obtainAsset(jsonName)
            let tuple = convert(asset)
            return Just(tuple).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(outputType: (data: Data, response: URLResponse).self, failure: error).eraseToAnyPublisher()
        case .none:
            fatalError("Result should be initialized")
        }
    }

    private func convert(_ asset: NSDataAsset) -> (data: Data, response: URLResponse) {
        let response = URLResponse(
            url: URL(string: "https://example.com")!,
            mimeType: "application/json",
            expectedContentLength: 100,
            textEncodingName: "UTF8"
        )
        return (asset.data, response)
    }
}

extension Character {
    static var adamWarlock: Character {
        .init(
            id: 1010354,
            name: "Adam Warlock",
            info: "Adam Warlock is an artificially created human who was born in a cocoon at a scientific complex called The Beehive.",
            thumbnail: .init(path: "http://i.annihil.us/u/prod/marvel/i/mg/a/f0/5202887448860", fileExtension: "jpg")
        )
    }
    static var agathaHarkness: Character {
        .init(
            id: 1012717,
            name: "Agatha Harkness",
            info: "",
            thumbnail: .init(path: "http://i.annihil.us/u/prod/marvel/i/mg/c/a0/4ce5a9bf70e19", fileExtension: "jpg")
        )
    }
}

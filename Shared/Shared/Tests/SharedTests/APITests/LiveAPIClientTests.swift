//
//  LiveAPIClientTests.swift
//  
//
//  Created by Igor Kokoev on 06.02.2022.
//

import XCTest
import Combine
@testable import Shared

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
        dataTaskPublisherProducer.produceReturnValue = .success(.obtainCharactersResponse)
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
        dataTaskPublisherProducer.produceReturnValue = .success(.obtainCharacterResponse)
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
        dataTaskPublisherProducer.produceReturnValue = .success(.obtainCharacterResponse)

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
    enum Response: String {
        case obtainCharactersResponse = "ObtainCharactersResponse"
        case obtainCharacterResponse = "ObtainCharacterResponse"
    }

    var produceReturnValue: Result<Response, Error>!

    func publisher(for request: URLRequest) -> DataTaskPublisher {
        switch produceReturnValue {
        case .success(let response):
            let tuple = convert(response)
            return Just(tuple).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(outputType: (data: Data, response: URLResponse).self, failure: error).eraseToAnyPublisher()
        case .none:
            fatalError("Result should be initialized")
        }
    }

    private func convert(_ response: Response) -> (data: Data, response: URLResponse) {
        let responseFileName = response.rawValue
        guard let asset = NSDataAsset(name: responseFileName, bundle: .module) else {
            fatalError("Failed to locate json file named: \(responseFileName)")
        }
        let response = URLResponse(
            url: URL(string: "https://example.com")!,
            mimeType: "application/json",
            expectedContentLength: 100,
            textEncodingName: "UTF8"
        )
        return (asset.data, response)
    }
}

private extension Character {
    static let adamWarlock = Character(
        id: 1010354,
        name: "Adam Warlock",
        description: "Adam Warlock is an artificially created human who was born in a cocoon at a scientific complex called The Beehive.",
        thumbnail: .init(path: "http://i.annihil.us/u/prod/marvel/i/mg/a/f0/5202887448860", extension: "jpg")
    )
    static let agathaHarkness = Character(
        id: 1012717,
        name: "Agatha Harkness",
        description: "",
        thumbnail: .init(path: "http://i.annihil.us/u/prod/marvel/i/mg/c/a0/4ce5a9bf70e19", extension: "jpg")
    )
}

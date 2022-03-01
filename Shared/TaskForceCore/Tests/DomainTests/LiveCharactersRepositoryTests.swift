//
//  LiveCharactersRepositoryTests.swift
//  
//
//  Created by Igor Kokoev on 06.02.2022.
//

import XCTest
import Combine
@testable import TaskForceCore

final class LiveCharactersRepositoryTests: XCTestCase {
    private var sut: LiveCharactersRepository!
    private var apiClient: MockAPIClient!
    private var squadManager: MockSquadManager!
    private var cancellableBag: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiClient = .init()
        squadManager = .init()
        cancellableBag = .init()
        sut = LiveCharactersRepository(apiClient: apiClient, squadManager: squadManager)
    }

    func testThatPageableResponseIsReturnedWhenCharactersAreObtained() {
        // arrange
        let givenResponse = APIMultipleElementsResponse<Character>(
            offset: 0,
            limit: 20,
            results: [.adamWarlock, .agathaHarkness]
        )
        apiClient.addResponse(for: ObtainCharactersRequest.self, result: .success(givenResponse))

        let expectedResponse = PageableResponse<Character>(
            results: [.adamWarlock, .agathaHarkness],
            offset: 0,
            limit: 20
        )
        var receivedResponse: PageableResponse<Character>!

        // act
        let expectation = XCTestExpectation(description: "Obtain Characters")
        sut.obtainCharacters(pagingParams: PagingParameters(limit: 0, offset: 20))
            .sink { completion in
                guard case let .failure(error) = completion else {
                    return
                }
                XCTFail("Unexpected error: \(error)")
            } receiveValue: { response in
                receivedResponse = response
                expectation.fulfill()
            }
            .store(in: &cancellableBag)
        wait(for: [expectation], timeout: 1.0)

        // assert
        XCTAssertEqual(expectedResponse, receivedResponse)
    }

    func testThatCharactersRecruitmentStatusIsModifiedDuringObtainment() {
        // arrange
        let givenResponse = APIMultipleElementsResponse<Character>(
            offset: 0,
            limit: 20,
            results: [.adamWarlock, .agathaHarkness]
        )
        apiClient.addResponse(for: ObtainCharactersRequest.self, result: .success(givenResponse))

        squadManager.squadSubject.send([.adamWarlock])

        let expectedRecruitmentStatuses = [true, false]
        var receivedCharacters = [Character]()

        // act
        let expectation = XCTestExpectation(description: "Obtain Characters")
        sut.obtainCharacters(pagingParams: PagingParameters(limit: 0, offset: 20))
            .map(\.results)
            .sink { completion in
                guard case let .failure(error) = completion else {
                    return
                }
                XCTFail("Unexpected error: \(error)")
            } receiveValue: { response in
                receivedCharacters = response
                expectation.fulfill()
            }
            .store(in: &cancellableBag)
        wait(for: [expectation], timeout: 1.0)

        // assert
        XCTAssertEqual(receivedCharacters.map(\.isRecruited), expectedRecruitmentStatuses)
    }

    func testThatSingleCharacterIsReturnedWhenCharacterIsObtained() {
        // arrange
        let givenResponse = APISingleElementResponse<Character>(results: [.adamWarlock])
        apiClient.addResponse(for: ObtainCharacterRequest.self, result: .success(givenResponse))

        let expectedResponse = Character.adamWarlock
        var receivedResponse: Character!

        // act
        let expectation = XCTestExpectation(description: "Obtain Character")
        sut.obtainCharacter(with: 123)
            .sink { completion in
                guard case let .failure(error) = completion else {
                    return
                }
                XCTFail("Unexpected error: \(error)")
            } receiveValue: { response in
                receivedResponse = response
                expectation.fulfill()
            }
            .store(in: &cancellableBag)
        wait(for: [expectation], timeout: 1.0)

        // assert
        XCTAssertEqual(expectedResponse, receivedResponse)
    }

    func testThatObserveSquadMembersPublishesUpdates() {
        // arrange
        var receivedSquads: [Squad] = []
        let expectedSquads: [Squad] = [
            [],
            [.adamWarlock],
            [.adamWarlock, .agathaHarkness],
            [.agathaHarkness]
        ]
        var receivedError: Error?

        sut.observeSquadMembers()
            .prefix(expectedSquads.count)
            .sink(
                receiveCompletion: { completion in
                    guard case let .failure(error) = completion else {
                        return
                    }
                    receivedError = error
                },
                receiveValue: { receivedSquads.append($0) }
            )
            .store(in: &cancellableBag)

        // act
        squadManager.squadSubject.send([.adamWarlock])
        squadManager.squadSubject.send([.adamWarlock, .agathaHarkness])
        squadManager.squadSubject.send([.agathaHarkness])

        // assert
        XCTAssertNil(receivedError)
        XCTAssertEqual(receivedSquads, expectedSquads)
    }
}

private final class MockSquadManager: SquadManager {
    let squadSubject: CurrentValueSubject<Squad, Error>

    init(squad: Squad = []) {
        squadSubject = .init(squad)
    }

    func observeSquadMembers() -> AnyPublisher<Squad, Error> {
        squadSubject.eraseToAnyPublisher()
    }

    func recruit(_ character: Character) {
        var squad = squadSubject.value
        squad.insert(character)
        squadSubject.send(squad)
    }

    func fire(_ character: Character) {
        var squad = squadSubject.value
        squad.remove(character)
        squadSubject.send(squad)
    }
}

private final class MockAPIClient: APIClient {
    private var result: Result<Any, Error>!

    func addResponse<T: APIRequest>(for request: T.Type, result: Result<T.Response, Error>) {
        self.result = result.map { $0 as Any }
    }

    func execute<T: APIRequest>(request: T) -> AnyPublisher<T.Response, Error> {
        switch result {
        case .success(let response):
            guard let apiResponse = response as? T.Response else {
                fatalError("Result type doesn't match response type")
            }
            return Just(apiResponse).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(outputType: T.Response.self, failure: error).eraseToAnyPublisher()
        case .none:
            fatalError("Result should be initialized")
        }
    }
}

private extension APIResponse {
    convenience init(offset: UInt = 0, limit: UInt = 0, results: [ResultElement]) {
        let data = Data(offset: offset, limit: limit, total: 0, count: UInt(results.count), results: results)
        self.init(code: 0, status: "status", data: data)
    }
}

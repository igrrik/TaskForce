//
//  PersistentSquadManagerTests.swift
//  
//
//  Created by Igor Kokoev on 20.02.2022.
//

import XCTest
import Combine
@testable import TaskForceCore

final class PersistentSquadManagerTests: XCTestCase {
    private var sut: PersistentSquadManager!
    private var persistenceController: MockPersistenceController!
    private var cancellableBag: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellableBag = .init()
        persistenceController = .init()
        sut = .init(persistenceController: persistenceController)
    }

//    func testThatObserveSquadMembersObtainsPersistedDataOnlyOnce() {
//        // arrange
//        let expectedSquads: [Squad] = [[], [.adamWarlock], [.adamWarlock, .agathaHarkness]]
//        var receivedSquads: [Squad] = []
//
//        // act
//        let connectable = sut.observeSquadMembers()
//
//        // assert
//        XCTAssertEqual(receivedSquads, expectedSquads)
//        XCTAssertEqual(persistenceController.obtainItemsCallsCount, 1)
//    }

    func testThatRecruitCharacterUpdatesSquadMembersAndSavesInPersistenceController() {
        // arrange
        let givenCharacter: Character = .adamWarlock
        let expectedSquadMembers: Set<Character> = [.adamWarlock]
        var receivedSquadMembers: Set<Character> = []
        var receivedError: Error?

        persistenceController.obtainItemsReturnValue = Just([Character]())
            .setFailureType(to: Error.self)
            .map { $0 as Any }
            .eraseToAnyPublisher()

        persistenceController.saveItemReturnValue = Empty(
            completeImmediately: true,
            outputType: Never.self,
            failureType: Error.self
        ).eraseToAnyPublisher()

        // act
        sut.observeSquadMembers()
            .prefix(2)
            .sink(
                receiveCompletion: { completion in
                    guard case let .failure(error) = completion else {
                        return
                    }
                    receivedError = error
                },
                receiveValue: { receivedSquadMembers = $0 }
            )
            .store(in: &cancellableBag)
        sut.recruit(givenCharacter)

        // assert
        XCTAssertNil(receivedError)
        XCTAssertTrue(givenCharacter.isRecruited)
        XCTAssertEqual(persistenceController.obtainItemsCallsCount, 1)
        XCTAssertEqual(persistenceController.saveItemCallsCount, 1)
        XCTAssertEqual(persistenceController.saveItemCallsArguments.first! as! Character, givenCharacter)
        XCTAssertEqual(receivedSquadMembers, expectedSquadMembers)
    }

    func testThatRecruitCharacterDoesNotCauseSideEffectWhenCharacterIsAlreadyRecruited() {
        // arrange
        let givenCharacter: Character = .adamWarlock
        givenCharacter.isRecruited = true
        var receivedSquadMembers: Set<Character> = []
        var receivedError: Error?

        persistenceController.obtainItemsReturnValue = Just([Character]())
            .setFailureType(to: Error.self)
            .map { $0 as Any }
            .eraseToAnyPublisher()

        // act
        sut.observeSquadMembers()
            .sink(
                receiveCompletion: { completion in
                    guard case let .failure(error) = completion else {
                        return
                    }
                    receivedError = error
                },
                receiveValue: { receivedSquadMembers = $0 }
            )
            .store(in: &cancellableBag)
        sut.recruit(givenCharacter)

        // assert
        XCTAssertNil(receivedError)
        XCTAssertEqual(persistenceController.obtainItemsCallsCount, 1)
        XCTAssertEqual(persistenceController.saveItemCallsCount, 0)
        XCTAssertTrue(receivedSquadMembers.isEmpty)
    }

    func testThatFiringCharacterUpdatesSquadMembersAndRemovesFromPersistenceController() {
        // arrange
        let givenCharacter: Character = .adamWarlock
        givenCharacter.isRecruited = true
        let expectedSquadMembers: Set<Character> = [.agathaHarkness]
        var receivedSquadMembers: Set<Character> = []
        var receivedError: Error?

        persistenceController.obtainItemsReturnValue = Just([Character.adamWarlock, .agathaHarkness])
            .setFailureType(to: Error.self)
            .map { $0 as Any }
            .eraseToAnyPublisher()

        persistenceController.deleteItemReturnValue = Empty(
            completeImmediately: true,
            outputType: Never.self,
            failureType: Error.self
        ).eraseToAnyPublisher()

        // act
        sut.observeSquadMembers()
            .sink(
                receiveCompletion: { completion in
                    guard case let .failure(error) = completion else {
                        return
                    }
                    receivedError = error
                },
                receiveValue: { receivedSquadMembers = $0 }
            )
            .store(in: &cancellableBag)
        sut.fire(givenCharacter)

        // assert
        XCTAssertNil(receivedError)
        XCTAssertFalse(givenCharacter.isRecruited)
        XCTAssertEqual(persistenceController.obtainItemsCallsCount, 1)
        XCTAssertEqual(persistenceController.deleteItemCallsCount, 1)
        XCTAssertEqual(persistenceController.deleteItemCallsArguments.first! as! Character, givenCharacter)
        XCTAssertEqual(receivedSquadMembers, expectedSquadMembers)
    }

    func testThatFiringCharacterDoesNotCauseSideEffectWhenCharacterIsNotRecruited() {
        // arrange
        let givenCharacter: Character = .adamWarlock
        var receivedSquadMembers: Set<Character> = []
        var receivedError: Error?

        persistenceController.obtainItemsReturnValue = Just([Character]())
            .setFailureType(to: Error.self)
            .map { $0 as Any }
            .eraseToAnyPublisher()

        // act
        sut.observeSquadMembers()
            .sink(
                receiveCompletion: { completion in
                    guard case let .failure(error) = completion else {
                        return
                    }
                    receivedError = error
                },
                receiveValue: { receivedSquadMembers = $0 }
            )
            .store(in: &cancellableBag)
        sut.fire(givenCharacter)

        // assert
        XCTAssertNil(receivedError)
        XCTAssertEqual(persistenceController.obtainItemsCallsCount, 1)
        XCTAssertEqual(persistenceController.saveItemCallsCount, 0)
        XCTAssertTrue(receivedSquadMembers.isEmpty)
    }
}

private final class MockPersistenceController: PersistenceController {
    var obtainItemsCallsCount: Int = 0
    var obtainItemsCallsArguments: [Any] = []
    var obtainItemsReturnValue: AnyPublisher<Any, Error>!

    func obtainItems<T: Persistable>(ofType: T.Type) -> AnyPublisher<[T], Error> {
        obtainItemsCallsCount += 1
        obtainItemsCallsArguments.append(ofType)
        return obtainItemsReturnValue.map { $0 as! [T] }.eraseToAnyPublisher()
    }

    var saveItemCallsCount: Int = 0
    var saveItemCallsArguments: [Any] = []
    var saveItemReturnValue: AnyPublisher<Never, Error>!

    func save<T: Persistable>(_ item: T) -> AnyPublisher<Never, Error> {
        saveItemCallsCount += 1
        saveItemCallsArguments.append(item)
        return saveItemReturnValue
    }

    var deleteItemCallsCount: Int = 0
    var deleteItemCallsArguments: [Any] = []
    var deleteItemReturnValue: AnyPublisher<Never, Error>!

    func delete<T: Persistable>(_ item: T) -> AnyPublisher<Never, Error> {
        deleteItemCallsCount += 1
        deleteItemCallsArguments.append(item)
        return deleteItemReturnValue
    }
}

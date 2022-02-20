//
//  CoreDataPersistenceControllerTests.swift
//  
//
//  Created by Igor Kokoev on 20.02.2022.
//

import XCTest
import CoreData
import Combine
@testable import TaskForceCore

final class CoreDataPersistenceControllerTests: XCTestCase {
    private var sut: CoreDataPersistenceController!
    private var context: MockManagedObjectContext!
    private var persistentContainer: MockPersistentContainer!
    private var cancellableBag: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellableBag = .init()
        context = .init()
        persistentContainer = .init(context: context)
        sut = .init(container: persistentContainer, delegateQueue: .main)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
        persistentContainer = nil
        cancellableBag = nil
    }

    func testThatObtainItemsReturnsPersistedObjects() {
        // arrange
        let expectedObjects = ["John", "Karen"].map(DummyPersistable.init(name:))
        var receivedObjects: [DummyPersistable] = []
        var receivedError: Error?

        let givenPersitableObjects = expectedObjects.map(\.name).map(DummyPersistableObject.init(name:))
        context.obtainReturnValue = .success(givenPersitableObjects)

        // act
        let expectation = XCTestExpectation(description: "Obtain items")
        sut.obtainItems(ofType: DummyPersistable.self)
            .sink(
                receiveCompletion: { completion in
                    guard case let .failure(error) = completion else {
                        return
                    }
                    receivedError = error
                },
                receiveValue: { objects in
                    receivedObjects = objects
                    expectation.fulfill()
                }
            )
            .store(in: &cancellableBag)
        wait(for: [expectation], timeout: 120.0)

        // assert
        XCTAssertNil(receivedError)
        XCTAssertEqual(receivedObjects, expectedObjects)
        XCTAssertEqual(context.obtainCallsCount, 1)
    }

    func testThatErrorIsThrownWhenContextFailsObtainment() {
        // arrange
        var receivedObjects: [Any]?
        var receivedError: Error!

        context.obtainReturnValue = .failure(DummyError())

        // act
        let expectation = XCTestExpectation(description: "Obtain Error")
        sut.obtainItems(ofType: DummyPersistable.self)
            .sink(
                receiveCompletion: { completion in
                    guard case let .failure(error) = completion else {
                        return
                    }
                    receivedError = error
                    expectation.fulfill()
                },
                receiveValue: { objects in
                    receivedObjects = objects
                }
            )
            .store(in: &cancellableBag)
        wait(for: [expectation], timeout: 1.0)

        // assert
        XCTAssertNotNil(receivedError as? DummyError)
        XCTAssertNil(receivedObjects)
        XCTAssertEqual(context.obtainCallsCount, 1)
    }

    func testThatErrorIsThrownWhenCannotMakePersistableObject() {
        // arrange
        var receivedError: Error!

        // act
        let expectation = XCTestExpectation(description: "Obtain Error")
        sut.save(DummyPersistable(name: "John"))
            .sink(
                receiveCompletion: { completion in
                    guard case let .failure(error) = completion else {
                        return
                    }
                    receivedError = error
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellableBag)
        wait(for: [expectation], timeout: 1.0)

        // assert
        XCTAssertEqual(context.saveCallsCount, 0)
        let failure = receivedError as! CoreDataPersistenceController.Failure
        switch failure {
        case .failedToFindObjectWithPredicate:
            XCTFail()
        case .failedToObtainEntityName:
            XCTFail()
        case .failedToCreatePersistableObject:
            return
        }
    }
}

private struct DummyError: Error {}

private final class DummyPersistableObject: NSObject, NSFetchRequestResult {
    let name: String

    init(name: String) {
        self.name = name
    }
}

private struct DummyPersistable: Persistable, Equatable {
    typealias PersistableObject = DummyPersistableObject

    let name: String

    init(name: String) {
        self.name = name
    }

    init?(object: DummyPersistableObject) {
        self.name = object.name
    }

    func makePersistableObject(in context: ManagedObjectContext) -> DummyPersistableObject? {
        .init(name: name)
    }

    func identifyingPredicate() -> NSPredicate {
        NSPredicate(format: "name == %@", name)
    }

    static func fetchRequest() throws -> NSFetchRequest<DummyPersistableObject> {
        NSFetchRequest(entityName: "Dummy")
    }
}

private final class MockManagedObjectContext: ManagedObjectContext {
    var hasChanges: Bool = true

    var obtainCallsCount: Int = 0
    var obtainCallsArguments: [Any] = []
    var obtainReturnValue: Result<Any, Error>!

    func obtain<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T] {
        obtainCallsCount += 1
        obtainCallsArguments.append(request)
        switch obtainReturnValue {
        case .success(let result):
            return result as! [T]
        case .failure(let error):
            throw error
        case .none:
            fatalError("obtainReturnValue should be initalized")
        }
    }

    var deleteCallsCount: Int = 0
    var deleteCallsArguments: [(object: Any, ofPersistableType: Any)] = []
    var deleteError: Error?

    func delete<T: Persistable>(object: T.PersistableObject, ofPersistableType: T.Type) throws {
        deleteCallsCount += 1
        deleteCallsArguments.append((object, ofPersistableType))
        guard let deleteError = deleteError else {
            return
        }
        throw deleteError
    }

    var saveCallsCount: Int = 0
    var saveError: Error?

    func save() throws {
        saveCallsCount += 1

        guard let saveError = saveError else {
            return
        }
        throw saveError
    }
}

private final class MockPersistentContainer: PersistentContainer {
    let context: MockManagedObjectContext

    init(context: MockManagedObjectContext) {
        self.context = context
    }

    func performBackgroundTask(_ block: @escaping (ManagedObjectContext) -> Void) {
        block(context)
    }
}

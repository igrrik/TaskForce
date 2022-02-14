//
//  TaskForce_UIKitUITests.swift
//  TaskForce-UIKitUITests
//
//  Created by Igor Kokoev on 01.02.2022.
//

import XCTest

final class TaskForce_UIKitUITests: XCTestCase {
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

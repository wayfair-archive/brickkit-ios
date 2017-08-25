//
//  BrickLoggerTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 8/23/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class TestLogger: BrickLoggable {
    var didPrintWarning: Bool = false
    var didPrintVerbose: Bool = false
    var didPrintError: Bool = false

    public func logError(_ message: @escaping @autoclosure() -> String, file: String, lineNumber: Int, function: String) {
        didPrintError = true
    }

    public func logVerbose(_ message: @escaping @autoclosure() -> String, file: String, lineNumber: Int, function: String) {
        didPrintVerbose = true
    }

    public func logWarning(_ message: @escaping @autoclosure() -> String, file: String, lineNumber: Int, function: String) {
        didPrintWarning = true
    }

}

class BrickLoggerTests: XCTestCase {
    var testLogger: TestLogger!

    override func setUp() {
        super.setUp()

        testLogger = TestLogger()
        BrickLogger.logger = testLogger
    }

    override func tearDown() {
        super.tearDown()

        BrickLogger.logger = nil
    }

    func testThatErrorGetsLogged() {
        BrickLogger.logError("Some error")
        XCTAssertTrue(testLogger.didPrintError)
    }

    func testThatWarningGetsLogged() {
        BrickLogger.logWarning("Some warning")
        XCTAssertTrue(testLogger.didPrintWarning)
    }

    func testThatVerboseGetsLogged() {
        BrickLogger.logVerbose("Some verbose")
        XCTAssertTrue(testLogger.didPrintVerbose)
    }
    
}

/// This test was added just to make sure that the console logger didn't break
class BrickConsoleLoggerTests: XCTestCase {
    var testLogger: BrickConsoleLogger!
    var receivedMessage: String?

    override func setUp() {
        super.setUp()

        testLogger = BrickConsoleLogger(logVerbose: true, loggingFunction: { (message) in
            self.receivedMessage = message
        })
        BrickLogger.logger = testLogger
    }

    override func tearDown() {
        super.tearDown()

        BrickLogger.logger = nil
    }

    func testThatErrorGetsLogged() {
        BrickLogger.logError("Some error")
        XCTAssertNotNil(receivedMessage)
    }

    func testThatWarningGetsLogged() {
        BrickLogger.logWarning("Some warning")
        XCTAssertNotNil(receivedMessage)
    }

    func testThatVerboseGetsLogged() {
        BrickLogger.logVerbose("Some verbose")
        XCTAssertNotNil(receivedMessage)
    }

    func testThatMessageDoesntGetLoggedWhenLogVerboseIsFalse() {
        testLogger = BrickConsoleLogger(logVerbose: false, loggingFunction: { (message) in
            self.receivedMessage = message
        })
        BrickLogger.logger = testLogger

        BrickLogger.logVerbose("Some verbose")
        XCTAssertNil(receivedMessage)
    }

}

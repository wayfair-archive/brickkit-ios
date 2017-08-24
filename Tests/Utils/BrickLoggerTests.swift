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

    public func logError(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int) {
        didPrintError = true
    }

    public func logVerbose(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int) {
        didPrintVerbose = true
    }

    public func logWarning(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int) {
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
        BrickLogger.logError(message: "Some error")
        XCTAssertTrue(testLogger.didPrintError)
    }

    func testThatWarningGetsLogged() {
        BrickLogger.logWarning(message: "Some warning")
        XCTAssertTrue(testLogger.didPrintWarning)
    }

    func testThatVerboseGetsLogged() {
        BrickLogger.logVerbose(message: "Some verbose")
        XCTAssertTrue(testLogger.didPrintVerbose)
    }

}

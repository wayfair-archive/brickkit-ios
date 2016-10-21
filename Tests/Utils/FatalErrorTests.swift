//
//  FatalErrorTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

private struct FatalErrorHolder {
    static var expectation: XCTestExpectation?
    static var assertionMessage: String?
}

@noreturn func testFatalError(message: String = "", file: StaticString = #file, line: UInt = #line) {
    FatalErrorHolder.assertionMessage = message
    FatalErrorHolder.expectation?.fulfill()
    unreachable()
}

// This is a `noreturn` function that pauses forever
@noreturn func unreachable() {
    repeat {
        NSRunLoop.currentRunLoop().run()
    } while (true)
}

extension XCTestCase {

    func expectFatalError(expectedMessage: String? = nil, testcase: () -> Void) {

        // For right now, we are skipping the expectFatalError tests because Travis can't handle this
        return;

        FatalErrorHolder.expectation = expectationWithDescription("expectingFatalError")
        FatalErrorUtil.replaceFatalError(testFatalError)

        // act, perform on separate thead because a call to fatalError pauses forever
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), testcase)

        waitForExpectationsWithTimeout(25) { _ in
            defer {
                FatalErrorHolder.expectation = nil
                FatalErrorHolder.assertionMessage = nil
            }

            if let message = expectedMessage {
                 // assert
                 XCTAssertEqual(FatalErrorHolder.assertionMessage, message)
            }

            // clean up
            FatalErrorUtil.restoreFatalError()
        }

    }
}

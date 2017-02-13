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

//func testFatalError(_ message: String = "", file: StaticString = #file, line: UInt = #line) {
//    FatalErrorHolder.assertionMessage = message
//    FatalErrorHolder.expectation?.fulfill()
//}

extension XCTestCase {

    func expectFatalError(_ expectedMessage: String? = nil, testcase: @escaping () -> Void) {

        // For right now, we are skipping the expectFatalError tests because Travis can't handle this
        return

//        FatalErrorHolder.expectation = expectation(description: "expectingFatalError")
//        FatalErrorUtil.replaceFatalError(testFatalError)

        // act, perform on separate thead because a call to fatalError pauses forever
//        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: testcase)
//
//        waitForExpectations(timeout: 25) { _ in
//            defer {
//                FatalErrorHolder.expectation = nil
//                FatalErrorHolder.assertionMessage = nil
//            }
//
//            if let message = expectedMessage {
//                 // assert
//                 XCTAssertEqual(FatalErrorHolder.assertionMessage, message)
//            }
//
//            // clean up
//            FatalErrorUtil.restoreFatalError()
//        }

    }
}

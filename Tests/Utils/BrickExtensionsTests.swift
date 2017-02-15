//
//  BrickExtensionsTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickExtensionsTests: XCTestCase {

    func testAllKeysForValue() {
        let dict = ["a" : 1, "b" : 2, "c" : 1, "d" : 2]
        let keys = dict.allKeysForValue(1)
        XCTAssertEqual(keys.sorted { $0 < $1 }, ["a", "c"])
    }

    func testAllKeysForValueNotFound() {
        let dict = ["a" : 1, "b" : 2, "c" : 1, "d" : 2]
        let keys = dict.allKeysForValue(5)
        XCTAssertEqual(keys, [])
    }

}

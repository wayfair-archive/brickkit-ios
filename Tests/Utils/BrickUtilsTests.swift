//
//  BrickUtilsTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/30/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickUtilsTests: XCTestCase {

    // MARK: calculateWidth
    func testCalculateWidth() {
        XCTAssertEqual(BrickUtils.calculateWidth(for: 1, widthRatio: 1, totalWidth: 100, inset:0), 100)
        XCTAssertEqual(BrickUtils.calculateWidth(for: 0.5, widthRatio: 1, totalWidth: 100, inset:0), 50)
        XCTAssertEqual(BrickUtils.calculateWidth(for: 1.5, widthRatio: 1, totalWidth: 100, inset:0), 150)
    }

    func testCalculateWidthInsets() {
        XCTAssertEqual(BrickUtils.calculateWidth(for: 1, widthRatio: 1, totalWidth: 100, inset:10), 100)
        XCTAssertEqual(BrickUtils.calculateWidth(for: 0.5, widthRatio: 1, totalWidth: 100, inset: 10), 45)
        XCTAssertEqual(BrickUtils.calculateWidth(for: 1/3, widthRatio: 1, totalWidth: 100, inset: 5), 30)
    }

    func testCalculateWidthWidthRatio() {
        XCTAssertEqual(BrickUtils.calculateWidth(for: 240, widthRatio: 240, totalWidth: 100, inset: 0), 100)
        XCTAssertEqual(BrickUtils.calculateWidth(for: 120, widthRatio: 240, totalWidth: 100, inset: 0), 50)
        XCTAssertEqual(BrickUtils.calculateWidth(for: 360, widthRatio: 240, totalWidth: 100, inset: 0), 150)
    }

}

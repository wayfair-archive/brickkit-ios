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

    // MARK: findRowMaxY
    
    let frames: [CGRect] = [
        CGRect(x: 0, y: 0, width: 200, height: 50),
        CGRect(x: 200, y: 0, width: 200, height: 100),
        CGRect(x: 0, y: 100, width: 200, height: 100),
        CGRect(x: 200, y: 100, width: 200, height: 50),
        CGRect(x: 400, y: 100, width: 200, height: 150),
        ]

    func testMaxXIfFirst() {
        XCTAssertEqual(BrickUtils.findRowMaxY(for: 0, in: frames), 0)
    }

    func testMaxXFindStartIndex() {
        XCTAssertEqual(BrickUtils.findRowMaxY(for: 1, in: frames), 50)
    }

    func testMaxXIfNotGoingOutOfIndex() {
        XCTAssertEqual(BrickUtils.findRowMaxY(for: 2, in: frames), 100)
    }

    func testMaxXOutOfBounds() {
        XCTAssertNil(BrickUtils.findRowMaxY(for: 10, in: frames))
    }

    func testMaxXLinearRows() {
        XCTAssertEqual(BrickUtils.findRowMaxY(for: 4, in: frames), 200)
    }

}

//
//  AlignRowHeightsLayoutBehaviorTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 7/12/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class AlignRowHeightTests: BrickFlowLayoutBaseTests {

    func testAlignRowHeightsSingleRow() {

        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(width: .Ratio(ratio: 1/2), height: .Fixed(size: 100)),
            DummyBrick(width: .Ratio(ratio: 1/2), height: .Fixed(size: 200))
            ], alignRowHeights: true)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 160, height: 200))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 160, y: 0, width: 160, height: 200))
    }

    func testAlignRowHeightsSingleRowFirstRowHighest() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(width: .Ratio(ratio: 1/2), height: .Fixed(size: 200)),
            DummyBrick(width: .Ratio(ratio: 1/2), height: .Fixed(size: 100))
            ], alignRowHeights: true)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 160, height: 200))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 160, y: 0, width: 160, height: 200))
    }

    func testAlignRowHeightsMultipleRows() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(width: .Ratio(ratio: 1/2), height: .Fixed(size: 100)),
            DummyBrick(width: .Ratio(ratio: 1/2), height: .Fixed(size: 200)),
            DummyBrick(width: .Ratio(ratio: 1/4), height: .Fixed(size: 100)),
            DummyBrick(width: .Ratio(ratio: 1/4), height: .Fixed(size: 200)),
            DummyBrick(width: .Ratio(ratio: 1/4), height: .Fixed(size: 100)),
            DummyBrick(width: .Ratio(ratio: 1/4), height: .Fixed(size: 150)),
            DummyBrick(width: .Ratio(ratio: 1/4), height: .Fixed(size: 100)),
            DummyBrick(width: .Ratio(ratio: 1/4), height: .Fixed(size: 200)),
            ], alignRowHeights: true)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 160, height: 200))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 160, y: 0, width: 160, height: 200))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 0, y: 200, width: 80, height: 200))
        let cell4 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 3, inSection: 1))
        XCTAssertEqual(cell4?.frame, CGRect(x: 80, y: 200, width: 80, height: 200))
        let cell5 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 4, inSection: 1))
        XCTAssertEqual(cell5?.frame, CGRect(x: 160, y: 200, width: 80, height: 200))
        let cell6 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 5, inSection: 1))
        XCTAssertEqual(cell6?.frame, CGRect(x: 240, y: 200, width: 80, height: 200))
        let cell7 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 6, inSection: 1))
        XCTAssertEqual(cell7?.frame, CGRect(x: 0, y: 400, width: 80, height: 200))
        let cell8 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 7, inSection: 1))
        XCTAssertEqual(cell8?.frame, CGRect(x: 80, y: 400, width: 80, height: 200))
    }

}

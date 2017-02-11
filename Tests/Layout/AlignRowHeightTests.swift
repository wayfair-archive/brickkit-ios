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
            DummyBrick(width: .ratio(ratio: 1/2), height: .fixed(size: 100)),
            DummyBrick(width: .ratio(ratio: 1/2), height: .fixed(size: 200))
            ], alignRowHeights: true)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 160, height: 200))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 160, y: 0, width: 160, height: 200))
    }

    func testAlignRowHeightsSingleRowFirstRowHighest() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(width: .ratio(ratio: 1/2), height: .fixed(size: 200)),
            DummyBrick(width: .ratio(ratio: 1/2), height: .fixed(size: 100))
            ], alignRowHeights: true)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 160, height: 200))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 160, y: 0, width: 160, height: 200))
    }

    func testAlignRowHeightsMultipleRows() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(width: .ratio(ratio: 1/2), height: .fixed(size: 100)),
            DummyBrick(width: .ratio(ratio: 1/2), height: .fixed(size: 200)),
            DummyBrick(width: .ratio(ratio: 1/4), height: .fixed(size: 100)),
            DummyBrick(width: .ratio(ratio: 1/4), height: .fixed(size: 200)),
            DummyBrick(width: .ratio(ratio: 1/4), height: .fixed(size: 100)),
            DummyBrick(width: .ratio(ratio: 1/4), height: .fixed(size: 150)),
            DummyBrick(width: .ratio(ratio: 1/4), height: .fixed(size: 100)),
            DummyBrick(width: .ratio(ratio: 1/4), height: .fixed(size: 200)),
            ], alignRowHeights: true)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 160, height: 200))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 160, y: 0, width: 160, height: 200))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 0, y: 200, width: 80, height: 200))
        let cell4 = collectionView.cellForItem(at: IndexPath(item: 3, section: 1))
        XCTAssertEqual(cell4?.frame, CGRect(x: 80, y: 200, width: 80, height: 200))
        let cell5 = collectionView.cellForItem(at: IndexPath(item: 4, section: 1))
        XCTAssertEqual(cell5?.frame, CGRect(x: 160, y: 200, width: 80, height: 200))
        let cell6 = collectionView.cellForItem(at: IndexPath(item: 5, section: 1))
        XCTAssertEqual(cell6?.frame, CGRect(x: 240, y: 200, width: 80, height: 200))
        let cell7 = collectionView.cellForItem(at: IndexPath(item: 6, section: 1))
        XCTAssertEqual(cell7?.frame, CGRect(x: 0, y: 400, width: 80, height: 200))
        let cell8 = collectionView.cellForItem(at: IndexPath(item: 7, section: 1))
        XCTAssertEqual(cell8?.frame, CGRect(x: 80, y: 400, width: 80, height: 200))
    }

}

//
//  BrickSection+OrderDataSource.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 7/6/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickSectionOrderDataSourceTests: XCTestCase {

    var brickCollectionView: BrickCollectionView!
    var section: BrickSection!
    var orderDataSource: BrickSectionOrderDataSource!

    override func setUp() {
        super.setUp()

        brickCollectionView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))

        let brick1 = DummyBrick("Brick1", height: .fixed(size: 50))
        let brick2 = DummyBrick("Brick2", height: .fixed(size: 50))

        brick1.repeatCount = 5
        brick2.repeatCount = 5

        section = BrickSection(bricks: [
            brick1, brick2
            ])
    }

    fileprivate var indexesForBrick1: [Int] {
        return indexesForBrick(withIdentifier: "Brick1")
    }

    fileprivate var indexesForBrick2: [Int] {
        return indexesForBrick(withIdentifier: "Brick2")
    }

    fileprivate func indexesForBrick(withIdentifier identifier: String) -> [Int] {
        return brickCollectionView.indexPathsForBricksWithIdentifier(identifier).map({$0.item}).sorted(by: <)
    }

}

// Mark: - Staggered

class BrickSectionStaggeredOrderDataSourceTests: BrickSectionOrderDataSourceTests {

    override func setUp() {
        super.setUp()

        orderDataSource = MockStaggeredBrickSectionOrderDataSource()
        section.orderDataSource = orderDataSource
        brickCollectionView.setupSectionAndLayout(section)
    }

    func testThatIndex0ReturnsBrick0Index0() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 0)
    }

    func testThatIndex1ReturnsBrick1Index0() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 1, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 0)
    }

    func testThatIndex2ReturnsBrick0Index1() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 2, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 1)
    }

    func testThatIndex3ReturnsBrick1Index1() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 3, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 1)
    }

    func testThatIndex4ReturnsBrick0Index2() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 4, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 2)
    }

    func testThatIndex5ReturnsBrick1Index2() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 5, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 2)
    }

    func testThatIndex6ReturnsBrick0Index3() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 6, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 3)
    }

    func testThatIndex7ReturnsBrick1Index3() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 7, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 3)
    }

    func testThatIndex8ReturnsBrick0Index4() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 8, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 4)
    }

    func testThatIndex9ReturnsBrick1Index4() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 9, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 4)
    }

    func testThatReturningBrick1IndexesAreOrdered() {
        XCTAssertEqual(indexesForBrick1, [0, 2, 4, 6, 8])
    }

    func testThatReturningBrick2IndexesAreOrdered() {
        XCTAssertEqual(indexesForBrick2, [1, 3, 5, 7, 9])
    }

}

class MockStaggeredBrickSectionOrderDataSource: BrickSectionOrderDataSource {

    func brickAndIndex(atIndex brickIndex: Int, section: BrickSection) -> (Brick, Int)? {
        let actualIndex = brickIndex / 2
        if brickIndex % 2 == 0 {
            return (section.bricks[0], actualIndex)
        } else {
            return (section.bricks[1], actualIndex)
        }
    }

}

// Mark: - Advanced

class BrickSectionAdvancedOrderDataSourceTests: BrickSectionOrderDataSourceTests {

    override func setUp() {
        super.setUp()

        orderDataSource = MockAdvancedBrickSectionOrderDataSource()
        section.orderDataSource = orderDataSource
        brickCollectionView.setupSectionAndLayout(section)
    }

    func testThatIndex0ReturnsBrick0Index0() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 0)
    }

    func testThatIndex1ReturnsBrick0Index1() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 1, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 1)
    }

    func testThatIndex2ReturnsBrick0Index2() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 2, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 2)
    }

    func testThatIndex3ReturnsBrick1Index0() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 3, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 0)
    }

    func testThatIndex4ReturnsBrick1Index1() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 4, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 1)
    }

    func testThatIndex5ReturnsBrick0Index3() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 5, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 3)
    }

    func testThatIndex6ReturnsBrick1Index2() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 6, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 2)
    }

    func testThatIndex7ReturnsBrick1Index3() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 7, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 3)
    }

    func testThatIndex8ReturnsBrick0Index4() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 8, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 4)
    }

    func testThatIndex9ReturnsBrick1Index4() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 9, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 4)
    }

    func testThatReturningBrick1IndexesAreOrdered() {
        XCTAssertEqual(indexesForBrick1, [0, 1, 2, 5, 8])
    }

    func testThatReturningBrick2IndexesAreOrdered() {
        XCTAssertEqual(indexesForBrick2, [3, 4, 6, 7, 9])
    }

}

class MockAdvancedBrickSectionOrderDataSource: BrickSectionOrderDataSource {

    let advancedRepeat: [[Int]] = [
        [0, 1, 2, 5, 8],
        [3, 4, 6, 7, 9]
    ]

    func brickAndIndex(atIndex brickIndex: Int, section: BrickSection) -> (Brick, Int)? {
        let actualIndex: Int
        let brick: Brick
        if advancedRepeat[0].contains(brickIndex) {
            actualIndex = advancedRepeat[0].index(of: brickIndex)!
            brick = section.bricks[0]
        } else {
            actualIndex = advancedRepeat[1].index(of: brickIndex)!
            brick = section.bricks[1]
        }
        return (brick, actualIndex)
    }

}

// Mark: - nil

class BrickSectionNilOrderDataSourceTests: BrickSectionOrderDataSourceTests {

    override func setUp() {
        super.setUp()

        orderDataSource = MockNilBrickSectionOrderDataSource()
        section.orderDataSource = orderDataSource
        brickCollectionView.setupSectionAndLayout(section)
    }

    func testThatIndex0ReturnsBrick0Index0() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 0)
    }

    func testThatIndex1ReturnsBrick0Index1() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 1, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 1)
    }

    func testThatIndex2ReturnsBrick0Index2() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 2, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 2)
    }

    func testThatIndex3ReturnsBrick0Index3() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 3, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 3)
    }

    func testThatIndex4ReturnsBrick0Index4() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 4, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[0])
        XCTAssertEqual(cell?.index, 4)
    }

    func testThatIndex5ReturnsBrick1Index0() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 5, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 0)
    }

    func testThatIndex6ReturnsBrick1Index1() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 6, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 1)
    }

    func testThatIndex7ReturnsBrick1Index2() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 7, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 2)
    }

    func testThatIndex8ReturnsBrick1Index3() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 8, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 3)
    }

    func testThatIndex9ReturnsBrick1Index4() {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 9, section: 1)) as? BrickCell
        XCTAssertTrue(cell?._brick === section.bricks[1])
        XCTAssertEqual(cell?.index, 4)
    }

    func testThatReturningBrick1IndexesAreOrdered() {
        XCTAssertEqual(indexesForBrick1, [0, 1, 2, 3, 4])
    }

    func testThatReturningBrick2IndexesAreOrdered() {
        XCTAssertEqual(indexesForBrick2, [5, 6, 7, 8, 9])
    }

}

class MockNilBrickSectionOrderDataSource: BrickSectionOrderDataSource {

    func brickAndIndex(atIndex brickIndex: Int, section: BrickSection) -> (Brick, Int)? {
        return nil
    }

}

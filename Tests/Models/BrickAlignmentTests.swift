//
//  BrickAlignmentTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 12/4/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
import BrickKit

class BrickAlignmentTests: BrickFlowLayoutBaseTests {
}

// MARK: - Left Align
extension BrickAlignmentTests {

    func testThatLeftAlignDoesnChangeDefaultBehavior() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(height: .Fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignment: .Left)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }
    
    func testThatLeftAlignIgnoresHiddenBricks() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 1)])
        collectionView.layout.hideBehaviorDataSource = hideBehaviorDataSource
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(height: .Fixed(size: 50)),
            DummyBrick(height: .Fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignRowHeights: true, alignment: .Left)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertNil(cell1)
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }
    
    func testThatLeftAlignmentBricks() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            ], alignment: .Left)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 50, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 100, y: 0, width: 50, height: 50))

    }

    func testThatLeftAlignmentBricksWithInsets() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: .Left)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 65, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 120, y: 0, width: 50, height: 50))
        
    }

    func testThatLeftAlignmentBricksWithInsetsAndSection() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            BrickSection(width: .Fixed(size: 50), bricks: [
                DummyBrick(height: .Fixed(size: 50))
                ]),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: .Left)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 0, width: 50, height: 50))
        let cell12 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(cell12?.frame, CGRect(x: 10, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 65, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 120, y: 0, width: 50, height: 50))
        
    }
}

// MARK: - Right Align
extension BrickAlignmentTests {

    func testThatRightAlignDoesnChangeDefaultBehavior() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(height: .Fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignment: .Right)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }

    func testThatRightAlignmentBricks() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            ], alignment: .Right)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 170, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 220, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 270, y: 0, width: 50, height: 50))
        
    }

    func testThatRightAlignmentBricksWithInsets() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: .Right)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 150, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 205, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 260, y: 0, width: 50, height: 50))
        
    }

    func testThatRightAlignmentBricksWithInsetsAndSection() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            BrickSection(width: .Fixed(size: 50), bricks: [
                DummyBrick(height: .Fixed(size: 50))
                ]),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: .Right)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 150, y: 0, width: 50, height: 50))
        let cell12 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(cell12?.frame, CGRect(x: 150, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 205, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 260, y: 0, width: 50, height: 50))
        
    }

    func testThatRightAlignmentNestedBricksWithInsetsAndSection() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
                DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
                DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
                ], alignment: .Right),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(cell1?.frame, CGRect(x: 160, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 2))
        XCTAssertEqual(cell2?.frame, CGRect(x: 210, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 2))
        XCTAssertEqual(cell3?.frame, CGRect(x: 260, y: 0, width: 50, height: 50))
        
    }

    func testThatRightAlignmentNestedBricksWithInsetsAndSectionInset() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                DummyBrick(width: .Fixed(size: 85), height: .Fixed(size: 50)),
                DummyBrick(width: .Fixed(size: 85), height: .Fixed(size: 50)),
                DummyBrick(width: .Fixed(size: 85), height: .Fixed(size: 50))
                ], inset: 10, alignment: .Right)
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(cell1?.frame, CGRect(x: 25, y: 20, width: 85, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 2))
        XCTAssertEqual(cell2?.frame, CGRect(x: 120, y: 20, width: 85, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 2))
        XCTAssertEqual(cell3?.frame, CGRect(x: 215, y: 20, width: 85, height: 50))
    }
}

// MARK: - Center Align
extension BrickAlignmentTests {

    func testThatCenterAlignDoesnChangeDefaultBehavior() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(height: .Fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignment: .Center)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }

    func testThatCenterAlignmentBricks() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            ], alignment: .Center)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 85, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 135, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 185, y: 0, width: 50, height: 50))

    }

    func testThatCenterAlignmentBricksWithInsets() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: .Center)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 80, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 135, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 190, y: 0, width: 50, height: 50))
        
    }

    func testThatCenterAlignmentBricksWithInsetsAndSection() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            BrickSection(width: .Fixed(size: 50), bricks: [
                DummyBrick(height: .Fixed(size: 50))
                ]),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: .Center)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 80, y: 0, width: 50, height: 50))
        let cell12 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(cell12?.frame, CGRect(x: 80, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 135, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 190, y: 0, width: 50, height: 50))
        
    }

    func testThatAddingABrickAlignsProperly() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick("BRICK", width: .Ratio(ratio: 1/3), height: .Fixed(size: 50)),
            ], edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), alignment: .Center)
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["BRICK": 2])
        section.repeatCountDataSource = repeatCountDataSource
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        repeatCountDataSource.repeatCountHash = ["BRICK": 3]
        let expectation = expectationWithDescription("Invalidat Bricks")

        collectionView.invalidateRepeatCounts(reloadAllSections: false) { (completed, insertedIndexPaths, deletedIndexPaths) in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 100, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 110, y: 10, width: 100, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 210, y: 10, width: 100, height: 50))

    }
}

// MARK: - Justified Align
extension BrickAlignmentTests {

    func testThatJustifiedAlignDoesnChangeDefaultBehavior() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(height: .Fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignment: .Justified)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }

    func testThatJustifiedAlignmentBricks() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            ], alignment: .Justified)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 135, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 270, y: 0, width: 50, height: 50))

    }

    func testThatJustifiedAlignmentBricksWithInsets() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: .Justified)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 135, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 260, y: 0, width: 50, height: 50))
    }

    func testThatJustifiedAlignmentBricksWithInsetsAndSection() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            BrickSection(width: .Fixed(size: 50), bricks: [
                DummyBrick(height: .Fixed(size: 50))
                ]),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            DummyBrick(width: .Fixed(size: 50), height: .Fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: .Justified)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let cell1 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 0, width: 50, height: 50))
        let cell12 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(cell12?.frame, CGRect(x: 10, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 135, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 260, y: 0, width: 50, height: 50))
    }
}

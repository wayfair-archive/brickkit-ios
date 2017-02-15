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
        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignment: BrickAlignment(horizontal: .left, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }
    
    func testThatLeftAlignIgnoresHiddenBricks() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 1)])
        collectionView.layout.hideBehaviorDataSource = hideBehaviorDataSource

        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
            DummyBrick(height: .fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignRowHeights: true, alignment: BrickAlignment(horizontal: .left, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertNil(cell1)
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }
    
    func testThatLeftAlignmentBricks() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            ], alignment: BrickAlignment(horizontal: .left, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 50, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 100, y: 0, width: 50, height: 50))

    }

    func testThatLeftAlignmentBricksWithInsets() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: BrickAlignment(horizontal: .left, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 65, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 120, y: 0, width: 50, height: 50))
        
    }

    func testThatLeftAlignmentBricksWithInsetsAndSection() {
        let section = BrickSection(bricks: [
            BrickSection(width: .fixed(size: 50), bricks: [
                DummyBrick(height: .fixed(size: 50))
                ]),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: BrickAlignment(horizontal: .left, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 0, width: 50, height: 50))
        let cell12 = collectionView.cellForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(cell12?.frame, CGRect(x: 10, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 65, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 120, y: 0, width: 50, height: 50))
        
    }
}

// MARK: - Right Align
extension BrickAlignmentTests {

    func testThatRightAlignDoesnChangeDefaultBehavior() {
        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignment: BrickAlignment(horizontal: .right, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }

    func testThatRightAlignmentBricks() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            ], alignment: BrickAlignment(horizontal: .right, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 170, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 220, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 270, y: 0, width: 50, height: 50))
        
    }

    func testThatRightAlignmentBricksWithInsets() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: BrickAlignment(horizontal: .right, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 150, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 205, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 260, y: 0, width: 50, height: 50))
        
    }

    func testThatRightAlignmentBricksWithInsetsAndSection() {
        let section = BrickSection(bricks: [
            BrickSection(width: .fixed(size: 50), bricks: [
                DummyBrick(height: .fixed(size: 50))
                ]),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: BrickAlignment(horizontal: .right, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 150, y: 0, width: 50, height: 50))
        let cell12 = collectionView.cellForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(cell12?.frame, CGRect(x: 150, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 205, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 260, y: 0, width: 50, height: 50))
        
    }

    func testThatRightAlignmentNestedBricksWithInsetsAndSection() {
        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
                DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
                DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
                ], alignment: BrickAlignment(horizontal: .right, vertical: .top)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(cell1?.frame, CGRect(x: 160, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 2))
        XCTAssertEqual(cell2?.frame, CGRect(x: 210, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 2))
        XCTAssertEqual(cell3?.frame, CGRect(x: 260, y: 0, width: 50, height: 50))
        
    }

    func testThatRightAlignmentNestedBricksWithInsetsAndSectionInset() {
        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                DummyBrick(width: .fixed(size: 85), height: .fixed(size: 50)),
                DummyBrick(width: .fixed(size: 85), height: .fixed(size: 50)),
                DummyBrick(width: .fixed(size: 85), height: .fixed(size: 50))
                ], inset: 10, alignment: BrickAlignment(horizontal: .right, vertical: .top))
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(cell1?.frame, CGRect(x: 25, y: 20, width: 85, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 2))
        XCTAssertEqual(cell2?.frame, CGRect(x: 120, y: 20, width: 85, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 2))
        XCTAssertEqual(cell3?.frame, CGRect(x: 215, y: 20, width: 85, height: 50))
    }
}

// MARK: - Center Align
extension BrickAlignmentTests {

    func testThatCenterAlignDoesnChangeDefaultBehavior() {
        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignment: BrickAlignment(horizontal: .center, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }

    func testThatCenterAlignmentBricks() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            ], alignment: BrickAlignment(horizontal: .center, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 85, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 135, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 185, y: 0, width: 50, height: 50))

    }

    func testThatCenterAlignmentBricksWithInsets() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: BrickAlignment(horizontal: .center, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 80, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 135, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 190, y: 0, width: 50, height: 50))
        
    }

    func testThatCenterAlignmentBricksWithInsetsAndSection() {
        let section = BrickSection(bricks: [
            BrickSection(width: .fixed(size: 50), bricks: [
                DummyBrick(height: .fixed(size: 50))
                ]),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: BrickAlignment(horizontal: .center, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 80, y: 0, width: 50, height: 50))
        let cell12 = collectionView.cellForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(cell12?.frame, CGRect(x: 80, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 135, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 190, y: 0, width: 50, height: 50))
        
    }

    func testThatAddingABrickAlignsProperly() {
        let section = BrickSection(bricks: [
            DummyBrick("BRICK", width: .ratio(ratio: 1/3), height: .fixed(size: 50)),
            ], edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), alignment: BrickAlignment(horizontal: .center, vertical: .top))
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["BRICK": 2])
        section.repeatCountDataSource = repeatCountDataSource
        collectionView.setupSectionAndLayout(section)

        repeatCountDataSource.repeatCountHash = ["BRICK": 3]
        let expectation = self.expectation(description: "Invalidat Bricks")

        collectionView.invalidateRepeatCounts(reloadAllSections: false) { (completed, insertedIndexPaths, deletedIndexPaths) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 100, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 110, y: 10, width: 100, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 210, y: 10, width: 100, height: 50))

    }
}

// MARK: - Justified Align
extension BrickAlignmentTests {

    func testThatJustifiedAlignDoesnChangeDefaultBehavior() {
        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignment: BrickAlignment(horizontal: .justified, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }

    func testThatJustifiedAlignmentBricks() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            ], alignment: BrickAlignment(horizontal: .justified, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 135, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 270, y: 0, width: 50, height: 50))

    }

    func testThatJustifiedAlignmentBricksWithInsets() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: BrickAlignment(horizontal: .justified, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 135, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 260, y: 0, width: 50, height: 50))
    }

    func testThatJustifiedAlignmentBricksWithInsetsAndSection() {
        let section = BrickSection(bricks: [
            BrickSection(width: .fixed(size: 50), bricks: [
                DummyBrick(height: .fixed(size: 50))
                ]),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), alignment: BrickAlignment(horizontal: .justified, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 0, width: 50, height: 50))
        let cell12 = collectionView.cellForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(cell12?.frame, CGRect(x: 10, y: 0, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 135, y: 0, width: 50, height: 50))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 260, y: 0, width: 50, height: 50))
    }
}

// MARK: - Top Align
extension BrickAlignmentTests {

    func testThatTopAlignDoesnChangeDefaultBehavior() {
        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignment: BrickAlignment(horizontal: .left, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }

    func testThatTopAlignIgnoresHiddenBricks() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 1)])
        collectionView.layout.hideBehaviorDataSource = hideBehaviorDataSource

        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
            DummyBrick(height: .fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignRowHeights: true, alignment: BrickAlignment(horizontal: .left, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertNil(cell1)
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }

    func testThatTopAlignmentBricks() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .ratio(ratio: 0.5), height: .fixed(size: 50)),
            DummyBrick(width: .ratio(ratio: 0.5), height: .fixed(size: 10)),
            ], alignment: BrickAlignment(horizontal: .left, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 160, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 160, y: 0, width: 160, height: 10))
    }

    func testThatTopAlignmentBricksWithInsets() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 30)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 20)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), alignment: BrickAlignment(horizontal: .left, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 65, y: 10, width: 50, height: 30))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 120, y: 10, width: 50, height: 20))

    }

    func testThatTopAlignmentBricksWithInsetsAndSection() {
        let section = BrickSection(bricks: [
            BrickSection(width: .fixed(size: 50), bricks: [
                DummyBrick(height: .fixed(size: 50))
                ]),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 30)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 20)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), alignment: BrickAlignment(horizontal: .left, vertical: .top))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 50, height: 50))
        let cell12 = collectionView.cellForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(cell12?.frame, CGRect(x: 10, y: 10, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 65, y: 10, width: 50, height: 30))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 120, y: 10, width: 50, height: 20))
        
    }

}

// MARK: - Center Align
extension BrickAlignmentTests {

    func testThatVerticalCenterAlignDoesnChangeDefaultBehavior() {
        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignment: BrickAlignment(horizontal: .left, vertical: .center))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }

    func testThatVerticalCenterAlignIgnoresHiddenBricks() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 1)])
        collectionView.layout.hideBehaviorDataSource = hideBehaviorDataSource

        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
            DummyBrick(height: .fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignRowHeights: true, alignment: BrickAlignment(horizontal: .left, vertical: .center))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertNil(cell1)
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }

    func testThatVerticalCenterAlignmentBricks() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .ratio(ratio: 0.5), height: .fixed(size: 50)),
            DummyBrick(width: .ratio(ratio: 0.5), height: .fixed(size: 10)),
            ], alignment: BrickAlignment(horizontal: .left, vertical: .center))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 160, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 160, y: 20, width: 160, height: 10))
    }

    func testThatVerticalCenterAlignmentBricksWithInsets() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 30)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 20)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), alignment: BrickAlignment(horizontal: .left, vertical: .center))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 65, y: 20, width: 50, height: 30))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 120, y: 25, width: 50, height: 20))

    }

    func testThatVerticalCenterAlignmentBricksWithInsetsAndSection() {
        let section = BrickSection(bricks: [
            BrickSection(width: .fixed(size: 50), bricks: [
                DummyBrick(height: .fixed(size: 50))
                ]),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 30)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 20)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), alignment: BrickAlignment(horizontal: .left, vertical: .center))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 50, height: 50))
        let cell12 = collectionView.cellForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(cell12?.frame, CGRect(x: 10, y: 10, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 65, y: 20, width: 50, height: 30))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 120, y: 25, width: 50, height: 20))
        
    }
}

// MARK: - Bottom Align
extension BrickAlignmentTests {

    func testThatBottomAlignDoesnChangeDefaultBehavior() {
        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignment: BrickAlignment(horizontal: .left, vertical: .bottom))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }

    func testThatBottomAlignIgnoresHiddenBricks() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 1)])
        collectionView.layout.hideBehaviorDataSource = hideBehaviorDataSource

        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
            DummyBrick(height: .fixed(size: 50)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), alignRowHeights: true, alignment: BrickAlignment(horizontal: .left, vertical: .bottom))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertNil(cell1)
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 5, y: 5, width: 310, height: 50))
    }

    func testThatBottomAlignmentBricks() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .ratio(ratio: 0.5), height: .fixed(size: 50)),
            DummyBrick(width: .ratio(ratio: 0.5), height: .fixed(size: 10)),
            ], alignment: BrickAlignment(horizontal: .left, vertical: .bottom))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 160, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 160, y: 40, width: 160, height: 10))
    }

    func testThatBottomAlignmentBricksWithInsets() {
        let section = BrickSection(bricks: [
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 50)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 30)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 20)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), alignment: BrickAlignment(horizontal: .left, vertical: .bottom))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 65, y: 30, width: 50, height: 30))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 120, y: 40, width: 50, height: 20))

    }

    func testThatBottomAlignmentBricksWithInsetsAndSection() {
        let section = BrickSection(bricks: [
            BrickSection(width: .fixed(size: 50), bricks: [
                DummyBrick(height: .fixed(size: 50))
                ]),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 30)),
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 20)),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), alignment: BrickAlignment(horizontal: .left, vertical: .bottom))
        collectionView.setupSectionAndLayout(section)

        let cell1 = collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 50, height: 50))
        let cell12 = collectionView.cellForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(cell12?.frame, CGRect(x: 10, y: 10, width: 50, height: 50))
        let cell2 = collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 65, y: 30, width: 50, height: 30))
        let cell3 = collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 120, y: 40, width: 50, height: 20))
        
    }
}

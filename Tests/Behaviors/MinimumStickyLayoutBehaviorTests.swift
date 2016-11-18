//
//  MinimumStickyLayoutBehaviorTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/3/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class MinimumStickyLayoutBehaviorTests: BrickFlowLayoutBaseTests {

    func testMinimumStickyBehavior() {
        let fixedStickyWithMinimumLayoutBehavior = FixedStickyWithMinimumLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0)], minStickingHeight: 50)
        let stickyBehavior = MinimumStickyLayoutBehavior(dataSource: fixedStickyWithMinimumLayoutBehavior)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        let expectedResult: [Int : [CGRect]] = [
            0 : frames
        ]

        let attributes = layout.layoutAttributesForElementsInRect(CGRect(origin: CGPoint.zero, size: layout.collectionViewContentSize()))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 2000))

        var firstAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 25
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 25, width: 320, height: 75))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 50))
    }

    func testMinimumStickyBehaviorWithMultipleInDataSource() {
        let fixedStickyWithMinimumLayoutBehavior = FixedStickyWithMinimumLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0), NSIndexPath(forItem: 1, inSection: 0)], minStickingHeights:[NSIndexPath(forItem: 0, inSection: 0): 50])
        let stickyBehavior = MinimumStickyLayoutBehavior(dataSource: fixedStickyWithMinimumLayoutBehavior)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        let expectedResult: [Int : [CGRect]] = [
            0 : frames
        ]

        let attributes = layout.layoutAttributesForElementsInRect(CGRect(origin: CGPoint.zero, size: layout.collectionViewContentSize()))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 2000))

        var firstAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 25
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 25, width: 320, height: 75))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 50))
    }

    func testMinimumStickyBehaviorWhenScrolled() {
        let fixedStickyWithMinimumLayoutBehavior = FixedStickyWithMinimumLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0)], minStickingHeight: 50)
        let stickyBehavior = MinimumStickyLayoutBehavior(dataSource: fixedStickyWithMinimumLayoutBehavior)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        var firstAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 50))
    }

    func testMinimumStickyBehaviorWithBaseDataSource() {
        let fixedStickyWithMinimumLayoutBehavior = FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])
        let stickyBehavior = MinimumStickyLayoutBehavior(dataSource: fixedStickyWithMinimumLayoutBehavior)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        let expectedResult: [Int : [CGRect]] = [
            0 : frames
        ]

        let attributes = layout.layoutAttributesForElementsInRect(CGRect(origin: CGPoint.zero, size: layout.collectionViewContentSize()))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 2000))

        var firstAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 25
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 25, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 100))
        
    }
    


}

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
        let fixedStickyWithMinimumLayoutBehavior = FixedStickyWithMinimumLayoutBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 0)], minStickingHeight: 50)
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

        let attributes = layout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: layout.collectionViewContentSize))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 2000))

        var firstAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 25
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 25, width: 320, height: 75))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 50))
    }

    func testMinimumStickyBehaviorWithMultipleInDataSource() {
        let fixedStickyWithMinimumLayoutBehavior = FixedStickyWithMinimumLayoutBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 0), IndexPath(item: 1, section: 0)], minStickingHeights:[IndexPath(item: 0, section: 0): 50])
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

        let attributes = layout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: layout.collectionViewContentSize))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 2000))

        var firstAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 25
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 25, width: 320, height: 75))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 50))
    }

    func testMinimumStickyBehaviorWhenScrolled() {
        let fixedStickyWithMinimumLayoutBehavior = FixedStickyWithMinimumLayoutBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 0)], minStickingHeight: 50)
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
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 50))
    }

    func testMinimumStickyBehaviorWithBaseDataSource() {
        let fixedStickyWithMinimumLayoutBehavior = FixedStickyLayoutBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 0)])
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

        let attributes = layout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: layout.collectionViewContentSize))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 2000))

        var firstAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 25
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 25, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 100))
        XCTAssertTrue(stickyBehavior.hasInvalidatableAttributes())
        
    }
    
    func testNoInvalitableAttributes() {
        let fixedStickyWithMinimumLayoutBehavior = FixedStickyLayoutBehaviorDataSource(indexPaths: [IndexPath(item: 20, section: 0)]) // IndexPath is just out of section count.
        let stickyBehavior = MinimumStickyLayoutBehavior(dataSource: fixedStickyWithMinimumLayoutBehavior)
        self.layout.behaviors.insert(stickyBehavior)
        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))
        layout.collectionView?.contentOffset.y = 25
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))
        XCTAssertFalse(stickyBehavior.hasInvalidatableAttributes())
    }

}

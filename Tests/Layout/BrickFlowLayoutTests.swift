//
//  BrickFlowLayoutTests.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/20/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickFlowLayoutTests: BrickFlowLayoutBaseTests {


    func testCreateLayoutWithNoSections() {
        setDataSources(SectionsCollectionViewDataSource(sections: []), brickLayoutDataSource: FixedBrickLayoutDataSource())

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertEqual(attributes?.count, 0)
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 0, height: 0))
    }

    func testCreateLayoutWithOneRow() {
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))
        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))

        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 100))

        let firstAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))
    }

    func testCreateLayoutWithTwoBricksNextToEachother() {
        setDataSources(SectionsCollectionViewDataSource(sections: [2, 1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 0.5, height: 100))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 160, height: 100),
                CGRect(x: 160, y: 0, width: 160, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))

        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 100))
    }
    
    func testCreateLayoutWithTwoBricksWithOneZeroHeight() {
        setDataSources(SectionsCollectionViewDataSource(sections: [2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1]], heights: [[100, 0]], types: [[.brick, .brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))

        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 100))
    }
    

    func testCreateLayoutWithTwoBricksNextToEachotherWithDifferentHeights() {
        setDataSources(SectionsCollectionViewDataSource(sections: [2, 1]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[0.5, 0.5]], heights: [[100, 200]], types: [[.brick, .brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 160, height: 100),
                CGRect(x: 160, y: 0, width: 160, height: 200)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))

        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 200))
    }
    
//    func testCreateLayoutWithTwoBricksNextToEachotherWithDifferentHeightsWithAlignRowHeights() {
//        self.layout.behaviors.insert(AlignRowHeightsLayoutBehavior())
//        setDataSources(SectionsCollectionViewDataSource(sections: [4]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[0.5, 0.5, 0.5, 0.5]], heights: [[100, 200, 150, 50]], types: [[.Brick, .Brick, .Brick, .Brick]]))
//
//        let expectedResult = [
//            0 : [
//                CGRect(x: 0, y: 0, width: 160, height: 200),
//                CGRect(x: 160, y: 0, width: 160, height: 200),
//                CGRect(x: 0, y: 200, width: 160, height: 150),
//                CGRect(x: 160, y: 200, width: 160, height: 150)
//            ]
//        ]
//
//        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
//        XCTAssertNotNil(attributes)
//        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
//
//        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 350))
//    }

    func testCreateLayoutWithTwoBricksNextToEachotherWithInset() {
        setDataSources(SectionsCollectionViewDataSource(sections: [2, 1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 0.5, height: 100, inset: 20))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 150, height: 100),
                CGRect(x: 170, y: 0, width: 150, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))

        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 100))
    }

    func testCreateLayoutWithTwoBricksNextToEachotherAndOneBelow() {
        setDataSources(SectionsCollectionViewDataSource(sections: [3]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[0.5, 0.5, 1]], heights: [[100, 100, 100]], types: [[.brick, .brick, .brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 160, height: 100),
                CGRect(x: 160, y: 0, width: 160, height: 100),
                CGRect(x: 0, y: 100, width: 320, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))

        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 200))
    }
    
    
    func testCreateLayoutWithTwoBricksNextToEachotherAndOneBelowWithInset() {
        setDataSources(SectionsCollectionViewDataSource(sections: [3]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[0.5, 0.5, 1]], heights: [[100, 100, 100]], insets: [10], types: [[.brick, .brick, .brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 155, height: 100),
                CGRect(x: 165, y: 0, width: 155, height: 100),
                CGRect(x: 0, y: 110, width: 320, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))

        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 210))
    }

    func testCalculateSectionsIfNeededWithoutDataSource() {
        let brickFlowLayout = BrickFlowLayout()
        expectFatalError { 
            _ = brickFlowLayout.calculateSectionsIfNeeded(self.hugeFrame)
        }
    }

    func testCalculateSectionsWithoutCollectionView() {
        let brickFlowLayout = BrickFlowLayout()
        expectFatalError {
            brickFlowLayout.calculateSections()
        }
    }

    func testCalculateSectionWithoutCollectionView() {
        let brickFlowLayout = BrickFlowLayout()
        expectFatalError {
            brickFlowLayout.calculateSection(for: 5, with: nil, containedInWidth: 320, at: CGPoint.zero)
        }
    }

    func testUpdateHeightWithoutDataSource() {
        let brickFlowLayout = BrickFlowLayout()
        expectFatalError {
            brickFlowLayout.updateHeight(IndexPath(item: 0, section: 0), newHeight: 320)
        }
    }

    func testShouldInvalidateLayoutForPreferredLayoutAttributesWithUICollectionViewLayoutAttributes() {
        let brickFlowLayout = BrickFlowLayout()
        let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
        XCTAssertFalse(brickFlowLayout.shouldInvalidateLayout(forPreferredLayoutAttributes: attributes, withOriginalAttributes: attributes))
    }

    func testDelegate() {
        let brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))

        let delegate = FixedDelegate()
        brickView.layout.delegate = delegate

        let section = BrickSection(bricks: [
            DummyBrick()
            ])
        brickView.setupSectionAndLayout(section)

        XCTAssertTrue(delegate.didUpdateCalled)
        XCTAssertEqual(delegate.updatedIndexPaths, [IndexPath(item: 0, section: 1)])
    }

    func testPrecision() {
        let brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
        let section = BrickSection(bricks: [
            DummyBrick("Dummy", width: .ratio(ratio: 1/5), height: .fixed(size: 50))
            ], inset: 8, edgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        let repeatCount = FixedRepeatCountDataSource(repeatCountHash: ["Dummy": 5])
        section.repeatCountDataSource = repeatCount
        brickView.setupSectionAndLayout(section)

        let cell = brickView.cellForItem(at: IndexPath(item: 4, section: 1))
        XCTAssertEqual(cell?.frame, CGRect(x: 820.8, y: 8, width: 195.2, height: 50), accuracy: CGRect(x: 0.1, y: 0.1, width: 0.1, height: 0.1))
    }

}

class FixedDelegate: BrickLayoutDelegate {
    var didUpdateCalled: Bool = false
    var updatedIndexPaths: Set<IndexPath> = []
    var didUpdateHandler: (() -> Void)? = nil
    
    func brickLayout(_ layout: BrickLayout, didUpdateHeightForItemAtIndexPath indexPath: IndexPath) {
        didUpdateCalled = true
        updatedIndexPaths.insert(indexPath)
        didUpdateHandler?()
        didUpdateHandler = nil
    }

}

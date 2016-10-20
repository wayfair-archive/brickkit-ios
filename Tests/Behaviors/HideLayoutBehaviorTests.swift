//
//  HideBehaviorTests.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class HideLayoutBehaviorTests: BrickFlowLayoutBaseTests {

    func testHideOneRowBehavior() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 1, inSection: 0)])
        self.layout.hideBehaviorDataSource = hideBehaviorDataSource

        setDataSources(SectionsCollectionViewDataSource(sections: [2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1]], heights: [[100, 100]], types: [[.Brick, .Brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 100))

        let indexPaths = attributes?.map { return $0.indexPath }
        XCTAssertEqual(indexPaths?.count, 1)
        XCTAssertEqual(indexPaths?.first, NSIndexPath(forItem: 0, inSection: 0))
    }

    func testHideAllRowsBehavior() {
        let hideBehavior = FixedHideBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0), NSIndexPath(forItem: 1, inSection: 0)])
        self.layout.hideBehaviorDataSource = hideBehavior

        setDataSources(SectionsCollectionViewDataSource(sections: [2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1]], heights: [[100, 100]], edgeInsets: [UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)], types: [[.Brick, .Brick]]))

        let expectedResult: [Int: [CGRect]] = [:]

        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 0))
    }


    func testHideOneSectionBehavior() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 1, inSection: 0)])
        self.layout.hideBehaviorDataSource = hideBehaviorDataSource

        setDataSources(SectionsCollectionViewDataSource(sections: [2,1]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1], [1]], heights: [[100, 100], [100]], types: [[.Brick, .Section(sectionIndex: 1)], [.Brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
            ]
        ]

        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 100))

    }

    func testHideMultiSections() {
        let brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Section 1", bricks: [
            BrickSection("Section 2", bricks: [
                BrickSection("Section 3", bricks: [DummyBrick(height: .Fixed(size: 50))]),
                BrickSection("Section 4", bricks: [DummyBrick(height: .Fixed(size: 50))]),
                BrickSection("Section 5", bricks: [DummyBrick(height: .Fixed(size: 50))])
                ])
            ])
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 1)])
        brickView.layout.hideBehaviorDataSource = hideBehaviorDataSource

        brickView.setSection(section)
        brickView.layoutSubviews()

        XCTAssertEqual(brickView.visibleCells().count, 0)
    }

}

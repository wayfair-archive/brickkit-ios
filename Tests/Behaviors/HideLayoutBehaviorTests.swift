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
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [IndexPath(item: 1, section: 0)])
        self.layout.hideBehaviorDataSource = hideBehaviorDataSource

        setDataSources(SectionsCollectionViewDataSource(sections: [2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1]], heights: [[100, 100]], types: [[.brick, .brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 100))

        let indexPaths = attributes?.map { return $0.indexPath }
        XCTAssertEqual(indexPaths?.count, 1)
        XCTAssertEqual(indexPaths?.first, IndexPath(item: 0, section: 0))
    }

    func testHideAllRowsBehavior() {
        let hideBehavior = FixedHideBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 0), IndexPath(item: 1, section: 0)])
        self.layout.hideBehaviorDataSource = hideBehavior

        setDataSources(SectionsCollectionViewDataSource(sections: [2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1]], heights: [[100, 100]], edgeInsets: [UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)], types: [[.brick, .brick]]))

        let expectedResult: [Int: [CGRect]] = [:]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 0))
    }


    func testHideOneSectionBehavior() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [IndexPath(item: 1, section: 0)])
        self.layout.hideBehaviorDataSource = hideBehaviorDataSource

        setDataSources(SectionsCollectionViewDataSource(sections: [2,1]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1], [1]], heights: [[100, 100], [100]], types: [[.brick, .section(sectionIndex: 1)], [.brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 100))

    }

    func testHideMultiSections() {
        let brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Section 1", bricks: [
            BrickSection("Section 2", bricks: [
                BrickSection("Section 3", bricks: [DummyBrick(height: .fixed(size: 50))]),
                BrickSection("Section 4", bricks: [DummyBrick(height: .fixed(size: 50))]),
                BrickSection("Section 5", bricks: [DummyBrick(height: .fixed(size: 50))])
                ])
            ])
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 1)])
        brickView.layout.hideBehaviorDataSource = hideBehaviorDataSource

        brickView.setSection(section)
        brickView.layoutSubviews()

        XCTAssertEqual(brickView.visibleCells.count, 0)
    }

}

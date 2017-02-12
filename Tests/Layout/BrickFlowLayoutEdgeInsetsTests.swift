//
//  BrickFlowLayoutEdgeInsetsTests.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/23/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest

class BrickFlowLayoutEdgeInsetsTests: BrickFlowLayoutBaseTests {

    func testCreateLayoutWithOneRow() {
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)))
        let expectedResult = [
            0 : [
                CGRect(x: 20, y: 20, width: 280, height: 100),
            ]
        ]

        layout.prepare()

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))

        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 140))
    }

    func testCreateLayoutWithTwoBricksNextToEachother() {
        setDataSources(SectionsCollectionViewDataSource(sections: [2]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 0.5, height: 100, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)))

        let expectedResult = [
            0 : [
                CGRect(x: 20, y: 20, width: 140, height: 100),
                CGRect(x: 160, y: 20, width: 140, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))

        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 140))
    }

    func testCreateLayoutWithTwoBricksNextToEachotherAndOneBelow() {
        setDataSources(SectionsCollectionViewDataSource(sections: [3]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[0.5, 0.5, 1]], heights: [[100, 100, 100]], edgeInsets: [UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)], types: [[.brick, .brick, .brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 20, y: 20, width: 140, height: 100),
                CGRect(x: 160, y: 20, width: 140, height: 100),
                CGRect(x: 20, y: 120, width: 280, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))

        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 240))
    }

}

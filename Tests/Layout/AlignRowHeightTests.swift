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
        collectionView.layout.alignRowHeights = true

        let half = CGFloat(1.0/2.0)
        setDataSources(SectionsCollectionViewDataSource(sections: [2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[half, half]], heights: [[100, 200]], types: [[.Brick, .Brick]]))


        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 160, height: 200),
                CGRect(x: 160, y: 0, width: 160, height: 200),
            ]
        ]

        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
    }

    func testAlignRowHeightsSingleRowFirstRowHighest() {
        collectionView.layout.alignRowHeights = true

        let half = CGFloat(1.0/2.0)
        setDataSources(SectionsCollectionViewDataSource(sections: [2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[half, half]], heights: [[200, 100]], types: [[.Brick, .Brick]]))


        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 160, height: 200),
                CGRect(x: 160, y: 0, width: 160, height: 200),
            ]
        ]

        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
    }

    func testAlignRowHeightsMultipleRows() {
        collectionView.layout.alignRowHeights = true

        let half = CGFloat(1.0/2.0)
        let fourth = CGFloat(1.0/4.0)
        setDataSources(SectionsCollectionViewDataSource(sections: [8]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[half, half, fourth, fourth, fourth, fourth, fourth]], heights: [[100, 200, 100, 200, 100, 150, 100, 200]], types: [[.Brick, .Brick, .Brick, .Brick, .Brick, .Brick]]))


        let layoutFourth = CGFloat(320.0/4.0)
        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 160, height: 200),
                CGRect(x: 160, y: 0, width: 160, height: 200),
                CGRect(x: 0, y: 200, width: layoutFourth, height: 200),
                CGRect(x: layoutFourth, y: 200, width: layoutFourth, height: 200),
                CGRect(x: 2 * layoutFourth, y: 200, width: layoutFourth, height: 200),
                CGRect(x: 3 * layoutFourth, y: 200, width: layoutFourth, height: 200),
                CGRect(x: 0, y: 400, width: layoutFourth, height: 200),
                CGRect(x: layoutFourth, y: 400, width: layoutFourth, height: 200),
            ]
        ]

        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
    }

    func testAlignRowHeightsNoBricks() {
        collectionView.layout.alignRowHeights = true

        let half = CGFloat(1.0/2.0)
        setDataSources(SectionsCollectionViewDataSource(sections: [0]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[half]], heights: [[100]], types: [[.Brick]]))


        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: [:]))
    }

}

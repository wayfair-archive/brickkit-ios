//
//  BrickFlowLayoutZIndexTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/17/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

private let zIndexMap: (attribute: UICollectionViewLayoutAttributes) -> Int = { $0.zIndex }
private let zIndexSort: (Int, Int) -> Bool = { $0 < $1 }

class BrickFlowLayoutZIndexTests: BrickFlowLayoutBaseTests {
    /*
    section a
    ----brick aa
    ----section ab
    --------brick ab1
    --------section ab2
    ------------brick ab21
    ------------brick ab22
    ------------brick ab23
    ----brick ac
    ----section ad
    --------brick ad1
    --------section ad2
    ------------brick ad21
    ------------brick ad22
    ------------brick ad23
    ----brick ae
     */

    override func setUp() {
        super.setUp()

        let section = BrickSection("a", bricks: [
            DummyBrick("aa"),
            BrickSection("ab", bricks: [
                DummyBrick("ab1"),
                BrickSection("ab2", bricks: [
                    DummyBrick("ab21"),
                    DummyBrick("ab22"),
                    DummyBrick("ab23"),
                    ]),
                ]),
            DummyBrick("ac"),
            BrickSection("ad", bricks: [
                DummyBrick("ad1"),
                BrickSection("ad2", bricks: [
                    DummyBrick("ad21"),
                    DummyBrick("ad22"),
                    DummyBrick("ad23"),
                    ]),
                ]),
            DummyBrick("ae"),
            ])
        collectionView.registerBrickClass(DummyBrick.self)
        collectionView.setSection(section)
    }

    /*
     section a 0
     ----brick aa 15
     ----section ab 9
     --------brick ab1 14
     --------section ab2 10
     ------------brick ab21 13
     ------------brick ab22 12
     ------------brick ab23 11
     ----brick ac 8
     ----section ad 2
     --------brick ad1 7
     --------section ad2 3
     ------------brick ad21 6
     ------------brick ad22 5
     ------------brick ad23 4
     ----brick ae 1

     */
    func testTopDownZIndex() {
        layout.invalidateLayout()
        layout.prepareLayout()
        collectionView.layoutSubviews()

        let expectedResult = [
            0 : [
                0,
            ],
            1 : [
                15, 9, 8, 2, 1
            ],
            2 : [
                14, 10
            ],
            3 : [
                13, 12, 11
            ],
            4 : [
                7, 3
            ],
            5 : [
                6, 5, 4
            ],
            ]

        let attributes = layout.layoutAttributesForElementsInRect(CGRect(origin:CGPoint.zero, size: layout.collectionViewContentSize()))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, map: zIndexMap, expectedResult: expectedResult, sort: zIndexSort))
    }

    /*
     section a 0
     ----brick aa 1
     ----section ab 2
     --------brick ab1 3
     --------section ab2 4
     ------------brick ab21 5
     ------------brick ab22 6
     ------------brick ab23 7
     ----brick ac 8
     ----section ad 9
     --------brick ad1 10
     --------section ad2 11
     ------------brick ad21 12
     ------------brick ad22 13
     ------------brick ad23 14
     ----brick ae 15
     */
    func testBottomUpZIndex() {
        layout.zIndexBehavior = .BottomUp
        collectionView.layoutSubviews()

        let expectedResult = [
            0 : [
                0,
            ],
            1 : [
                1, 2, 8, 9, 15
            ],
            2 : [
                3, 4
            ],
            3 : [
                5, 6, 7
            ],
            4 : [
                10, 11
            ],
            5 : [
                12, 13, 14
            ],
            ]

        let attributes = layout.layoutAttributesForElementsInRect(CGRect(origin:CGPoint.zero, size: layout.collectionViewContentSize()))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, map: zIndexMap, expectedResult: expectedResult, sort: zIndexSort))
    }


    func testMaxZIndex() {
        layout.invalidateLayout()
        layout.prepareLayout()
        collectionView.layoutSubviews()

        XCTAssertEqual(layout.maxZIndex, 15)
    }
}

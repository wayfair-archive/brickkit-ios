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
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [IndexPath(item: 1, section: 1)])
        collectionView.layout.hideBehaviorDataSource = hideBehaviorDataSource

        collectionView.setupSectionAndLayout(BrickSection("Section 1", bricks: [
            DummyBrick(height: .fixed(size: 100)),
            DummyBrick(height: .fixed(size: 100))
            ]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100)
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 320, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 100))

        let indexPaths = attributes?.map { return $0.indexPath }
        XCTAssertEqual(indexPaths?.count, 2)
        XCTAssertEqual(indexPaths?[0], IndexPath(item: 0, section: 0))
        XCTAssertEqual(indexPaths?[1], IndexPath(item: 0, section: 1))
    }

    func testHideAllRowsBehavior() {
        let hideBehavior = FixedHideBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 1), IndexPath(item: 1, section: 1)])
        self.layout.hideBehaviorDataSource = hideBehavior

        collectionView.setupSectionAndLayout(BrickSection("Section 1", bricks: [
            DummyBrick(height: .fixed(size: 100)),
            DummyBrick(height: .fixed(size: 100))
            ], edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)))

        let expectedResult: [Int: [CGRect]] = [:]

        let attributes = collectionView.layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 0))
    }


    func testHideOneSectionBehavior() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [IndexPath(item: 1, section: 1)])
        self.layout.hideBehaviorDataSource = hideBehaviorDataSource

        collectionView.setupSectionAndLayout(BrickSection("Section 1", bricks: [
            DummyBrick(height: .fixed(size: 100)),
            BrickSection(bricks: [
                DummyBrick(height: .fixed(size: 100))
                ])
            ]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 100))

    }

    func testHideMultiSections() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 1)])
        collectionView.layout.hideBehaviorDataSource = hideBehaviorDataSource

        collectionView.setupSectionAndLayout(BrickSection("Section 1", bricks: [
            BrickSection("Section 2", bricks: [
                BrickSection("Section 3", bricks: [DummyBrick(height: .fixed(size: 50))]),
                BrickSection("Section 4", bricks: [DummyBrick(height: .fixed(size: 50))]),
                BrickSection("Section 5", bricks: [DummyBrick(height: .fixed(size: 50))])
                ])
            ]))

        XCTAssertEqual(collectionView.visibleCells.count, 0)
    }

    func testHideOneRowBehaviorWithHidden() {
        let section = BrickSection("Section 1", bricks: [
            DummyBrick(height: .fixed(size: 100)),
            DummyBrick(height: .fixed(size: 100))
            ])
        section.bricks[1].isHidden = true
        collectionView.setupSectionAndLayout(section)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100)
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 320, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 100))

        let indexPaths = attributes?.map { return $0.indexPath }
        XCTAssertEqual(indexPaths?.count, 2)
        XCTAssertEqual(indexPaths?[0], IndexPath(item: 0, section: 0))
        XCTAssertEqual(indexPaths?[1], IndexPath(item: 0, section: 1))
    }

    func testHideOneRowBehaviorWithHiddenAfterLayout() {
        let section = BrickSection("Section 1", bricks: [
            DummyBrick(height: .fixed(size: 100)),
            DummyBrick(height: .fixed(size: 100))
            ])
        collectionView.setupSectionAndLayout(section)

        section.bricks[1].isHidden = true
        collectionView.invalidateVisibility()
        collectionView.layoutSubviews()

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100)
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 320, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 100))

        let indexPaths = attributes?.map { return $0.indexPath }
        XCTAssertEqual(indexPaths?.count, 2)
        XCTAssertEqual(indexPaths?[0], IndexPath(item: 0, section: 0))
        XCTAssertEqual(indexPaths?[1], IndexPath(item: 0, section: 1))
    }

    func testHideAllRowsBehaviorWithHidden() {
        let section = BrickSection("Section 1", bricks: [
            DummyBrick(height: .fixed(size: 100)),
            DummyBrick(height: .fixed(size: 100))
            ], edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        section.bricks[0].isHidden = true
        section.bricks[1].isHidden = true
        collectionView.setupSectionAndLayout(section)


        let expectedResult: [Int: [CGRect]] = [:]

        let attributes = collectionView.layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 0))
    }


    func testHideOneSectionBehaviorWithHidden() {
        let section = BrickSection("Section 1", bricks: [
            DummyBrick(height: .fixed(size: 100)),
            BrickSection(bricks: [
                DummyBrick(height: .fixed(size: 100))
                ])
            ])
        section.bricks[1].isHidden = true
        collectionView.setupSectionAndLayout(section)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 100))

    }

    func testHideMultiSectionsWithHidden() {
        let section = BrickSection("Section 1", bricks: [
            BrickSection("Section 2", bricks: [
                BrickSection("Section 3", bricks: [DummyBrick(height: .fixed(size: 50))]),
                BrickSection("Section 4", bricks: [DummyBrick(height: .fixed(size: 50))]),
                BrickSection("Section 5", bricks: [DummyBrick(height: .fixed(size: 50))])
                ])
            ])
        section.bricks[0].isHidden = true
        collectionView.setupSectionAndLayout(section)
        
        XCTAssertEqual(collectionView.visibleCells.count, 0)
    }
    
}

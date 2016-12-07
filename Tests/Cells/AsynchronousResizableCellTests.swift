//
//  AsynchronousResizableCellTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class AsynchronousResizableCellTests: XCTestCase {
    var brickView: BrickCollectionView!

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    func setupSectionWithOneResizableCell() -> AsynchronousResizableBrick {
        brickView.registerBrickClass(AsynchronousResizableBrick.self)

        let resizableBrick = AsynchronousResizableBrick()
        let expectation = expectationWithDescription("Async")
        resizableBrick.didChangeSizeCallBack = {
            expectation.fulfill()
        }

        let section = BrickSection(bricks: [
            resizableBrick
            ])
        brickView.setSection(section)
        return resizableBrick
    }

    func testResizing() {
        let resizableBrick = setupSectionWithOneResizableCell()
        resizableBrick.newHeight = 100
        brickView.layoutSubviews()

        waitForExpectationsWithTimeout(5, handler: nil)

        brickView.layoutIfNeeded()

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
            ]
        ]

        let attributes = brickView.collectionViewLayout.layoutAttributesForElementsInRect(brickView.frame)
        let frames = brickView.visibleCells().map({ $0.frame })
        let expectedFrames = Array(expectedResult.values).flatMap({$0})

        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(frames, expectedFrames)

        XCTAssertEqual(brickView.collectionViewLayout.collectionViewContentSize(), CGSize(width: 320, height: 100))
    }

    func testResizingFixedHeight() {
        let resizableBrick = setupSectionWithOneResizableCell()

        resizableBrick.newHeight = 100
        resizableBrick.height = .Fixed(size: 70)
        
        brickView.layoutSubviews()

        waitForExpectationsWithTimeout(5, handler: nil)

        brickView.layoutIfNeeded()

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 70),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 320, height: 70),
            ]
        ]

        let attributes = brickView.collectionViewLayout.layoutAttributesForElementsInRect(brickView.frame)
        let frames = brickView.visibleCells().map({ $0.frame })
        let expectedFrames = Array(expectedResult.values).flatMap({$0})

        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(frames, expectedFrames)

        XCTAssertEqual(brickView.collectionViewLayout.collectionViewContentSize(), CGSize(width: 320, height: 70))
    }

    func testResizingFixedHeightAndDynamicHeight() {
        brickView.registerBrickClass(AsynchronousResizableBrick.self)

        let resizableBrick1 = AsynchronousResizableBrick()
        resizableBrick1.newHeight = 100

        let resizableBrick2 = AsynchronousResizableBrick()
        resizableBrick2.newHeight = 100
        resizableBrick2.size.height = .Fixed(size: 70)

        let expectation = expectationWithDescription("Async")

        var done1 = false
        var done2 = false

        resizableBrick1.didChangeSizeCallBack = {
            done1 = true
            if done1 && done2 {
                expectation.fulfill()
            }
        }

        resizableBrick2.didChangeSizeCallBack = {
            done2 = true
            if done1 && done2 {
                expectation.fulfill()
            }
        }

        let section = BrickSection(bricks: [
            resizableBrick1,
            resizableBrick2
            ])

        brickView.setSection(section)

        brickView.layoutSubviews()

        waitForExpectationsWithTimeout(5, handler: nil)

        brickView.layoutIfNeeded()

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 170),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
                CGRect(x: 0, y: 100, width: 320, height: 70),
            ]
        ]

        let attributes = brickView.collectionViewLayout.layoutAttributesForElementsInRect(brickView.frame)
        let frames = brickView.visibleCells().map({ $0.frame })
        let expectedFrames = Array(expectedResult.values).flatMap({$0})

        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(frames.sort(frameSort), expectedFrames.sort(frameSort))

        XCTAssertEqual(brickView.collectionViewLayout.collectionViewContentSize(), CGSize(width: 320, height: 170))
    }

    func testResizingInCollectionBrick() {
        brickView.registerBrickClass(CollectionBrick.self)

        let expectation = expectationWithDescription("Async")

        let resizableBrick = AsynchronousResizableBrick()
        resizableBrick.newHeight = 100
        resizableBrick.didChangeSizeCallBack = {
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                expectation.fulfill()
            })
        }

        let collectionSection = BrickSection(bricks: [
            resizableBrick
            ])

        let section = BrickSection(bricks: [
            CollectionBrick(dataSource: CollectionBrickCellModel(section: collectionSection), brickTypes: [AsynchronousResizableBrick.self])])


        brickView.setSection(section)
        brickView.layoutSubviews()

        waitForExpectationsWithTimeout(5, handler: nil)

        brickView.layoutIfNeeded()

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
            ]
        ]

        let attributes = brickView.collectionViewLayout.layoutAttributesForElementsInRect(brickView.frame)
        let frames = brickView.visibleCells().map({ $0.frame })
        let expectedFrames = Array(expectedResult.values).flatMap({$0})

        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(frames, expectedFrames)

        XCTAssertEqual(brickView.collectionViewLayout.collectionViewContentSize(), CGSize(width: 320, height: 100))
    }

    func testResizingInCollectionBrickScrolling() {
        brickView.registerBrickClass(CollectionBrick.self)


        let collectionSection = BrickSection(bricks: [
            DummyBrick(width: .Ratio(ratio: 1/2)),
            DummyBrick(width: .Ratio(ratio: 1/2)),
            DummyBrick(width: .Ratio(ratio: 1/2)),
            DummyBrick(width: .Ratio(ratio: 1/2)),
            DummyBrick(width: .Ratio(ratio: 1)),
            ])

        let section = BrickSection(bricks: [
            CollectionBrick(scrollDirection: .Horizontal, dataSource: CollectionBrickCellModel(section: collectionSection, configureHandler: { (cell) in
                cell.brickCollectionView.registerBrickClass(DummyBrick.self)
            }))
            ])


        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CollectionBrickCell
        cell?.brickCollectionView.contentOffset.x = 2 * brickView.frame.width
        brickView.layoutIfNeeded()

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 640),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 320, height: 640),
            ]
        ]

        let attributes = brickView.collectionViewLayout.layoutAttributesForElementsInRect(brickView.frame)
        let frames = brickView.visibleCells().map({ $0.frame })
        let expectedFrames = Array(expectedResult.values).flatMap({$0})

        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(frames, expectedFrames)

        XCTAssertEqual(brickView.collectionViewLayout.collectionViewContentSize(), CGSize(width: 320, height: 640))
    }

}

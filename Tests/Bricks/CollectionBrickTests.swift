//
//  CollectionBrickTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/5/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class CollectionBrickTests: XCTestCase {
    
    var brickView: BrickCollectionView!

    override func setUp() {
        super.setUp()

        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    func testCollectionBrickRepeatCount() {
        brickView.registerBrickClass(CollectionBrick.self)

        let repeatDataSource = CollectionViewRepeatDataSource(repeatCounts: [
            "Collection1": 1,
            "Collection2": 2,
            "Collection3": 3
            ])
        let collectionSection = BrickSection("CollectionSection", bricks: [
            DummyBrick("Brick", width: .fixed(size: 10), height: .fixed(size: 10))
            ])
        collectionSection.repeatCountDataSource = repeatDataSource

        let section = BrickSection(bricks: [
            CollectionBrick("Collection1", height: .fixed(size: 10), dataSource: CollectionBrickCellModel(section: collectionSection, configureHandler: { cell in
                cell.brickCollectionView.registerBrickClass(DummyBrick.self)
            })),
            CollectionBrick("Collection2", height: .fixed(size: 10), dataSource: CollectionBrickCellModel(section: collectionSection, registerBricksHandler: { cell in
                cell.brickCollectionView.registerBrickClass(DummyBrick.self)
            })),
            CollectionBrick("Collection3", height: .fixed(size: 10), dataSource: CollectionBrickCellModel(section: collectionSection), brickTypes: [DummyBrick.self])
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()
        brickView.layoutIfNeeded()

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CollectionBrickCell
        XCTAssertEqual(cell1?.brickCollectionView.visibleCells.count, 2)
        let cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1)) as? CollectionBrickCell
        XCTAssertEqual(cell2?.brickCollectionView.visibleCells.count, 3)
        let cell3 = brickView.cellForItem(at: IndexPath(item: 2, section: 1)) as? CollectionBrickCell
        XCTAssertEqual(cell3?.brickCollectionView.visibleCells.count, 4)

        XCTAssertEqual(cell1!.brickCollectionView.dataSource!.collectionView(cell1!.brickCollectionView, numberOfItemsInSection: 1), 1)
        XCTAssertEqual(cell2!.brickCollectionView.dataSource!.collectionView(cell1!.brickCollectionView, numberOfItemsInSection: 1), 2)
        XCTAssertEqual(cell3!.brickCollectionView.dataSource!.collectionView(cell1!.brickCollectionView, numberOfItemsInSection: 1), 3)
    }

    func testCollectionViewFrame() {
        let collectionSection = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 200))
            ])
        let section = BrickSection(bricks: [
            CollectionBrick("Collection1", dataSource: CollectionBrickCellModel(section: collectionSection, configureHandler: { cell in
                cell.brickCollectionView.registerBrickClass(DummyBrick.self)
            }))
            ], edgeInsets: UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0))
        brickView.setupSectionAndLayout(section)

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CollectionBrickCell
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 300, width: 320, height: 200))
        cell1?.layoutIfNeeded()
        XCTAssertEqual(cell1?.brickCollectionView.frame, CGRect(x: 0, y: 0, width: 320, height: 200))

        XCTAssertFalse(brickView.layout.isInCollectionBrick)
        XCTAssertTrue(cell1!.brickCollectionView.layout.isInCollectionBrick)
    }

    func testCollectionViewLargeFrame() {
        brickView.registerBrickClass(CollectionBrick.self)

        let collectionSection = BrickSection("CollectionSection", bricks: [
            DummyBrick("1", height: .auto(estimate: .fixed(size: 1000))),
            DummyBrick("2", height: .auto(estimate: .fixed(size: 1000))),
            DummyBrick("3", height: .auto(estimate: .fixed(size: 1000))),
            DummyBrick("4", height: .auto(estimate: .fixed(size: 1000)))
            ])

        let section = BrickSection("RootSection", bricks: [
            CollectionBrick("Collection1", dataSource: CollectionBrickCellModel(section: collectionSection, configureHandler: { cell in
                cell.brickCollectionView.registerBrickClass(DummyBrick.self)
            }))
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let expectation = self.expectation(description: "Wait for batch updates")
        brickView.performBatchUpdates({ 
            // Run this inside a performBatchUpdates, so this is called after the sizeChangeHandler was called
            }) { (completed) in
                expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CollectionBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertEqual(cell1?.brickCollectionView.frame, CGRect(x: 0, y: 0, width: 320, height: 320 * 8))
    }

    func testThatCollectionBrickDoesNotSendOutUpdatesDuringLayoutSubviews() {
        brickView.registerBrickClass(CollectionBrick.self)

        let collectionSection = BrickSection("CollectionSection", bricks: [
            LabelBrick(text: "a")
            ])

        let section = BrickSection("RootSection", bricks: [
            CollectionBrick("Collection1", dataSource: CollectionBrickCellModel(section: collectionSection, configureHandler: { cell in
                cell.brickCollectionView.registerBrickClass(LabelBrick.self)
            }))
            ])

        let delegate = FixedBrickLayoutDelegate()
        brickView.layout.delegate = delegate
        brickView.setupSectionAndLayout(section)

        XCTAssertEqual(delegate.count, 1, "The delegate should have only been called 1 time for the updated height of the CollectionBrick")
    }

    func testThatCollectionViewZeroFrameHeight() {
        brickView.registerBrickClass(CollectionBrick.self)

        let collectionSection = BrickSection("CollectionSection", bricks: [
            DummyBrick("1", height: .auto(estimate: .fixed(size: 1000))),
            DummyBrick("2", height: .auto(estimate: .fixed(size: 1000))),
            DummyBrick("3", height: .auto(estimate: .fixed(size: 1000))),
            DummyBrick("4", height: .auto(estimate: .fixed(size: 1000)))
            ])

        let section = BrickSection("RootSection", bricks: [
            CollectionBrick("Collection1", dataSource: CollectionBrickCellModel(section: collectionSection), brickTypes: [DummyBrick.self])
            ])

        brickView.setupSectionAndLayout(section)

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CollectionBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertEqual(cell1?.brickCollectionView.frame, CGRect(x: 0, y: 0, width: 320, height: 320 * 8))

        let mockAttributes = UICollectionViewLayoutAttributes()
        mockAttributes.bounds = CGRect(x: 0, y: 0, width: 0, height: 0)

        _ = cell1?.preferredLayoutAttributesFitting(mockAttributes) // if the function returns the test passes
    }


    func testThatCollectionBrickPerformsResizeWhileDealloc() {
        let expect = expectation(description: "CollectionBrick contains Async bricks that release after calling sizeChangedHandler")

        let resizableBrick = DeinitNotifyingAsyncBrick(size: BrickSize(width: .fill, height: .fill))

        let collectionSection = BrickSection(bricks: [
            resizableBrick
            ])

        let section = BrickSection(bricks: [
            CollectionBrick(scrollDirection: .horizontal, dataSource: CollectionBrickCellModel(section: collectionSection), brickTypes: [DeinitNotifyingAsyncBrick.self])
            ])

        brickView.setSection(section)
        brickView.layoutSubviews()

        var cell = self.brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CollectionBrickCell
        XCTAssertNotNil(cell)
        XCTAssertNotNil(cell?.resizeDelegate)
        XCTAssertTrue(cell?.resizeDelegate === brickView)

        cell?.resizeDelegate?.performResize(cell: cell!, completion: {
            expect.fulfill()
        })

        cell?.brickCollectionView = nil
        cell = nil
        brickView = nil

        XCTAssertNil(brickView)
        XCTAssertNil(cell)

        waitForExpectations(timeout: 3, handler: nil)
    }
}


class FixedBrickLayoutDelegate: BrickLayoutDelegate {
    var count = 0

    func brickLayout(_ layout: BrickLayout, didUpdateHeightForItemAtIndexPath indexPath: IndexPath) {
        count += 1
    }

}

class CollectionViewRepeatDataSource: BrickRepeatCountDataSource {
    var requestedRepeatCounts: [Int: String] = [:]
    var repeatCounts: [String: Int]

    init(repeatCounts: [String: Int]) {
        self.repeatCounts = repeatCounts
    }

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == "Brick" {
            return repeatCounts[collectionIdentifier] ?? 1
        } else {
            return 1
        }
    }
}

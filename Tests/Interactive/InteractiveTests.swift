//
//  InteractiveTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/30/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class InteractiveTests: XCTestCase {
    
    var brickView: BrickCollectionView!

    let LabelBrickIdentifier = "Label"
    let DummyBrickIdentifier = "Dummy"
    let CollectionBrickIdentifier = "Collection"
    let RootSectionIdentifier = "RootSection"

    var labelModel: LabelBrickCellModel!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        labelModel = LabelBrickCellModel(text: "A")
    }

    //MARK: invalidateRepeatCounts

    func testInvalidateRepeatCounts() {
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(LabelBrickIdentifier, height: .Fixed(size: 10), dataSource: labelModel)
            ])
        let fixedCount = FixedRepeatCountDataSource(repeatCountHash: [LabelBrickIdentifier: 1])
        section.repeatCountDataSource = fixedCount
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        XCTAssertEqual(brickView.subviews.count, 2)

        fixedCount.repeatCountHash[LabelBrickIdentifier] = 5

        let indexPathSort: (NSIndexPath, NSIndexPath) -> Bool = { indexPath1, indexPath2  in
            if indexPath1.section == indexPath2.section {
                return indexPath1.item < indexPath2.item
            } else {
                return indexPath1.section < indexPath2.section
            }
        }

        let addedExpectation = expectationWithDescription("Added Bricks")
        self.brickView.invalidateRepeatCounts { (completed, insertedIndexPaths, deletedIndexPaths) in
            XCTAssertEqual(insertedIndexPaths.sort(indexPathSort), [
                NSIndexPath(forItem: 1, inSection: 1),
                NSIndexPath(forItem: 2, inSection: 1),
                NSIndexPath(forItem: 3, inSection: 1),
                NSIndexPath(forItem: 4, inSection: 1),
                ])
            XCTAssertEqual(deletedIndexPaths, [])

            addedExpectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)

        XCTAssertEqual(brickView.visibleCells().count, 6)

        fixedCount.repeatCountHash[LabelBrickIdentifier] = 1

        let removedExpectation = expectationWithDescription("Removed Bricks")
        self.brickView.invalidateRepeatCounts { (completed, insertedIndexPaths, deletedIndexPaths) in
            XCTAssertEqual(insertedIndexPaths, [])
            XCTAssertEqual(deletedIndexPaths.sort(indexPathSort), [
                NSIndexPath(forItem: 1, inSection: 1),
                NSIndexPath(forItem: 2, inSection: 1),
                NSIndexPath(forItem: 3, inSection: 1),
                NSIndexPath(forItem: 4, inSection: 1),
                ])
            removedExpectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)

        XCTAssertEqual(brickView.visibleCells().count, 2)
    }

    func testInvalidateRepeatCountsLess() {
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                LabelBrick("Brick1", height: .Fixed(size: 10), dataSource: labelModel),
                ]),
            LabelBrick("Brick2", height: .Fixed(size: 10), dataSource: labelModel),
            BrickSection(bricks: [
                LabelBrick("Brick3", height: .Fixed(size: 10), dataSource: labelModel),
                ]),
            ])

        let fixedCount = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 5, "Brick2": 5, "Brick3": 5])
        section.repeatCountDataSource = fixedCount
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        XCTAssertEqual(brickView.visibleCells().count, 18)

        fixedCount.repeatCountHash = ["Brick1": 2, "Brick2": 2, "Brick3": 2]

        let addedExpectation = expectationWithDescription("Added Bricks")
        self.brickView.invalidateRepeatCounts { (completed) in
            addedExpectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)

        XCTAssertEqual(brickView.visibleCells().count, 9)
        let flow = brickView.layout 
        XCTAssertEqual(flow.sections?[3]?.sectionAttributes?.indexPath, NSIndexPath(forItem: 3, inSection: 1))
    }

    func testInvalidateRepeatCountsMultiSections() {
        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick("Brick1", height: .Fixed(size: 10)),
            BrickSection(bricks: [
                DummyBrick("Brick2", height: .Fixed(size: 10)),
                BrickSection(bricks: [
                    DummyBrick("Brick3", height: .Fixed(size: 10))
                    ])
                ]),
            BrickSection(bricks: [
                DummyBrick("Brick4", height: .Fixed(size: 10))
                ])
            ])

        let fixed = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 5, "Brick2": 4, "Brick3": 3, "Brick4": 2])
        section.repeatCountDataSource = fixed

        brickView.setSection(section)
        brickView.layoutIfNeeded()
        XCTAssertEqual(brickView.visibleCells().count, 18)

        fixed.repeatCountHash["Brick1"] = 3
        fixed.repeatCountHash["Brick2"] = 2
        fixed.repeatCountHash["Brick3"] = 1
        fixed.repeatCountHash["Brick4"] = 0

        let repeatCountExpectation = expectationWithDescription("RepeatCount")
        self.brickView.invalidateRepeatCounts { (completed) in
            repeatCountExpectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)

        XCTAssertEqual(brickView.visibleCells().count, 10)
    }


    //MARK: reloadBricksWithIdentifiers

    func testReloadBricksWithIdentifiersNotReloadCell() {

        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(LabelBrickIdentifier, dataSource: labelModel)
            ])
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        labelModel.text = "B"

        let expectation = expectationWithDescription("Reload")
        brickView.reloadBricksWithIdentifiers([LabelBrickIdentifier], shouldReloadCell: false) { (completed) in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)

        let label = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? LabelBrickCell
        XCTAssertNotNil(label)

        XCTAssertEqual(label?.label.text, "B")
    }

    func testReloadBricksWithIdentifiersNotReloadCellOffScreen() {

        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(LabelBrickIdentifier, dataSource: labelModel)
            ], edgeInsets: UIEdgeInsets(top: 1000, left: 0, bottom: 0, right: 0))
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        labelModel.text = "B"

        let expectation = expectationWithDescription("Reload")
        brickView.reloadBricksWithIdentifiers([LabelBrickIdentifier], shouldReloadCell: false) { (completed) in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)

        var label = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? LabelBrickCell
        XCTAssertNil(label)

        brickView.contentOffset.y = 1000
        brickView.layoutIfNeeded()

        label = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? LabelBrickCell
        XCTAssertNotNil(label)

        XCTAssertEqual(label?.label.text, "B")
    }

    func testReloadBricksWithIdentifiersReloadCell() {

        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(LabelBrickIdentifier, dataSource: labelModel)
            ])
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        labelModel.text = "B"

        let expectation = expectationWithDescription("Reload")
        brickView.reloadBricksWithIdentifiers([LabelBrickIdentifier], shouldReloadCell: true) { (completed) in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)

        let label = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? LabelBrickCell
        XCTAssertNotNil(label)

        XCTAssertEqual(label?.label.text, "B")
    }

    func testReloadBricksWithIdentifiersReloadCellMultiSectionAdd() {

        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(RootSectionIdentifier, bricks: [
            LabelBrick(LabelBrickIdentifier, height: .Fixed(size: 10), dataSource: labelModel)
            ])
        let fixedCount = FixedRepeatCountDataSource(repeatCountHash: [LabelBrickIdentifier: 1])
        section.repeatCountDataSource = fixedCount
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        XCTAssertEqual(brickView.subviews.count, 2)

        fixedCount.repeatCountHash[LabelBrickIdentifier] = 5

        let expectation = expectationWithDescription("Reload")
        brickView.reloadBricksWithIdentifiers([RootSectionIdentifier], shouldReloadCell: true) { (completed) in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)

        XCTAssertEqual(brickView.visibleCells().count, 6)
    }

    func testReloadBricksWithIdentifiersReloadCellMultiSectionRemove() {

        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(RootSectionIdentifier, bricks: [
            LabelBrick(LabelBrickIdentifier, height: .Fixed(size: 10), dataSource: labelModel)
            ])
        let fixedCount = FixedRepeatCountDataSource(repeatCountHash: [LabelBrickIdentifier: 5])
        section.repeatCountDataSource = fixedCount
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        XCTAssertEqual(brickView.visibleCells().count, 6)

        fixedCount.repeatCountHash[LabelBrickIdentifier] = 1

        let expectation = expectationWithDescription("Reload")
        brickView.reloadBricksWithIdentifiers([RootSectionIdentifier], shouldReloadCell: true) { (completed) in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)

        XCTAssertEqual(brickView.visibleCells().count, 2)
    }

    // Mark: - ReloadBricksWithIdentifier
    func testReloadBricksWithIdentifier() {

        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(LabelBrickIdentifier, dataSource: labelModel)
            ])
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        labelModel.text = "B"

        brickView.reloadBrickWithIdentifier(LabelBrickIdentifier, andIndex: 0)
        brickView.layoutIfNeeded()

        let label = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? LabelBrickCell
        XCTAssertNotNil(label)

        XCTAssertEqual(label?.label.text, "B")
    }

    func testReloadBricksWithIdentifierChangeWidth() {

        brickView.registerBrickClass(LabelBrick.self)

        let brick = LabelBrick(LabelBrickIdentifier, height: .Fixed(size: 100), dataSource: labelModel)
        let section = BrickSection(bricks: [
            brick
            ])
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        var label: LabelBrickCell
        label = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as! LabelBrickCell
        XCTAssertNotNil(label)
        XCTAssertEqual(label.frame, CGRect(x: 0, y: 0, width: 320, height: 100))

        brick.width = .Ratio(ratio: 1/2)

        let expectation = expectationWithDescription("Reload")
        brickView.performBatchUpdates({ 
            self.brickView.reloadBrickWithIdentifier(self.LabelBrickIdentifier, andIndex: 0)
            }) { (completed) in
                self.brickView.collectionViewLayout.invalidateLayout()
                expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)

        brickView.layoutSubviews()

        XCTAssertEqual(brickView.collectionViewLayout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))?.frame, CGRect(x: 0, y: 0, width: 160, height: 100))
        XCTAssertEqual(brickView.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))?.frame, CGRect(x: 0, y: 0, width: 160, height: 100))

        label = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as! LabelBrickCell
        XCTAssertNotNil(label)
        XCTAssertEqual(label.frame, CGRect(x: 0, y: 0, width: 160, height: 100))
    }


    //MARK: reloadBricksWithIdentifiers

    func testReloadBricksWithIdentifiersCollectionBrick() {
        brickView.registerBrickClass(CollectionBrick.self)

        let collectionSection = BrickSection(bricks: [
            LabelBrick(LabelBrickIdentifier, dataSource: labelModel)
            ])

        let section = BrickSection(bricks: [
            CollectionBrick(CollectionBrickIdentifier, dataSource: CollectionBrickCellModel(section: collectionSection, configureHandler: { (cell) in
                cell.brickCollectionView.registerBrickClass(LabelBrick.self)
            }))
            ])
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        labelModel.text = "B"
        brickView.reloadBricksWithIdentifiers([LabelBrickIdentifier], inCollectionBrickWithIdentifier: CollectionBrickIdentifier)

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CollectionBrickCell
        XCTAssertNotNil(cell)

        let label = cell!.brickCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? LabelBrickCell
        XCTAssertNotNil(label)

        XCTAssertEqual(label?.label.text, "B")
        
    }

    func testReloadBricksWithIdentifiersCollectionBrickOffscreen() {
        brickView.registerBrickClass(CollectionBrick.self)

        let collectionSection = BrickSection(bricks: [
            LabelBrick(LabelBrickIdentifier, dataSource: labelModel)
            ])

        let section = BrickSection(bricks: [
            CollectionBrick(CollectionBrickIdentifier, dataSource: CollectionBrickCellModel(section: collectionSection, configureHandler: { (cell) in
                cell.brickCollectionView.registerBrickClass(LabelBrick.self)
            }))
            ], edgeInsets: UIEdgeInsets(top: 1000, left: 0, bottom: 0, right: 0))
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        labelModel.text = "B"
        brickView.reloadBricksWithIdentifiers([LabelBrickIdentifier], inCollectionBrickWithIdentifier: CollectionBrickIdentifier)

        var cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CollectionBrickCell
        XCTAssertNil(cell)

        brickView.contentOffset.y = 1000
        brickView.layoutIfNeeded()
        cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CollectionBrickCell
        XCTAssertNotNil(cell)

        let label = cell!.brickCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? LabelBrickCell
        XCTAssertNotNil(label)

        XCTAssertEqual(label?.label.text, "B")
    }

    func testReloadBricksWithIdentifiersCollectionBrickAtIndex() {
        brickView.registerBrickClass(CollectionBrick.self)

        let collectionSection = BrickSection(bricks: [
            LabelBrick(LabelBrickIdentifier, dataSource: labelModel)
            ])

        let section = BrickSection(bricks: [
            CollectionBrick(CollectionBrickIdentifier, dataSource: CollectionBrickCellModel(section: collectionSection, configureHandler: { (cell) in
                cell.brickCollectionView.registerBrickClass(LabelBrick.self)
            }))
            ])
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: [CollectionBrickIdentifier: 5])
        section.repeatCountDataSource = repeatCountDataSource

        brickView.setSection(section)
        brickView.layoutIfNeeded()

        labelModel.text = "B"
        brickView.reloadBricksWithIdentifiers([LabelBrickIdentifier], inCollectionBrickWithIdentifier: CollectionBrickIdentifier, andIndex: 2)

        let cell1 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CollectionBrickCell
        XCTAssertNotNil(cell1)

        let label1 = cell1!.brickCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? LabelBrickCell
        XCTAssertNotNil(label1)

        XCTAssertEqual(label1!.label.text, "A")

        let cell2 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 1)) as? CollectionBrickCell
        XCTAssertNotNil(cell2)

        let label2 = cell2!.brickCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? LabelBrickCell
        XCTAssertNotNil(label2)

        XCTAssertEqual(label2!.label.text, "B")

    }

    //MARK: invalidateHeightForBrickWithIdentifier

    func testInvalidateHeightForBrickWithIdentifier() {
        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(DummyBrickIdentifier, height: .Auto(estimate: .Ratio(ratio: 1)))
            ])
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        brickView.invalidateHeightForBrickWithIdentifier(DummyBrickIdentifier, newHeight: 21)
        brickView.layoutIfNeeded()

        let cell1 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? DummyBrickCell
        XCTAssertNotNil(cell1)

        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 21))
    }

    func testInvalidateHeightForBrickWithIdentifierAuto() {
        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(DummyBrickIdentifier, height: .Auto(estimate: .Ratio(ratio: 1)))
            ])
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        brickView.invalidateHeightForBrickWithIdentifier(DummyBrickIdentifier, newHeight: 21)
        brickView.layoutIfNeeded()

        let cell1 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? DummyBrickCell
        XCTAssertNotNil(cell1)

        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 21))
    }

    func testInvalidateHeightForBrickWithoutIdentifier() {
        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(DummyBrickIdentifier, height: .Auto(estimate: .Ratio(ratio: 1)))
            ])
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        var cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? DummyBrickCell
        XCTAssertNotNil(cell)
        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: 0, width: 320, height: 640))

        cell?.frame.size.height = 10

        brickView.invalidateHeightForBrickWithIdentifier(DummyBrickIdentifier, newHeight: nil)
        brickView.layoutIfNeeded()

        cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? DummyBrickCell
        XCTAssertNotNil(cell)
        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: 0, width: 320, height: 640))

    }

    // Mark: - Invalidate while sticky

    func testInvalidateWhileSticky() {
        brickView.registerBrickClass(DummyBrick.self)
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(height: .Fixed(size: 50)),
            BrickSection(bricks: [
                LabelBrick(DummyBrickIdentifier, text: "", configureCellBlock: { cell in
                    var text = "Brick"
                    for _ in 0..<cell.index {
                        text += "\nBrick"
                    }
                    cell.label.text = text
                })
                ])
            ])
        
        let fixedStickyLayout = FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 1)])
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: [DummyBrickIdentifier: 30])
        section.repeatCountDataSource = repeatCountDataSource
        let sticky = StickyLayoutBehavior(dataSource: fixedStickyLayout)
        brickView.layout.behaviors.insert(sticky)

        brickView.setSection(section)
        brickView.layoutSubviews()

        brickView.contentOffset.y += brickView.frame.size.height
        brickView.collectionViewLayout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))
        brickView.layoutIfNeeded()

        let cell1 = brickView.collectionViewLayout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(cell1?.frame.origin.y, 50)
        let cell2 = brickView.collectionViewLayout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 0, y: brickView.contentOffset.y, width: 320, height: 50))
    }

    // Mark: - Shouldn't crash
    func testShouldNotCrashOnReloadBricks() {
        // we should check if the indexpath exists before adding it...
        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            BrickSection("Section", bricks: [
                DummyBrick("Item", width: .Ratio(ratio: 1/2), height: .Fixed(size: 38)),
                ], inset: 5, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)),
            ])

        let repeatCount = FixedRepeatCountDataSource(repeatCountHash: ["Item": 0])
        section.repeatCountDataSource = repeatCount
        
        brickView.setSection(section)
        brickView.layoutSubviews()

        var expectation: XCTestExpectation!

        repeatCount.repeatCountHash["Item"] = 30
        expectation = expectationWithDescription("Invalidate bricks")
        brickView.invalidateBricks { (completed) in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)

        repeatCount.repeatCountHash["Item"] = 0
        expectation = expectationWithDescription("Invalidate bricks")
        brickView.invalidateBricks { (completed) in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
}

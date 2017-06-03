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
            LabelBrick(LabelBrickIdentifier, height: .fixed(size: 10), dataSource: labelModel)
            ])
        let fixedCount = FixedRepeatCountDataSource(repeatCountHash: [LabelBrickIdentifier: 1])
        section.repeatCountDataSource = fixedCount
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        XCTAssertEqual(brickView.subviews.count, 2)

        fixedCount.repeatCountHash[LabelBrickIdentifier] = 5

        let indexPathSort: (IndexPath, IndexPath) -> Bool = { indexPath1, indexPath2  in
            if indexPath1.section == indexPath2.section {
                return indexPath1.item < indexPath2.item
            } else {
                return indexPath1.section < indexPath2.section
            }
        }

        let addedExpectation = expectation(description: "Added Bricks")
        self.brickView.invalidateRepeatCounts { (completed, insertedIndexPaths, deletedIndexPaths) in
            XCTAssertEqual(insertedIndexPaths.sorted(by: indexPathSort), [
                IndexPath(item: 1, section: 1),
                IndexPath(item: 2, section: 1),
                IndexPath(item: 3, section: 1),
                IndexPath(item: 4, section: 1),
                ])
            XCTAssertEqual(deletedIndexPaths, [])

            addedExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(brickView.visibleCells.count, 6)

        fixedCount.repeatCountHash[LabelBrickIdentifier] = 1

        let removedExpectation = expectation(description: "Removed Bricks")
        self.brickView.invalidateRepeatCounts { (completed, insertedIndexPaths, deletedIndexPaths) in
            XCTAssertEqual(insertedIndexPaths, [])
            XCTAssertEqual(deletedIndexPaths.sorted(by: indexPathSort), [
                IndexPath(item: 1, section: 1),
                IndexPath(item: 2, section: 1),
                IndexPath(item: 3, section: 1),
                IndexPath(item: 4, section: 1),
                ])
            removedExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(brickView.visibleCells.count, 2)
    }

    func testInvalidateRepeatCountsLess() {
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                LabelBrick("Brick1", height: .fixed(size: 10), dataSource: labelModel),
                ]),
            LabelBrick("Brick2", height: .fixed(size: 10), dataSource: labelModel),
            BrickSection(bricks: [
                LabelBrick("Brick3", height: .fixed(size: 10), dataSource: labelModel),
                ]),
            ])

        let fixedCount = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 5, "Brick2": 5, "Brick3": 5])
        section.repeatCountDataSource = fixedCount
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        XCTAssertEqual(brickView.visibleCells.count, 18)

        fixedCount.repeatCountHash = ["Brick1": 2, "Brick2": 2, "Brick3": 2]

        let addedExpectation = expectation(description: "Added Bricks")
        self.brickView.invalidateRepeatCounts { (_, _, _) in
            addedExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(brickView.visibleCells.count, 9)
        let flow = brickView.layout 
        XCTAssertEqual(flow.sections?[3]?.sectionAttributes?.indexPath, IndexPath(item: 3, section: 1))
    }

    func testInvalidateRepeatCountsMultiSections() {
        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick("Brick1", height: .fixed(size: 10)),
            BrickSection(bricks: [
                DummyBrick("Brick2", height: .fixed(size: 10)),
                BrickSection(bricks: [
                    DummyBrick("Brick3", height: .fixed(size: 10))
                    ])
                ]),
            BrickSection(bricks: [
                DummyBrick("Brick4", height: .fixed(size: 10))
                ])
            ])

        let fixed = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 5, "Brick2": 4, "Brick3": 3, "Brick4": 2])
        section.repeatCountDataSource = fixed

        brickView.setSection(section)
        brickView.layoutIfNeeded()
        XCTAssertEqual(brickView.visibleCells.count, 18)

        fixed.repeatCountHash["Brick1"] = 3
        fixed.repeatCountHash["Brick2"] = 2
        fixed.repeatCountHash["Brick3"] = 1
        fixed.repeatCountHash["Brick4"] = 0

        let repeatCountExpectation = expectation(description: "RepeatCount")
        self.brickView.invalidateRepeatCounts { (_, _, _) in
            repeatCountExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(brickView.visibleCells.count, 10)
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

        let expectation = self.expectation(description: "Reload")
        brickView.reloadBricksWithIdentifiers([LabelBrickIdentifier], shouldReloadCell: false) { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        let label = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? LabelBrickCell
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

        let expectation = self.expectation(description: "Reload")
        brickView.reloadBricksWithIdentifiers([LabelBrickIdentifier], shouldReloadCell: false) { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        var label = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? LabelBrickCell
        XCTAssertNil(label)

        brickView.contentOffset.y = 1000
        brickView.layoutIfNeeded()

        label = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? LabelBrickCell
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

        let expectation = self.expectation(description: "Reload")
        brickView.reloadBricksWithIdentifiers([LabelBrickIdentifier], shouldReloadCell: true) { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        let label = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? LabelBrickCell
        XCTAssertNotNil(label)

        XCTAssertEqual(label?.label.text, "B")
    }

    func testReloadBricksWithIdentifiersReloadCellMultiSectionAdd() {

        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(RootSectionIdentifier, bricks: [
            LabelBrick(LabelBrickIdentifier, height: .fixed(size: 10), dataSource: labelModel)
            ])
        let fixedCount = FixedRepeatCountDataSource(repeatCountHash: [LabelBrickIdentifier: 1])
        section.repeatCountDataSource = fixedCount
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        XCTAssertEqual(brickView.subviews.count, 2)

        fixedCount.repeatCountHash[LabelBrickIdentifier] = 5

        let expectation = self.expectation(description: "Reload")
        brickView.reloadBricksWithIdentifiers([RootSectionIdentifier], shouldReloadCell: true) { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(brickView.visibleCells.count, 6)
    }

    func testReloadBricksWithIdentifiersReloadCellMultiSectionRemove() {

        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(RootSectionIdentifier, bricks: [
            LabelBrick(LabelBrickIdentifier, height: .fixed(size: 10), dataSource: labelModel)
            ])
        let fixedCount = FixedRepeatCountDataSource(repeatCountHash: [LabelBrickIdentifier: 5])
        section.repeatCountDataSource = fixedCount
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        XCTAssertEqual(brickView.visibleCells.count, 6)

        fixedCount.repeatCountHash[LabelBrickIdentifier] = 1

        let expectation = self.expectation(description: "Reload")
        brickView.reloadBricksWithIdentifiers([RootSectionIdentifier], shouldReloadCell: true) { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(brickView.visibleCells.count, 2)
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

        let label = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? LabelBrickCell
        XCTAssertNotNil(label)

        XCTAssertEqual(label?.label.text, "B")
    }

    func testReloadBricksWithIdentifierChangeWidth() {

        brickView.registerBrickClass(LabelBrick.self)

        let brick = LabelBrick(LabelBrickIdentifier, height: .fixed(size: 100), dataSource: labelModel)
        let section = BrickSection(bricks: [
            brick
            ])
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        var label: LabelBrickCell
        label = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as! LabelBrickCell
        XCTAssertNotNil(label)
        XCTAssertEqual(label.frame, CGRect(x: 0, y: 0, width: 320, height: 100))

        brick.size.width = .ratio(ratio: 1/2)

        let expectation = self.expectation(description: "Reload")
        brickView.performBatchUpdates({ 
            self.brickView.reloadBrickWithIdentifier(self.LabelBrickIdentifier, andIndex: 0)
            }) { (completed) in
                self.brickView.collectionViewLayout.invalidateLayout()
                expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        brickView.layoutSubviews()

        XCTAssertEqual(brickView.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: 0, section: 1))?.frame, CGRect(x: 0, y: 0, width: 160, height: 100))
        XCTAssertEqual(brickView.layoutAttributesForItem(at: IndexPath(item: 0, section: 1))?.frame, CGRect(x: 0, y: 0, width: 160, height: 100))

        label = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as! LabelBrickCell
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

        let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CollectionBrickCell
        XCTAssertNotNil(cell)

        let label = cell!.brickCollectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? LabelBrickCell
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

        var cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CollectionBrickCell
        XCTAssertNil(cell)

        brickView.contentOffset.y = 1000
        brickView.layoutIfNeeded()
        cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CollectionBrickCell
        XCTAssertNotNil(cell)

        let label = cell!.brickCollectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? LabelBrickCell
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

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CollectionBrickCell
        XCTAssertNotNil(cell1)

        let label1 = cell1!.brickCollectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? LabelBrickCell
        XCTAssertNotNil(label1)

        XCTAssertEqual(label1!.label.text, "A")

        let cell2 = brickView.cellForItem(at: IndexPath(item: 2, section: 1)) as? CollectionBrickCell
        XCTAssertNotNil(cell2)

        let label2 = cell2!.brickCollectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? LabelBrickCell
        XCTAssertNotNil(label2)

        XCTAssertEqual(label2!.label.text, "B")

    }

    // Mark: - Invalidate while sticky

    func testInvalidateWhileSticky() {
        brickView.registerBrickClass(DummyBrick.self)
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
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
        
        let fixedStickyLayout = FixedStickyLayoutBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 1)])
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: [DummyBrickIdentifier: 30])
        section.repeatCountDataSource = repeatCountDataSource
        let sticky = StickyLayoutBehavior(dataSource: fixedStickyLayout)
        brickView.layout.behaviors.insert(sticky)

        brickView.setSection(section)
        brickView.layoutSubviews()

        brickView.contentOffset.y += brickView.frame.size.height
        brickView.collectionViewLayout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))
        brickView.layoutIfNeeded()

        let cell1 = brickView.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell1?.frame.origin.y, 50)
        let cell2 = brickView.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 0, y: brickView.contentOffset.y, width: 320, height: 50))
    }

    // Mark: - Shouldn't crash
    func testShouldNotCrashOnReloadBricks() {
        // we should check if the indexpath exists before adding it...
        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            BrickSection("Section", bricks: [
                DummyBrick("Item", width: .ratio(ratio: 1/2), height: .fixed(size: 38)),
                ], inset: 5, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)),
            ])

        let repeatCount = FixedRepeatCountDataSource(repeatCountHash: ["Item": 0])
        section.repeatCountDataSource = repeatCount
        
        brickView.setSection(section)
        brickView.layoutSubviews()

        var expectation: XCTestExpectation!

        repeatCount.repeatCountHash["Item"] = 30
        expectation = self.expectation(description: "Invalidate bricks")
        brickView.invalidateBricks { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        repeatCount.repeatCountHash["Item"] = 0
        expectation = self.expectation(description: "Invalidate bricks")
        brickView.invalidateBricks { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testThatInvalidateRepeatCountsSetCorrectIdentifiers() {
        let section = BrickSection(bricks: [
            DummyBrick("Brick1", height: .fixed(size: 50)),
            DummyBrick("Brick2", height: .fixed(size: 50))
            ])
        let repeatCount = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 1])
        section.repeatCountDataSource = repeatCount
        brickView.setupSectionAndLayout(section)

        repeatCount.repeatCountHash = ["Brick1": 2]
        let expecation = expectation(description: "Invalidate Repeat Counts")

        brickView.invalidateRepeatCounts(reloadAllSections: false) { (completed, insertedIndexPaths, deletedIndexPaths) in
            expecation.fulfill()
        }


        waitForExpectations(timeout: 5, handler: nil)

        let attributes = brickView.layout.layoutAttributesForItem(at: IndexPath(item: 1, section: 1)) as? BrickLayoutAttributes
        XCTAssertEqual(attributes?.identifier, "Brick1")
    }

    func testThatInvalidateRepeatCountsHasCorrectValues() {
        continueAfterFailure = true
        
        let repeatDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick2": 1])
        let section = BrickSection(bricks: [
            LabelBrick("Brick1", height: .fixed(size: 50), text: "Label 1"),
            LabelBrick("Brick2", height: .fixed(size: 10), text: "Label 2"),
            LabelBrick("Brick3", height: .fixed(size: 50), text: "Label 3"),
            ])
        section.repeatCountDataSource = repeatDataSource
        brickView.setupSectionAndLayout(section)
        
        repeatDataSource.repeatCountHash = ["Brick2": 3]
        let invalidateVisibilityExpectation = expectation(description: "Wait for invalidateVisibility")
        brickView.invalidateRepeatCounts(reloadAllSections: true) { (completed, insertedIndexPaths, deletedIndexPaths) in
            invalidateVisibilityExpectation.fulfill()
        }
        waitForExpectations(timeout:  5, handler: nil)
        brickView.layoutIfNeeded()
        
        XCTAssertEqual(brickView.cellForItem(at: IndexPath(item: 0, section: 1))?.frame.height, 50)
        XCTAssertEqual(brickView.cellForItem(at: IndexPath(item: 1, section: 1))?.frame.height, 10)
        XCTAssertEqual(brickView.cellForItem(at: IndexPath(item: 2, section: 1))?.frame.height, 10)
        XCTAssertEqual(brickView.cellForItem(at: IndexPath(item: 3, section: 1))?.frame.height, 10)
        XCTAssertEqual(brickView.cellForItem(at: IndexPath(item: 4, section: 1))?.frame.height, 50)
    }
}

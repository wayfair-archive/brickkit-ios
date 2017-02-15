//
//  BrickCollectionViewTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickCollectionViewTests: XCTestCase {

    var brickView: BrickCollectionView!

    override func setUp() {
        super.setUp()

        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    func testSetWrongCollectionViewLayout() {
        expectFatalError("BrickCollectionView: the layout needs to be of type `BrickLayout`") {
            self.brickView.collectionViewLayout = UICollectionViewFlowLayout()
        }
    }

    func testDeinit() {
        if isRunningOnA32BitDevice { // Ignoring iPhone 5 or lower for now
            return
        }

        brickView = CustomBrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        expectation(forNotification: "CustomBrickCollectionView.deinit", object: nil, handler: nil)
        brickView = nil
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNil(brickView)
    }

    func testDeinitWithBehaviors() {
        if isRunningOnA32BitDevice { // Ignoring iPhone 5 or lower for now
            return
        }

        brickView = CustomBrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let snapBehavior = SetZIndexLayoutBehavior(dataSource: FixedSetZIndexLayoutBehaviorDataSource(indexPaths: [:]))
        brickView.layout.behaviors = [snapBehavior]
        expectation(forNotification: "CustomBrickCollectionView.deinit", object: nil, handler: nil)
        brickView = nil
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNil(brickView)
    }

    func testRegisterBrickWithNib() {
        brickView.setupSectionAndLayout(BrickSection(bricks: [
            DummyBrick()
            ]))

        let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? DummyBrickCell
        XCTAssertNotNil(cell)
    }
    
    
    func testRegisterBrickWithDefaultNib() {
        brickView.registerBrickClass(LabelBrick.self, nib: LabelBrickNibs.Button)
        
        brickView.setSection(BrickSection(bricks: [
            LabelBrick(text: "TEST")
        ]))
        
        brickView.layoutSubviews()
        
        let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? LabelBrickCell
        XCTAssertNotNil(cell)
        XCTAssertNotNil(cell?.button)
    }

    func testRegisterBrickWithClass() {
        brickView.registerBrickClass(DummyBrickWithoutNib.self)
        brickView.setupSectionAndLayout(BrickSection(bricks: [
            DummyBrickWithoutNib()
            ]))

        let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? DummyBrickWithoutNibCell
        XCTAssertNotNil(cell)
    }

    func testRegisterBrickNoNibOrClass() {
        expectFatalError("Nib or cell class not found") {
            self.brickView.registerBrickClass(DummyBrickWithNoNib.self)
        }
    }

    func testBrickInfo() {
        brickView.setupSectionAndLayout(BrickSection(bricks: [
            DummyBrick("Brick1")
            ]))

        let brickInfo = brickView.brickInfo(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(brickInfo.brick.identifier, "Brick1")
        XCTAssertEqual(brickInfo.index, 0)
        XCTAssertEqual(brickInfo.collectionIndex, 0)
    }

    func testBrickInfoRepeatCount() {
        brickView.registerBrickClass(DummyBrick.self)
        let section = BrickSection(bricks: [
            DummyBrick("Brick1"),
            DummyBrick("Brick2"),
            ])
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 5, "Brick2": 5])
        section.repeatCountDataSource = repeatCountDataSource
        brickView.setSection(section)

        let brickInfo1 = brickView.brickInfo(at: IndexPath(item: 3, section: 1))
        XCTAssertEqual(brickInfo1.brick.identifier, "Brick1")
        XCTAssertEqual(brickInfo1.index, 3)
        XCTAssertEqual(brickInfo1.collectionIndex, 0)

        let brickInfo2 = brickView.brickInfo(at: IndexPath(item: 8, section: 1))
        XCTAssertEqual(brickInfo2.brick.identifier, "Brick2")
        XCTAssertEqual(brickInfo2.index, 3)
        XCTAssertEqual(brickInfo2.collectionIndex, 0)
    }

    func testBrickInfoCollectionBrick() {
        let collectionSection = BrickSection(bricks: [
            DummyBrick("Brick1")
            ])

        let collectionBrickCellModel = CollectionBrickCellModel(section: collectionSection) { cell in
            cell.brickCollectionView.registerBrickClass(DummyBrick.self)
        }
        
        let section = BrickSection(bricks: [
            CollectionBrick("CollectionBrick", dataSource: collectionBrickCellModel)
            ])

        brickView.setupSectionAndLayout(section)

        let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CollectionBrickCell
        let collectionBrickView = cell!.brickCollectionView

        let brickInfo = collectionBrickView?.brickInfo(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(brickInfo?.brick.identifier, "Brick1")
        XCTAssertEqual(brickInfo?.index, 0)
        XCTAssertEqual(brickInfo?.collectionIndex, 0)
        XCTAssertEqual(brickInfo?.collectionIdentifier, "CollectionBrick")
    }

    func testBrickInfoCollectionBrickRepeatCount() {

        let collectionSection = BrickSection(bricks: [
            DummyBrick("Brick1", height: .fixed(size: 10))
            ])

        let collectionBrickCellModel = CollectionBrickCellModel(section: collectionSection) { cell in
            cell.brickCollectionView.registerBrickClass(DummyBrick.self)
        }

        let section = BrickSection(bricks: [
            CollectionBrick("CollectionBrick", dataSource: collectionBrickCellModel)
            ])
        
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["CollectionBrick": 5])
        section.repeatCountDataSource = repeatCountDataSource

        brickView.setupSectionAndLayout(section)

        let cell = brickView.cellForItem(at: IndexPath(item: 3, section: 1)) as? CollectionBrickCell
        let collectionBrickView = cell!.brickCollectionView

        let brickInfo = collectionBrickView?.brickInfo(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(brickInfo?.brick.identifier, "Brick1")
        XCTAssertEqual(brickInfo?.index, 0)
        XCTAssertEqual(brickInfo?.collectionIndex, 3)
        XCTAssertEqual(brickInfo?.collectionIdentifier, "CollectionBrick")
    }

    func testIndexPathsForBricksWithIdentifier() {
        let section = BrickSection("Section1", bricks: [
            DummyBrick("Brick1"),
            BrickSection("Section2", bricks: [
                DummyBrick("Brick1"),
                DummyBrick("Brick2")
                ])
            ])
        brickView.setupSectionAndLayout(section)
        XCTAssertEqual(brickView.indexPathsForBricksWithIdentifier("Section1"), [IndexPath(item: 0, section: 0)])
        XCTAssertEqual(brickView.indexPathsForBricksWithIdentifier("Section2"), [IndexPath(item: 1, section: 1)])
        XCTAssertEqual(brickView.indexPathsForBricksWithIdentifier("Brick1"), [IndexPath(item: 0, section: 1), IndexPath(item: 0, section: 2)])
        XCTAssertEqual(brickView.indexPathsForBricksWithIdentifier("Brick2"), [IndexPath(item: 1, section: 2)])
        XCTAssertEqual(brickView.indexPathsForBricksWithIdentifier("Brick3"), [])
    }

    func testFatalErrorForBrickInfo() {
        brickView.setupSectionAndLayout(BrickSection(bricks: [ DummyBrick() ]))

        let indexPath = IndexPath(item: 1, section: 1)
        expectFatalError("Brick and index not found at indexPath: SECTION - \((indexPath as IndexPath).section) - ITEM: \((indexPath as NSIndexPath).item). This should never happen") {
            _ = self.brickView.brickInfo(at: indexPath)
        }
    }

    func testReloadBricks() {
        let brick = DummyBrick(width: .ratio(ratio: 1/10))
        let section = BrickSection(bricks: [
            brick
            ])
        brickView.setupSectionAndLayout(section)

        var cell: DummyBrickCell?
        cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? DummyBrickCell
        XCTAssertEqual(cell?.frame.width, 32)
        XCTAssertEqual(cell?.frame.height, 64)
        
        brick.width = .ratio(ratio: 1/5)

        let expectation = self.expectation(description: "Invalidate Bricks")

        brickView.invalidateBricks() { completed in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 500, handler: nil)

        brickView.layoutSubviews()

        cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? DummyBrickCell
        cell?.layoutIfNeeded()
        XCTAssertEqual(cell?.frame.width, 64)
        XCTAssertEqual(cell?.frame.height, 128)
    }

    func testReloadBricksWithBehaviors() {
        let offsetDataSource = FixedMultipleOffsetLayoutBehaviorDataSource(originOffsets: ["DummyBrick": CGSize(width: 10, height: 10)], sizeOffsets: nil)
        brickView.layout.behaviors.insert(OffsetLayoutBehavior(dataSource: offsetDataSource))

        let brick = DummyBrick("DummyBrick")
        let section = BrickSection(bricks: [
            brick
            ])
        brickView.setupSectionAndLayout(section)

        var cell: DummyBrickCell?
        cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? DummyBrickCell
        XCTAssertEqual(cell?.frame.origin.x, 10)
        XCTAssertEqual(cell?.frame.origin.y, 10)

        offsetDataSource.originOffsets?["DummyBrick"]?.width = 100
        offsetDataSource.originOffsets?["DummyBrick"]?.height = 100

        let expectation = self.expectation(description: "Invalidate Bricks")

        brickView.invalidateBricks() { completed in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        brickView.layoutIfNeeded()

        cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? DummyBrickCell
        XCTAssertEqual(cell?.frame.origin.x, 100)
        XCTAssertEqual(cell?.frame.origin.y, 100)
    }

    func testCustomBrickWithSameIdentifier() {
        brickView.registerNib(UINib(nibName: "DummyBrick100", bundle: DummyBrick.bundle), forBrickWithIdentifier: "DummyBrick")

        let section = BrickSection(bricks: [
            DummyBrick("DummyBrick")
            ]
        )
        brickView.setupSectionAndLayout(section)

        let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? DummyBrickCell
        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))
    }

    func testCalculateSectionThatDoesntExist() {

        let section = BrickSection(bricks: [
            DummyBrick("DummyBrick")
            ]
        )
        brickView.setupSectionAndLayout(section)

        expectFatalError {
            let flow = self.brickView.collectionViewLayout as! BrickFlowLayout
            flow.calculateSection(for: 5, with: nil, containedInWidth: 0, at: CGPoint.zero)
        }
    }

    func testInvalidateRepeatCountForCollectionBrick() {
        let collectionSection = BrickSection(bricks: [
            DummyBrick("Brick1", height: .fixed(size: 10))
            ])
        let fixed = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 0])
        collectionSection.repeatCountDataSource = fixed

        let collectionBrickCellModel = CollectionBrickCellModel(section: collectionSection) { cell in
            cell.brickCollectionView.registerBrickClass(DummyBrick.self)
        }

        let section = BrickSection(bricks: [
            CollectionBrick("CollectionBrick", dataSource: collectionBrickCellModel)
            ])

        brickView.setupSectionAndLayout(section)

        var cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CollectionBrickCell
        XCTAssertEqual(cell?.frame.height ?? 0, 0) //iOS9 and iOS10 have different behaviors, hence this code style to support both

        fixed.repeatCountHash["Brick1"] = 10
        let expectation = self.expectation(description: "")

        brickView.reloadBricksWithIdentifiers(["CollectionBrick"], shouldReloadCell: true) { completed in
            expectation.fulfill()
            }
        waitForExpectations(timeout: 5, handler: nil)
        brickView.layoutSubviews()

        cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CollectionBrickCell
        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))
    }

    func testRepeatCountMakesLabelGoTooBig() {
        let section = BrickSection("Section", bricks: [
            BrickSection("RepeatSection", bricks: [
                LabelBrick("BrickIdentifiers.repeatLabel", width: .ratio(ratio: 0.5), height: .auto(estimate: .fixed(size: 50)), text: "BRICK")
                ]),
            LabelBrick("BrickIdentifiers.titleLabel", text: "TITLE"),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        let fixed = FixedRepeatCountDataSource(repeatCountHash: ["BrickIdentifiers.repeatLabel": 1])
        section.repeatCountDataSource = fixed

        brickView.setupSectionAndLayout(section)

        var cell = brickView.cellForItem(at: IndexPath(item: 1, section: 1))

        XCTAssertEqualWithAccuracy(cell?.frame.height ?? 0, 16.5, accuracy:  0.5)

        fixed.repeatCountHash = ["BrickIdentifiers.repeatLabel": 2]

        brickView.invalidateRepeatCounts(reloadAllSections: true)
        brickView.layoutIfNeeded()

        cell = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqualWithAccuracy(cell?.frame.height ?? 0, 16.5, accuracy:  0.5)
        
        fixed.repeatCountHash = ["BrickIdentifiers.repeatLabel": 1]

        brickView.invalidateRepeatCounts(reloadAllSections: true)
        brickView.layoutIfNeeded()

        cell = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqualWithAccuracy(cell?.frame.height ?? 0, 16.5, accuracy:  0.5)
        
    }

    func testWithImageInCollectionBrick() {
        let image: UIImage = UIImage(named: "image0", in: Bundle(for: self.classForCoder), compatibleWith: nil)!

        let section1 = BrickSection(bricks: [
            ImageBrick(width: .ratio(ratio: 1/4), height: .ratio(ratio: 1), dataSource: ImageBrickModel(image: image, contentMode: .scaleAspectFill)),
            ])

        let section = BrickSection(backgroundColor: UIColor.white, bricks: [
            CollectionBrick("Collection 1", backgroundColor: UIColor.orange, scrollDirection: .horizontal, dataSource: CollectionBrickCellModel(section: section1), brickTypes: [ImageBrick.self]),
            ])
        brickView.setupSectionAndLayout(section)

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 80))
    }

    func testWithImagesInCollectionBrick() {
        let image: UIImage = UIImage(named: "image0", in: Bundle(for: self.classForCoder), compatibleWith: nil)!

        let section1 = BrickSection(bricks: [
            ImageBrick(width: .ratio(ratio: 1/4), height: .ratio(ratio: 1), dataSource: ImageBrickModel(image: image, contentMode: .scaleAspectFill)),
            ])

        let section2 = BrickSection(bricks: [
            ImageBrick(width: .ratio(ratio: 1/2), height: .ratio(ratio: 1), dataSource: ImageBrickModel(image: image, contentMode: .scaleAspectFill)),
            ])

        let section = BrickSection(backgroundColor: UIColor.white, bricks: [
            CollectionBrick("Collection 1", backgroundColor: UIColor.orange, scrollDirection: .horizontal, dataSource: CollectionBrickCellModel(section: section1), brickTypes: [ImageBrick.self]),
            CollectionBrick("Collection 2", backgroundColor: UIColor.orange, scrollDirection: .horizontal, dataSource: CollectionBrickCellModel(section: section2), brickTypes: [ImageBrick.self]),
            ])
        brickView.setupSectionAndLayout(section)

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 80))
        let cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 0, y: 80, width: 320, height: 160))
    }

    func testThatBricksBelowABrickThatShrunkAreOnTheRightYOrigin() {
        let brick = DummyBrick("resizeBrick", height: .fixed(size: 150))
        let section = BrickSection("TestSection", bricks:[
            brick,
            DummyBrick("secondBrick", height: .fixed(size: 25))
            ])
        brickView.setupSectionAndLayout(section)

        var height = brickView.contentSize.height
        XCTAssertEqual(height, 175)
        var cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 150))
        var cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 0, y: 150, width: 320, height: 25))

        brick.height = .fixed(size: 100)
        let expectation = self.expectation(description: "")

        brickView.invalidateBricks { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
        brickView.layoutIfNeeded()

        height = brickView.contentSize.height
        XCTAssertEqual(height, 125)

        cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))
        cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 0, y: 100, width: 320, height: 25))
    }

    func testThatBricksBelowABrickThatShrunkAreOnTheRightYOriginFromSecondBrick() {
        let brick = DummyBrick("resizeBrick", height: .fixed(size: 150))
        let section = BrickSection("TestSection", bricks:[
            DummyBrick("secondBrick", height: .fixed(size: 25)),
            brick,
            DummyBrick("secondBrick", height: .fixed(size: 25))
            ])
        brickView.setupSectionAndLayout(section)

        var height = brickView.contentSize.height
        XCTAssertEqual(height, 200)
        var cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 25))
        var cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 0, y: 25, width: 320, height: 150))
        var cell3 = brickView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 0, y: 175, width: 320, height: 25))

        brick.height = .fixed(size: 100)
        let expectation = self.expectation(description: "")

        brickView.invalidateBricks { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
        brickView.layoutIfNeeded()

        height = brickView.contentSize.height
        XCTAssertEqual(height, 150)

        cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 25))
        cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 0, y: 25, width: 320, height: 100))
        cell3 = brickView.cellForItem(at: IndexPath(item: 2, section: 1))
        XCTAssertEqual(cell3?.frame, CGRect(x: 0, y: 125, width: 320, height: 25))
    }

    func testThatFillBrickDimensionIgnoresEdgeInsets() {
        let section = BrickSection("TestSection", bricks:[
            DummyBrick(width: .fixed(size: 50), height: .fixed(size: 25)),
            DummyBrick(width: .fill, height: .fixed(size: 25))
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        brickView.setupSectionAndLayout(section)

        var cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 50, height: 25))
        var cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 65, y: 10, width: 245, height: 25))

        // Rotate

        brickView.frame.size = CGSize(width: 480, height: 320)
        let expectation = self.expectation(description: "")

        brickView.invalidateBricks { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)

        cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 50, height: 25))
        cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 65, y: 10, width: 405, height: 25))
    }

    func testThatSingleFillBrickDimensionIsFullWidth() {
        let section = BrickSection(bricks:[
            DummyBrick(width: .fill, height: .fixed(size: 25))
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        brickView.setupSectionAndLayout(section)

        var cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 300, height: 25))

        // Rotate

        brickView.frame.size = CGSize(width: 480, height: 320)
        let expectation = self.expectation(description: "")

        brickView.invalidateBricks { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)

        cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 460, height: 25))
    }

    func testThatFullWidthFillAsSecondDoesntCrash() {
        let section = BrickSection("TestSection", bricks:[
            DummyBrick(height: .fixed(size: 25)),
            DummyBrick(width: .fill, height: .fixed(size: 25))
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        brickView.setupSectionAndLayout(section)

        var cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 300, height: 25))
        var cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 10, y: 40, width: 300, height: 25))

        // Rotate

        brickView.frame.size = CGSize(width: 480, height: 320)
        let expectation = self.expectation(description: "")

        brickView.invalidateBricks { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)

        cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 460, height: 25))
        cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        XCTAssertEqual(cell2?.frame, CGRect(x: 10, y: 40, width: 460, height: 25))
    }

    func testThatFillInSectionTakesOriginIntoAccount() {
        let section = BrickSection("TestSection", bricks:[
            BrickSection(bricks: [
                DummyBrick(width: .fixed(size: 50), height: .fixed(size: 25)),
                DummyBrick(width: .fill, height: .fixed(size: 25))
                ])
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        brickView.setupSectionAndLayout(section)

        var cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 50, height: 25))
        var cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 2))
        XCTAssertEqual(cell2?.frame, CGRect(x: 60, y: 10, width: 250, height: 25))

        // Rotate

        brickView.frame.size = CGSize(width: 480, height: 320)
        let expectation = self.expectation(description: "")

        brickView.invalidateBricks { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)

        cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(cell1?.frame, CGRect(x: 10, y: 10, width: 50, height: 25))
        cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 2))
        XCTAssertEqual(cell2?.frame, CGRect(x: 60, y: 10, width: 410, height: 25))
    }
    
    func testThatDescriptionIsCorrect() {
        XCTAssertTrue(self.brickView.description.hasSuffix("CollectionBrick: false"))
    }

    func testThatDescriptionIsCorrectWithCollectionBrick() {
        let section = BrickSection(bricks: [
            CollectionBrick(dataSource: CollectionBrickCellModel(section: BrickSection(bricks:[DummyBrick()])), brickTypes: [DummyBrick.self])
            ])
        brickView.setupSectionAndLayout(section)
        let collectionBrickCell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CollectionBrickCell
        XCTAssertEqual(collectionBrickCell?.brickCollectionView.description.hasSuffix("CollectionBrick: true"), true)
    }

    func testThatGettingInvalidLayoutAttributesReturnRightValue() {
        XCTAssertNil(brickView.layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 1)))
    }

    func testThatRepeatCountGetsUpdatedWithReloadBricks() {
        let brick = DummyBrick("Brick", width: .fixed(size: 100), height: .fixed(size: 50))
        let section = BrickSection(bricks: [
            brick
            ])
        let repeatDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick": 1])
        section.repeatCountDataSource = repeatDataSource
        brickView.setupSectionAndLayout(section)

        XCTAssertNotNil(brickView.cellForItem(at: IndexPath(item: 0, section: 1)))
        XCTAssertNil(brickView.cellForItem(at: IndexPath(item: 1, section: 1)))

        repeatDataSource.repeatCountHash = ["Brick": 2]
        let expectation = self.expectation(description: "Invalidate Bricks")
        brickView.invalidateBricks() { (completed) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(brickView.cellForItem(at: IndexPath(item: 0, section: 1)))
        XCTAssertNotNil(brickView.cellForItem(at: IndexPath(item: 1, section: 1)))
    }

}

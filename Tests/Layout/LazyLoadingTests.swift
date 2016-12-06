//
//  LazyLoadingTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/26/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class LazyLoadingTests: XCTestCase {
    let BrickIdentifier = "Brick"
    var brickView: BrickCollectionView!
    var repeatCountDataSource: FixedRepeatCountDataSource!
    var repeatBrick: Brick!

    var flowLayout: BrickFlowLayout {
        return brickView.layout 
    }
    
    override func setUp() {
        super.setUp()
        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    func setupSection(repeatCount: Int = 100, widthRatio: CGFloat = 1, height: CGFloat = 100) {
        brickView.registerBrickClass(DummyBrick.self)

        repeatBrick = DummyBrick(BrickIdentifier, width: .Ratio(ratio: widthRatio), height: .Fixed(size: height))
        let section = BrickSection(bricks: [
            repeatBrick
            ])
        repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: [BrickIdentifier: repeatCount])
        section.repeatCountDataSource = repeatCountDataSource

        brickView.setSection(section)
    }

    func testFrameOfInterest() {
        setupSection()

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 500))
        XCTAssertEqual(flowLayout.frameOfInterest, CGRect(x: 0, y: 0, width: 320, height: 500))
        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 500, width: 320, height: 500))
        XCTAssertEqual(flowLayout.frameOfInterest, CGRect(x: 0, y: 0, width: 320, height: 1000))
        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 20000, width: 320, height: 500))
        XCTAssertEqual(flowLayout.frameOfInterest, CGRect(x: 0, y: 0, width: 320, height: 20500))
    }
    
    func testThatContentSizeIsSetCorrectly() {
        setupSection()

        brickView.layoutSubviews()

        XCTAssertEqualWithAccuracy(brickView.contentSize, CGSize(width: 320, height: 10000), accuracy: CGSize(width: 0.01, height: 0.01))
    }
    
    func testThatOnlyNecessaryAttributesAreCreated() {
        setupSection()

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 500))
        XCTAssertEqual(flowLayout.sections![1]!.attributes.count, 5)
        XCTAssertEqual(flowLayout.sections![1]!.frame, CGRect(x: 0, y: 0, width: 320, height: 10000))
    }

    func testThatOnlyNecessaryAttributesAreCreatedAndOrigin() {
        brickView.registerBrickClass(DummyBrick.self)

        repeatBrick = DummyBrick(BrickIdentifier, height: .Fixed(size: 100))
        let section = BrickSection(bricks: [
            DummyBrick(height: .Fixed(size: 20)),
            BrickSection(bricks: [repeatBrick])
            ])
        repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: [BrickIdentifier: 100])
        section.repeatCountDataSource = repeatCountDataSource

        brickView.setSection(section)

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 500))
        XCTAssertEqual(flowLayout.sections![2]!.attributes.count, 5)
        XCTAssertEqual(flowLayout.sections![2]!.frame, CGRect(x: 0, y: 20, width: 320, height: 10000))
    }

    func testThatOnlyNecessaryAttributesAreCreatedTwoBy() {
        setupSection(widthRatio: 1/2)

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 500))
        XCTAssertEqual(flowLayout.sections![1]!.attributes.count, 10)
        XCTAssertEqual(flowLayout.sections![1]!.frame, CGRect(x: 0, y: 0, width: 320, height: 5000))
    }

    func testThatOnlyNecessaryAttributesAreCreatedWithInsets() {
        setupSection()
        brickView.section.inset = 10
        brickView.section.edgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 500))
        XCTAssertEqual(flowLayout.sections![1]!.frame, CGRect(x: 0, y: 0, width: 320, height: 11000))

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 11000))
        XCTAssertEqual(flowLayout.sections![1]!.frame, CGRect(x: 0, y: 0, width: 320, height: 11000))
    }

    func testThatOnlyNecessaryAttributesAreCreatedWithInsetsTwoBy() {
        setupSection(widthRatio: 1/2)
        brickView.section.inset = 10
        brickView.section.edgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 500))
        XCTAssertEqual(flowLayout.sections![1]!.frame, CGRect(x: 0, y: 0, width: 320, height: 5520))

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 5520))
        XCTAssertEqual(flowLayout.sections![1]!.frame, CGRect(x: 0, y: 0, width: 320, height: 5520))
    }

    func testThatOnlyNecessaryAttributesAreCreatedWithInsetsTwoByAndUneven() {
        setupSection(99, widthRatio: 1/2)
        brickView.section.inset = 10
        brickView.section.edgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 500))
        XCTAssertEqual(flowLayout.sections![1]!.frame, CGRect(x: 0, y: 0, width: 320, height: 5465))

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 5520))
        XCTAssertEqual(flowLayout.sections![1]!.frame, CGRect(x: 0, y: 0, width: 320, height: 5520))
    }

    func testThatOnlyNecessaryAttributesAreCreatedWhenScrolling() {
        setupSection()
        
        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 500))
        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 500, width: 320, height: 500))
        XCTAssertEqual(flowLayout.sections![1]!.attributes.count, 10)
        XCTAssertEqual(flowLayout.sections![1]!.frame, CGRect(x: 0, y: 0, width: 320, height: 10000))
    }

    func testThatAlignRowHeightsWorksProperly() {
        setupSection()
        brickView.section.inset = 10
        brickView.section.alignRowHeights = true

        let attributes = brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 500))?.sort({$0.0.indexPath.item < $0.1.indexPath.item})
        let lastAttributes = attributes?.last
        XCTAssertEqual(lastAttributes?.frame, CGRect(x: 0.0, y: 440.0, width: 320.0, height: 100.0))
    }

}

extension LazyLoadingTests {

    func testThatStickyFooterWorksWithLazyLoading() {
        setupSection()
        let stickyDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 99, inSection: 1)])
        let stickyFooter = StickyFooterLayoutBehavior(dataSource: stickyDataSource)
        flowLayout.behaviors.insert(stickyFooter)

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 500))
        XCTAssertEqual(flowLayout.sections![1]!.frame, CGRect(x: 0, y: 0, width: 320, height: 10000))
        XCTAssertNotNil(flowLayout.sections![1]!.attributes[99])
        XCTAssertEqual(flowLayout.sections?[1]?.attributes[99]?.frame, CGRect(x: 0, y: 380, width: 320, height: 100))
    }

    func testFrameOfInterestWithStickyFooter() {
        let count = 1000
        setupSection(count, height: 50)

        let stickyIndexPath = NSIndexPath(forItem: count-1, inSection: 1)
        let footerDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [stickyIndexPath])
        let footerBehavior = StickyFooterLayoutBehavior(dataSource: footerDataSource)
        brickView.layout.behaviors.insert(footerBehavior)

        brickView.layoutSubviews()

        XCTAssertTrue(flowLayout.downStreamBehaviorIndexPaths[1]!.contains(stickyIndexPath))
        XCTAssertEqual(footerBehavior.stickyAttributes.count, 1)
        
        let cell = brickView.cellForItemAtIndexPath(stickyIndexPath)
        XCTAssertNotNil(cell)
        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: 430, width: 320, height: 50))
    }

    func testFrameOfInterestWithStickyFooterSection() {
        let repeatCount = 1000
        let height: CGFloat = 50

        brickView.registerBrickClass(DummyBrick.self)

        repeatBrick = DummyBrick(BrickIdentifier, height: .Fixed(size: height))
        let section = BrickSection(bricks: [
            BrickSection(bricks: [repeatBrick]),
            BrickSection(bricks: [repeatBrick])
            ])
        repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: [BrickIdentifier: repeatCount])
        section.repeatCountDataSource = repeatCountDataSource

        let stickyIndexPath = NSIndexPath(forItem: repeatCount-1, inSection: 3)
        let footerDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [stickyIndexPath])
        brickView.layout.behaviors.insert(StickyFooterLayoutBehavior(dataSource: footerDataSource))

        brickView.setSection(section)
        brickView.layoutSubviews()

        while brickView.contentOffset.y < CGFloat(repeatCount * 50)  {
            brickView.contentOffset.y += brickView.frame.size.height
            brickView.layoutIfNeeded()
        }

        let attributes = flowLayout.layoutAttributesForItemAtIndexPath(stickyIndexPath) as? BrickLayoutAttributes
        let count = flowLayout.sections![3]!.attributes.count - 1
        let originY = CGFloat(repeatCount + count) * 50
        XCTAssertEqual(attributes?.originalFrame.origin.y, originY)

        let cell = brickView.cellForItemAtIndexPath(stickyIndexPath)
        XCTAssertNotNil(cell)
        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: brickView.contentOffset.y + 480 - 50, width: 320, height: 50))
    }

    func testFrameOfInterestWithStickyFooterSectionWithBricks() {
        let repeatCount = 1000
        let height: CGFloat = 50

        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                DummyBrick(BrickIdentifier, height: .Fixed(size: height))
                ]),
            BrickSection(bricks: [
                DummyBrick(BrickIdentifier, height: .Fixed(size: height)),
                BrickSection(bricks: [
                    DummyBrick(height: .Fixed(size: height))
                    ])
                ])
            ])
        repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: [BrickIdentifier: repeatCount])
        section.repeatCountDataSource = repeatCountDataSource

        let stickyIndexPath = NSIndexPath(forItem: repeatCount, inSection: 3)
        let footerDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [stickyIndexPath])
        brickView.layout.behaviors.insert(StickyFooterLayoutBehavior(dataSource: footerDataSource))

        brickView.setSection(section)
        brickView.layoutSubviews()

        while brickView.contentOffset.y < CGFloat(repeatCount * 50)  {
            brickView.contentOffset.y += brickView.frame.size.height
            brickView.layoutIfNeeded()
        }

        XCTAssertEqual(flowLayout.layoutAttributesForItemAtIndexPath(stickyIndexPath)?.frame, CGRect(x: 0, y: brickView.contentOffset.y + 480 - 50, width: 320, height: 50))
        let cell = brickView.cellForItemAtIndexPath(stickyIndexPath)
        XCTAssertNotNil(cell)
        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: brickView.contentOffset.y + 480 - 50, width: 320, height: 50))

        let brickIndexPath = NSIndexPath(forItem: 0, inSection: 4)
        let brickCell = brickView.cellForItemAtIndexPath(brickIndexPath)
        XCTAssertNotNil(brickCell)
        XCTAssertEqual(brickCell?.frame, CGRect(x: 0, y: brickView.contentOffset.y + 480 - 50, width: 320, height: 50))
    }

    func testFrameOfInterestWithStickyFooterSectionWithBricks2() {
        let repeatCount = 5
        let height: CGFloat = 50

        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                DummyBrick(BrickIdentifier, height: .Fixed(size: height))
                ]),
            BrickSection(bricks: [
                DummyBrick(BrickIdentifier, height: .Fixed(size: height)),
                BrickSection(bricks: [
                    DummyBrick(height: .Fixed(size: height))
                    ])
                ])
            ])
        repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: [BrickIdentifier: repeatCount])
        section.repeatCountDataSource = repeatCountDataSource

        let stickyIndexPath = NSIndexPath(forItem: repeatCount, inSection: 3)
        let footerDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [stickyIndexPath])
        brickView.layout.behaviors.insert(StickyFooterLayoutBehavior(dataSource: footerDataSource))

        brickView.setSection(section)
        brickView.layoutSubviews()

        XCTAssertEqual(flowLayout.layoutAttributesForItemAtIndexPath(stickyIndexPath)?.frame, CGRect(x: 0, y: brickView.contentOffset.y + 480 - 50, width: 320, height: 50))
        let cell = brickView.cellForItemAtIndexPath(stickyIndexPath)
        XCTAssertNotNil(cell)
        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: brickView.contentOffset.y + 480 - 50, width: 320, height: 50))
    }

    func testFrameOfInterestWithOffsetLayoutBehavior() {
        let count = 1000
        setupSection(1000, height: 50)

        let firstOffsetIndexPath = NSIndexPath(forItem: 0, inSection: 1)
        let lastOffsetIndexPath = NSIndexPath(forItem: count - 1, inSection: 1)
        let offsetDataSource = FixedOffsetLayoutBehaviorDataSource(originOffset: CGSize(width: 10, height: 10), sizeOffset: nil, indexPaths: [firstOffsetIndexPath, lastOffsetIndexPath])
        brickView.layout.behaviors.insert(OffsetLayoutBehavior(dataSource: offsetDataSource))

        brickView.layoutSubviews()

        let firstCell = brickView.cellForItemAtIndexPath(firstOffsetIndexPath)
        XCTAssertNotNil(firstCell)
        XCTAssertEqual(firstCell?.frame, CGRect(x: 10, y: 10, width: 320, height: 50))

        while brickView.contentOffset.y < CGFloat(count * 50) - brickView.frame.size.height  {
            brickView.contentOffset.y += brickView.frame.size.height
            brickView.layoutSubviews()
        }

        let lastCell = brickView.cellForItemAtIndexPath(lastOffsetIndexPath)
        XCTAssertNotNil(lastCell)
        XCTAssertEqual(lastCell?.frame, CGRect(x: 10, y: CGFloat((count-1) * 50) + 10, width: 320, height: 50))
    }

    func _testThatHorizontalScrollingCalculatesCorrectly() {
        brickView.layout.scrollDirection = .Horizontal
        setupSection()

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 5 * 320, height: 480))
        XCTAssertEqual(flowLayout.sections![1]!.attributes.count, 5)
        XCTAssertEqual(flowLayout.sections![1]!.frame, CGRect(x: 0, y: 0, width: 32000, height: 100))

    }

    func testThatHorizontalScrollingCalculatesCorrectlyWithMultipleBricks() {
        brickView.registerBrickClass(DummyBrick.self)
        brickView.layout.scrollDirection = .Horizontal
        
        let section = BrickSection(bricks: [
            DummyBrick(width: .Ratio(ratio: 1/2)),
            DummyBrick(width: .Ratio(ratio: 1/2)),
            DummyBrick(width: .Ratio(ratio: 1/2)),
            DummyBrick(width: .Ratio(ratio: 1/2)),
            DummyBrick(width: .Ratio(ratio: 1)),
            ])


        brickView.setSection(section)
        brickView.layoutSubviews()

        var x = brickView.frame.width
        while x < brickView.contentSize.width {
            brickView.contentOffset.x += brickView.frame.width
            brickView.layoutSubviews()
            x += brickView.frame.width
        }
        brickView.contentOffset.x = 0

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 960, height: 640),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 160, height: 320.0),
                CGRect(x: 160, y: 0, width: 160, height: 320.0),
                CGRect(x: 320, y: 0, width: 160, height: 320.0),
                CGRect(x: 480, y: 0, width: 160, height: 320.0),
                CGRect(x: 640, y: 0, width: 320, height: 640),
            ]
        ]



        let attributes = brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(origin: .zero, size: CGSize(width: 960, height: 640)))

        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickView.collectionViewLayout.collectionViewContentSize(), CGSize(width: 960, height: 640))
    }

    func testThatADummyCellIsReturnedIfNotYetCalculated() {
        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick("Brick"),
            ])
        let repeatCount = FixedRepeatCountDataSource(repeatCountHash: ["Brick": 100])
        section.repeatCountDataSource = repeatCount

        brickView.setSection(section)

        XCTAssertNotNil(brickView.layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)))
        XCTAssertNotNil(brickView.layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 99, inSection: 1)))
        XCTAssertNil(brickView.layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 100, inSection: 1)))
        XCTAssertNil(brickView.layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2)))
    }

    func testThatSettingHigherNumberOfItemsIsHandled() {
        setupSection()

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 5000))
        XCTAssertEqual(flowLayout.sections![1]!.attributes.count, 50)
        XCTAssertEqual(flowLayout.sections![1]!.frame, CGRect(x: 0, y: 0, width: 320, height: 10000))

        repeatCountDataSource.repeatCountHash = [BrickIdentifier: 101]
        brickView.invalidateRepeatCounts()
        XCTAssertEqual(flowLayout.sections![1]!.attributes.count, 50)
    }

    func testThatSettingLowerNumberOfItemsIsHandled() {
        setupSection()

        brickView.collectionViewLayout.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 5000))
        XCTAssertEqual(flowLayout.sections![1]!.attributes.count, 50)
        XCTAssertEqual(flowLayout.sections![1]!.frame, CGRect(x: 0, y: 0, width: 320, height: 10000))

        repeatCountDataSource.repeatCountHash = [BrickIdentifier: 99]
        brickView.invalidateRepeatCounts()
        XCTAssertEqual(flowLayout.sections![1]!.attributes.count, 50)
    }


}

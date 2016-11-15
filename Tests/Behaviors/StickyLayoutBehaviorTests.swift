//
//  StickyBehaviorTests.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/30/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class StickyLayoutBehaviorTests: BrickFlowLayoutBaseTests {
    
    func testStickyBehavior() {
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])
        let stickyBehavior = StickyLayoutBehavior(dataSource: behaviorDataSource)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        let expectedResult: [Int : [CGRect]] = [
            0 : frames
        ]

        let attributes = layout.layoutAttributesForElementsInRect(CGRect(origin: CGPoint.zero, size: layout.collectionViewContentSize()))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 2000))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        let firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 100))
    }

    func testStickyBehaviorThatIsHidden() {
        let indexPaths = [NSIndexPath(forItem: 0, inSection: 0)]
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: indexPaths)
        let stickyBehavior = StickyLayoutBehavior(dataSource: FixedStickyLayoutBehaviorDataSource(indexPaths: indexPaths))
        self.layout.behaviors.insert(stickyBehavior)
        self.layout.hideBehaviorDataSource = hideBehaviorDataSource

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<(sectionCount-1) {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        let firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertTrue(firstAttributes!.hidden)
    }

    func testStickyBehaviorWithContentInset() {
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])
        let stickyBehavior = StickyLayoutBehavior(dataSource: behaviorDataSource)
        self.layout.behaviors.insert(stickyBehavior)
        self.collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        let expectedResult: [Int : [CGRect]] = [
            0 : frames
        ]

        let attributes = layout.layoutAttributesForElementsInRect(CGRect(origin: CGPoint.zero, size: layout.collectionViewContentSize()))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 2000))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        let firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 520, width: 320, height: 100))
        
    }


    func testStickyBehaviorWhenScrolled() {
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])
        let stickyBehavior = StickyLayoutBehavior(dataSource: behaviorDataSource)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        let firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 100))
        
    }

    func testMultipleStickyBehavior() {
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0), NSIndexPath(forItem: 2, inSection: 0)])
        let stickyBehavior = StickyLayoutBehavior(dataSource: behaviorDataSource)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        let firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 100))
        let thirdAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0))
        XCTAssertEqual(thirdAttributes?.frame, CGRect(x: 0, y: 600, width: 320, height: 100))
    }
    
    func testSectionStickyBehavior() {
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 1), NSIndexPath(forItem: 0, inSection: 2)])
        let stickyBehavior = StickyLayoutBehavior(dataSource: behaviorDataSource)
        self.layout.behaviors.insert(stickyBehavior)

        setDataSources(SectionsCollectionViewDataSource(sections: [2, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1], [1, 1], [1, 1]], heights: [[0, 0], [100, 1000], [100, 1000]], types: [[.Section(sectionIndex: 1), .Section(sectionIndex: 2)], [.Brick, .Brick], [.Brick, .Brick]]))

        var firstSectionAttributes: UICollectionViewLayoutAttributes!
        var secondSectionAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: 1100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 1100
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: 1000, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: 1100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 1600
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: 1000, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: 1600, width: 320, height: 100))
    }

    func testStickingDelegateBehavior() {
        let indexPath = NSIndexPath(forItem: 1, inSection: 0)
        let stickingDelegate = FixedStickyLayoutBehaviorDelegate()
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [indexPath])
        let stickyBehavior = StickyLayoutBehavior(dataSource: behaviorDataSource, delegate: stickingDelegate)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        let expectedResult: [Int : [CGRect]] = [
            0 : frames
        ]

        let attributes = layout.layoutAttributesForElementsInRect(CGRect(origin: CGPoint.zero, size: layout.collectionViewContentSize()))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 2000))

        layout.collectionView?.contentOffset.y = 0
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        XCTAssertEqual(stickingDelegate.percentages[indexPath], 1.0)

        layout.collectionView?.contentOffset.y = 50
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        XCTAssertEqual(stickingDelegate.percentages[indexPath], 0.5)

        layout.collectionView?.contentOffset.y = 100
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        XCTAssertEqual(stickingDelegate.percentages[indexPath], 0)

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))
        
        XCTAssertEqual(stickingDelegate.percentages[indexPath], 0)
    }


    func testStickingDelegateBehaviorWithContentInset() {
        let indexPath = NSIndexPath(forItem: 1, inSection: 0)
        let stickingDelegate = FixedStickyLayoutBehaviorDelegate()
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [indexPath])
        let stickyBehavior = StickyLayoutBehavior(dataSource: behaviorDataSource, delegate: stickingDelegate)
        self.layout.behaviors.insert(stickyBehavior)

        self.collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        let expectedResult: [Int : [CGRect]] = [
            0 : frames
        ]

        let attributes = layout.layoutAttributesForElementsInRect(CGRect(origin: CGPoint.zero, size: layout.collectionViewContentSize()))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 2000))

        layout.collectionView?.contentOffset.y = 0
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        XCTAssertEqual(stickingDelegate.percentages[indexPath], 0.8)

        layout.collectionView?.contentOffset.y = 50
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        XCTAssertEqual(stickingDelegate.percentages[indexPath], 0.3)

        layout.collectionView?.contentOffset.y = 100
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        XCTAssertEqual(stickingDelegate.percentages[indexPath], 0)

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))
        
        XCTAssertEqual(stickingDelegate.percentages[indexPath], 0)
    }

    func testStickySectionWithContentInset() {
    let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])
        let stickyBehavior = StickyLayoutBehavior(dataSource: behaviorDataSource)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [1 + sectionCount, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1], [1]], heights: [[0, 100], [100]], types: [[.Section(sectionIndex: 1), .Brick], [.Brick, .Brick]]))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        frames.append(CGRect(x: 0, y: 0, width: size.width, height: 200))
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: 200 + (index * 100)), size: size))
        }

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        let groupAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(groupAttributes?.frame, CGRect(x: 0, y: 500, width: size.width, height: 200))
        let firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 500, width: size.width, height: size.height))
        let secondAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: 500 + size.height, width: size.width, height: size.height))
        
    }

    func testStickyNestedSection() {
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])
        let stickyBehavior = StickyLayoutBehavior(dataSource: behaviorDataSource)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [1 + sectionCount, 2, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1], [0.5, 0.5], [1], [1]], heights: [[0, 100], [0], [100], [100]], types: [[.Section(sectionIndex: 1), .Brick], [.Section(sectionIndex: 2), .Section(sectionIndex: 3)], [.Brick, .Brick], [.Brick, .Brick]]))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        frames.append(CGRect(x: 0, y: 0, width: size.width, height: 200))
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: 200 + (index * 100)), size: size))
        }

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        var attributes: UICollectionViewLayoutAttributes?
        attributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(attributes?.frame, CGRect(x: 0, y: 500, width: size.width, height: 200))

        attributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(attributes?.frame, CGRect(x: 0, y: 500, width: size.width / 2, height: 200))
        attributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))
        XCTAssertEqual(attributes?.frame, CGRect(x: size.width / 2, y: 500, width: size.width / 2, height: 200))

        attributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(attributes?.frame, CGRect(x: 0, y: 500, width: size.width / 2, height: 100))
        attributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 2))
        XCTAssertEqual(attributes?.frame, CGRect(x: 0, y: 600, width: size.width / 2, height: 100))

        attributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 3))
        XCTAssertEqual(attributes?.frame, CGRect(x: size.width / 2, y: 500, width: size.width / 2, height: 100))
        attributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 3))
        XCTAssertEqual(attributes?.frame, CGRect(x: size.width / 2, y: 600, width: size.width / 2, height: 100))
    }

    // This test checks if the originalFrame changes when a section is sticky
    func testStickyShouldNotChangeOriginalFrameForSectionAttributes() {
        let brickView = BrickCollectionView(frame: CGRect(x:0, y:0, width: 320, height: 480))
        brickView.registerBrickClass(DummyBrick.self)

        let brickSection = BrickSection(bricks: [
            BrickSection(bricks: [
                DummyBrick("Brick 2", height: .Fixed(size: 100)),
            ]),
            DummyBrick("Repeat", height: .Fixed(size: 100))
            ])

        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Repeat" : 100])
        brickSection.repeatCountDataSource = repeatCountDataSource
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 1)])
        let sticky = StickyLayoutBehavior(dataSource: behaviorDataSource)
        brickView.layout.behaviors.insert(sticky)

        brickView.setSection(brickSection)
        brickView.layoutSubviews()

        brickView.contentOffset.y = 480
        brickView.layoutIfNeeded()

        let attributes1 = brickView.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2)) as? BrickLayoutAttributes
        XCTAssertEqual(attributes1?.frame, CGRect(x: 0, y: 480, width: 320, height: 100))
        XCTAssertEqual(attributes1?.originalFrame, CGRect(x: 0, y: 0, width: 320, height: 100))
    }

}

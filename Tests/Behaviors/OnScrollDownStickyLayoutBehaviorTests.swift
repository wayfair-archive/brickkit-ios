//
//  OnScrollDownStickyLayoutBehaviorTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/3/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class OnScrollDownStickyLayoutBehaviorTests: BrickFlowLayoutBaseTests {

    func testOnScrollDownStickingBehavior() {
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)

        let fixedStickyLayout = FixedStickyLayoutBehaviorDataSource(indexPaths: [indexPath])
        let stickyBehavior = OnScrollDownStickyLayoutBehavior(dataSource: fixedStickyLayout)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        var firstAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 450
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 350, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 200
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 200, width: 320, height: 100))
        
        layout.collectionView?.contentOffset.y = 200
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 200, width: 320, height: 100))
    }

    func testOnScrollDownStickingSectionBehavior() {
        let fixedStickyLayout = FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 1), NSIndexPath(forItem: 0, inSection: 2)])
        let stickyBehavior = OnScrollDownStickyLayoutBehavior(dataSource: fixedStickyLayout)
        self.layout.behaviors.insert(stickyBehavior)


        setDataSources(SectionsCollectionViewDataSource(sections: [2, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1], [1, 1], [1, 1]], heights: [[0, 0], [100, 1000], [100, 1000]], types: [[.Section(sectionIndex: 1), .Section(sectionIndex: 2)], [.Brick, .Brick], [.Brick, .Brick]]))

        var firstSectionAttributes: UICollectionViewLayoutAttributes!
        var secondSectionAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: 1100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 1100
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: 1100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 1000
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: 900, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: 1100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 1600
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: 900, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: 1100, width: 320, height: 100))
    }

    func testOnScrollDownStickingBehaviorStacked() {
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        let indexPath2 = NSIndexPath(forItem: 1, inSection: 0)
        let fixedStickyLayout = FixedStickyLayoutBehaviorDataSource(indexPaths: [indexPath, indexPath2])
        let stickyBehavior = OnScrollDownStickyLayoutBehavior(dataSource: fixedStickyLayout)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        var firstAttributes: UICollectionViewLayoutAttributes!
        var secondAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath)
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath2)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: 100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 450
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath)
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath2)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 250, width: 320, height: 100))
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: 350, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 200
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath)
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath2)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 200, width: 320, height: 100))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 200, width: 320, height: 100))
    }

    func testThatOnScrollDownWorksWithBrickViewSameContentHeight() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(height: .Fixed(size: 50)),
            DummyBrick("BRICK", height: .Fixed(size: 50))
            ])
        let indexPath = NSIndexPath(forItem: 0, inSection: 1)
        let scrollDownDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [indexPath])
        let stickyBehavior = OnScrollDownStickyLayoutBehavior(dataSource: scrollDownDataSource)
        self.layout.behaviors.insert(stickyBehavior)

        let repeatDataSource = FixedRepeatCountDataSource(repeatCountHash: ["BRICK" : 100])
        section.repeatCountDataSource = repeatDataSource

        collectionView.setSection(section)
        collectionView.layoutSubviews()

        collectionView.contentOffset.y += 100
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))
        collectionView.layoutSubviews()
        collectionView.contentOffset.y -= 5
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))
        collectionView.layoutSubviews()

        collectionView.contentOffset.y -= 5
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))
        collectionView.layoutSubviews()

        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))
        collectionView.layoutSubviews()

        XCTAssertEqual(layout.layoutAttributesForItemAtIndexPath(indexPath)?.frame, CGRect(x: 0, y: 45, width: 320, height: 50))

    }
    
}

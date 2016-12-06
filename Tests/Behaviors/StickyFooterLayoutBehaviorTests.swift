//
//  StickyFooterLayoutBehaviorTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/2/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class StickyFooterLayoutBehaviorTests: BrickFlowLayoutBaseTests {

    func testStickyBehavior() {
        let sectionCount = 20

        let indexPath = NSIndexPath(forItem: sectionCount - 1, inSection: 0)
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [indexPath])
        let stickyBehavior = StickyFooterLayoutBehavior(dataSource: behaviorDataSource)
        self.layout.behaviors.insert(stickyBehavior)

        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var firstAttributes:UICollectionViewLayoutAttributes!

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 500, width: 320, height: 100))


        layout.collectionView?.contentOffset.y = 3000
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 3000, width: 320, height: 100))
    }

    func testStackedStickyBehavior() {
        let sectionCount = 20

        let indexPath1 = NSIndexPath(forItem: sectionCount - 1, inSection: 0)
        let indexPath2 = NSIndexPath(forItem: sectionCount - 2, inSection: 0)
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [indexPath1, indexPath2])
        let stickyBehavior = StickyFooterLayoutBehavior(dataSource: behaviorDataSource)
        self.layout.behaviors.insert(stickyBehavior)

        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var firstAttributes: UICollectionViewLayoutAttributes!
        var secondAttributes: UICollectionViewLayoutAttributes!

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath1)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100, width: 320, height: 100))
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath2)
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 200, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath1)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 500, width: 320, height: 100))
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath2)
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 500 - 100, width: 320, height: 100))


        layout.collectionView?.contentOffset.y = 3000
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath1)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 3000, width: 320, height: 100))
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath2)
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: (sectionCount - 2) * 100, width: 320, height: 100))

    }

    func testStickyBehaviorContentInset() {
        let sectionCount = 20
        self.collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

        let indexPath = NSIndexPath(forItem: sectionCount - 1, inSection: 0)
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [indexPath])
        let stickyBehavior = StickyFooterLayoutBehavior(dataSource: behaviorDataSource)
        self.layout.behaviors.insert(stickyBehavior)

        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var firstAttributes:UICollectionViewLayoutAttributes!

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 - 40, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 500 - 20, width: 320, height: 100))


        layout.collectionView?.contentOffset.y = 3000
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 3000 - 20, width: 320, height: 100))
    }

    func testSectionStickyBehavior() {
        let firstIndexPath = NSIndexPath(forItem: 1, inSection: 2)
        let secondIndexPath = NSIndexPath(forItem: 1, inSection: 3)
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [firstIndexPath, secondIndexPath])
        let stickyBehavior = StickyFooterLayoutBehavior(dataSource: behaviorDataSource)
        self.layout.behaviors.insert(stickyBehavior)

        setDataSources(SectionsCollectionViewDataSource(sections: [1, 2, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1], [1, 1], [1, 1], [1, 1]], heights: [[0], [0, 0], [1000, 100], [1000, 100]], types: [[.Section(sectionIndex: 1)], [.Section(sectionIndex: 2), .Section(sectionIndex: 3)], [.Brick, .Brick], [.Brick, .Brick]]))

        var firstSectionAttributes: UICollectionViewLayoutAttributes!
        var secondSectionAttributes: UICollectionViewLayoutAttributes!

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(firstIndexPath)
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItemAtIndexPath(secondIndexPath)
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: 1100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(firstIndexPath)
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 500, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItemAtIndexPath(secondIndexPath)
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: 1100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 1100
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(firstIndexPath)
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: 1000, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItemAtIndexPath(secondIndexPath)
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 1100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 1600
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(firstIndexPath)
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: 1000, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItemAtIndexPath(secondIndexPath)
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 1600, width: 320, height: 100))
    }

    func testSectionStickyBehaviorCanStackWithOtherSections() {
        let sectionCount = 20

        let indexPath1 = NSIndexPath(forItem: 1, inSection: 1)
        let indexPath2 = NSIndexPath(forItem: sectionCount - 1, inSection: 2)
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [indexPath1, indexPath2])
        let stickyBehavior = StickyFooterLayoutBehavior(dataSource: behaviorDataSource)
        stickyBehavior.canStackWithOtherSections = true
        self.layout.behaviors.insert(stickyBehavior)

        setDataSources(SectionsCollectionViewDataSource(sections: [1, 2, sectionCount]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1], [1, 1], [1]], heights: [[0], [0, 100], [100]], types: [[.Section(sectionIndex: 1)], [.Section(sectionIndex: 2), .Brick], [.Brick]]))


        var firstAttributes: UICollectionViewLayoutAttributes!
        var secondAttributes: UICollectionViewLayoutAttributes!

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath1)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100, width: 320, height: 100))
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath2)
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 200, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath1)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 500, width: 320, height: 100))
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath2)
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 500 - 100, width: 320, height: 100))


        layout.collectionView?.contentOffset.y = 3000
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath1)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 3000, width: 320, height: 100))
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(indexPath2)
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: ((sectionCount - 2) * 100) + 100, width: 320, height: 100))
    }

    func testSectionWithinSectionsStickyBehavior() {
        let sectionIndexPath = NSIndexPath(forItem: 1, inSection: 1)
        let firstIndexPath = NSIndexPath(forItem: 0, inSection: 2)
        let secondIndexPath = NSIndexPath(forItem: 1, inSection: 2)
        let behaviorDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [sectionIndexPath])
        let stickyBehavior = StickyFooterLayoutBehavior(dataSource: behaviorDataSource)
        self.layout.behaviors.insert(stickyBehavior)

        setDataSources(SectionsCollectionViewDataSource(sections: [1, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1], [1, 1], [1, 1]], heights: [[0], [1000, 0], [100, 100]], types: [[.Section(sectionIndex: 1)], [.Brick, .Section(sectionIndex: 2)], [.Brick, .Brick]]))

        var sectionAttributes: UICollectionViewLayoutAttributes!
        var firstSectionAttributes: UICollectionViewLayoutAttributes!
        var secondSectionAttributes: UICollectionViewLayoutAttributes!

        sectionAttributes = layout.layoutAttributesForItemAtIndexPath(sectionIndexPath)
        XCTAssertEqual(sectionAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 200, width: 320, height: 200))
        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(firstIndexPath)
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 200, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItemAtIndexPath(secondIndexPath)
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        sectionAttributes = layout.layoutAttributesForItemAtIndexPath(sectionIndexPath)
        XCTAssertEqual(sectionAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 200 + 500, width: 320, height: 200))
        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(firstIndexPath)
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 200 + 500, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItemAtIndexPath(secondIndexPath)
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: collectionViewFrame.height - 100 + 500, width: 320, height: 100))
    }

    func testThatFooterSectionDoesNotGrowTooLarge() {
        collectionView.layout.zIndexBehavior = .BottomUp

        collectionView.registerBrickClass(LabelBrick.self)

        let stickyDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 50, inSection: 1)])
        let behavior = StickyFooterLayoutBehavior(dataSource: stickyDataSource)
        collectionView.layout.behaviors.insert(behavior)

        let configureCellBlock: ConfigureLabelBlock  = { cell in
            cell.edgeInsets.top = 10
            cell.edgeInsets.bottom = 11
        }

        let footerSection = BrickSection("Footer", bricks: [
            LabelBrick("A", text: "Footer Title", configureCellBlock: configureCellBlock),
            LabelBrick("B", width: .Ratio(ratio: 0.5), text: "Footer Label 1", configureCellBlock: configureCellBlock),
            LabelBrick("C", width: .Ratio(ratio: 0.5), text: "Footer Label 2", configureCellBlock: configureCellBlock),
            ])

        let section = BrickSection(bricks: [
            LabelBrick("BRICK", width: .Ratio(ratio: 0.5), height: .Fixed(size: 38), text: "Brick"),
            footerSection
            ])
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["BRICK" : 50])
        section.repeatCountDataSource = repeatCountDataSource
        
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let attributes = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 50, inSection: 1))
        XCTAssertEqual(attributes?.frame, CGRect(x: 0, y: 404, width: 320, height: 76))

        let footerAttributes1 = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 2))
        XCTAssertEqual(footerAttributes1?.frame, CGRect(x: 0, y: 404, width: 320, height: 38))
        let footerAttributes2 = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 2))
        XCTAssertEqual(footerAttributes2?.frame, CGRect(x: 0, y: 442, width: 160, height: 38))
        let footerAttributes3 = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 2))
        XCTAssertEqual(footerAttributes3?.frame, CGRect(x: 160, y: 442, width: 160, height: 38))
    }

    
}

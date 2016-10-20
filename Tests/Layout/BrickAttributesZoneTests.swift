//
//  BrickAttributesZoneTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/29/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickAttributesZoneTests: BrickFlowLayoutBaseTests {

    func testVerticalZeroSize() {
        let brickZones = BrickZones(collectionViewSize: .zero, scrollDirection: .Vertical)
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 0, y: 0, width: 100, height: 100)), [])
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 0, y: 240, width: 100, height: 100)), [])
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 0, y: 380, width: 160, height: 240)), [])
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 0, y: 480, width: 160, height: 240)), [])
    }

    func testHorizontalZeroSize() {
        let brickZones = BrickZones(collectionViewSize: .zero, scrollDirection: .Horizontal)
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 0, y: 0, width: 100, height: 100)), [])
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 0, y: 240, width: 100, height: 100)), [])
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 0, y: 380, width: 160, height: 240)), [])
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 0, y: 480, width: 160, height: 240)), [])
    }

    func testCalculateZoneVertical() {
        let brickZones = BrickZones(collectionViewSize: collectionViewFrame.size, scrollDirection: .Vertical)
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 0, y: 0, width: 100, height: 100)), [0])
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 0, y: 240, width: 100, height: 100)), [0])
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 0, y: 380, width: 160, height: 240)), [0, 1])
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 0, y: 480, width: 160, height: 240)), [1])
    }

    func testCalculateZoneHorizontal() {
        let brickZones = BrickZones(collectionViewSize: collectionViewFrame.size, scrollDirection: .Horizontal)
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 0, y: 0, width: 100, height: 100)), [0])
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 160, y: 0, width: 100, height: 100)), [0])
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 220, y: 0, width: 160, height: 240)), [0, 1])
        XCTAssertEqual(brickZones.calculateZonesForFrame(CGRect(x: 320, y: 0, width: 160, height: 240)), [1])
    }

    func testSingleZone() {
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)))

        layout.calculateSectionsIfNeeded()


        XCTAssertEqual(layout.brickZones?.attributesZones.count, 1)
        XCTAssertEqual(layout.brickZones?.attributesZones.keys.first, 0)
        XCTAssertEqual(layout.brickZones?.attributesZones[0]?.count, 1)
    }

    func testBrickInTwoZones() {
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 500, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)))

        layout.calculateSectionsIfNeeded()

        XCTAssertEqual(layout.brickZones?.attributesZones.count, 2)
        XCTAssertEqual(layout.brickZones?.attributesZones[0]?.count, 1)
        XCTAssertEqual(layout.brickZones?.attributesZones[1]?.count, 1)
    }

    func testBrickInMultipleZones() {
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 2000, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)))

        layout.calculateSectionsIfNeeded()

        XCTAssertEqual(layout.brickZones?.attributesZones.count, 5)
        XCTAssertEqual(layout.brickZones?.attributesZones[0]?.count, 1)
        XCTAssertEqual(layout.brickZones?.attributesZones[1]?.count, 1)
        XCTAssertEqual(layout.brickZones?.attributesZones[2]?.count, 1)
        XCTAssertEqual(layout.brickZones?.attributesZones[3]?.count, 1)
        XCTAssertEqual(layout.brickZones?.attributesZones[4]?.count, 1)
    }

    func testBrickChangedZones() {
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)))

        layout.calculateSectionsIfNeeded()

        let firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection:0)) as! BrickLayoutAttributes
        firstAttributes.frame.origin.y += 480
        layout.brickZones?.updateZones(for: firstAttributes)

        XCTAssertEqual(layout.brickZones?.attributesZones.count, 2)
        XCTAssertEqual(layout.brickZones?.attributesZones[0]?.count, 0)
        XCTAssertEqual(layout.brickZones?.attributesZones[1]?.count, 1)
    }

    func testBrickThatIsHidden() {
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 0, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)))

        layout.calculateSectionsIfNeeded()

        var firstSectionAttributes: UICollectionViewLayoutAttributes!

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertTrue(layout.brickZones!.attributesZones.isEmpty)

        firstSectionAttributes.frame.size.height = 100
        layout.brickZones?.updateZones(for: firstSectionAttributes)

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertTrue(layout.brickZones!.attributesZones[0]!.contains(firstSectionAttributes))
    }
    
    func testBrickThatBecomesHidden() {
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)))

        layout.calculateSectionsIfNeeded()

        var firstSectionAttributes: UICollectionViewLayoutAttributes!

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertFalse(layout.brickZones!.attributesZones.isEmpty)

        firstSectionAttributes.frame.size.height = 0
        layout.brickZones?.updateZones(for: firstSectionAttributes)

        firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertFalse(layout.brickZones!.attributesZones[0]!.contains(firstSectionAttributes))
    }

    func testRemoveBrick() {
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)))

        layout.calculateSectionsIfNeeded()

        let firstSectionAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))!

        XCTAssertFalse(layout.brickZones!.attributesZones.isEmpty)

        layout.brickZones?.removeAttributes(firstSectionAttributes)

        XCTAssertNil(layout.brickZones!.attributesZones[0])
        XCTAssertTrue(layout.brickZones!.attributesZones.isEmpty)
    }

    func testBrickNotChangedZones() {
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)))

        layout.calculateSectionsIfNeeded()

        let firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection:0)) as! BrickLayoutAttributes
        firstAttributes.frame.origin.y += 5
        layout.brickZones?.updateZones(for: firstAttributes)

        XCTAssertEqual(layout.brickZones?.attributesZones.count, 1)
        XCTAssertEqual(layout.brickZones?.attributesZones[0]?.count, 1)
    }
    
    func testBrickChangedMultipleZones() {
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)))

        layout.calculateSectionsIfNeeded()

        let firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection:0)) as! BrickLayoutAttributes
        firstAttributes.frame.origin.y += 400
        layout.brickZones?.updateZones(for: firstAttributes)

        XCTAssertEqual(layout.brickZones?.attributesZones.count, 2)
        XCTAssertEqual(layout.brickZones?.attributesZones[0]?.count, 1)
        XCTAssertEqual(layout.brickZones?.attributesZones[1]?.count, 1)
    }

    func testStickyZone() {
        let stickyBehavior = StickyLayoutBehavior(dataSource: FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0)]))
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        XCTAssertEqual(layout.brickZones?.attributesZones.count, 5)

        let firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection:0))
        XCTAssertTrue(layout.brickZones!.attributesZones[0]!.contains(firstAttributes!))

        layout.collectionView?.contentOffset.y = 480
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        XCTAssertFalse(layout.brickZones!.attributesZones[0]!.contains(firstAttributes!))
        XCTAssertTrue(layout.brickZones!.attributesZones[1]!.contains(firstAttributes!))
    }

    func testStickyZoneWithSection() {
        let stickyBehavior = StickyLayoutBehavior(dataSource: FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0)]))
        self.layout.behaviors.insert(stickyBehavior)

        setDataSources(SectionsCollectionViewDataSource(sections: [2, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1], [1, 1], [1, 1]], heights: [[0, 0], [100, 480], [100, 480]], types: [[.Section(sectionIndex: 1), .Section(sectionIndex: 2)], [.Brick, .Brick], [.Brick, .Brick]]))

        XCTAssertTrue(layout.brickZones!.attributesZones[0]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))!))
        XCTAssertTrue(layout.brickZones!.attributesZones[0]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))!))

        layout.collectionView?.contentOffset.y = 280
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        XCTAssertTrue(layout.brickZones!.attributesZones[0]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))!))
        XCTAssertTrue(layout.brickZones!.attributesZones[0]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))!))
        XCTAssertTrue(layout.brickZones!.attributesZones[1]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))!))


        layout.collectionView?.contentOffset.y = 480
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        XCTAssertFalse(layout.brickZones!.attributesZones[0]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))!))
        XCTAssertFalse(layout.brickZones!.attributesZones[0]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))!))
        XCTAssertTrue(layout.brickZones!.attributesZones[1]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))!))
        XCTAssertTrue(layout.brickZones!.attributesZones[1]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))!))
    }

    func testStickyZoneWithHugeSections() {
        let stickyBehavior = StickyLayoutBehavior(dataSource: FixedStickyLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0)]))
        self.layout.behaviors.insert(stickyBehavior)

        setDataSources(SectionsCollectionViewDataSource(sections: [2, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1], [1, 1], [1, 1]], heights: [[0, 0], [100, 1000], [100, 1000]], types: [[.Section(sectionIndex: 1), .Section(sectionIndex: 2)], [.Brick, .Brick], [.Brick, .Brick]]))

        XCTAssertTrue(layout.brickZones!.attributesZones[0]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))!))
        XCTAssertTrue(layout.brickZones!.attributesZones[0]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))!))

        layout.collectionView?.contentOffset.y = 280
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        XCTAssertTrue(layout.brickZones!.attributesZones[0]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))!))
        XCTAssertTrue(layout.brickZones!.attributesZones[0]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))!))
        XCTAssertTrue(layout.brickZones!.attributesZones[1]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))!))


        layout.collectionView?.contentOffset.y = 480
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        XCTAssertFalse(layout.brickZones!.attributesZones[0]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))!))
        XCTAssertFalse(layout.brickZones!.attributesZones[0]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))!))
        XCTAssertTrue(layout.brickZones!.attributesZones[1]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))!))
        XCTAssertTrue(layout.brickZones!.attributesZones[1]!.contains(layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1))!))
    }

}

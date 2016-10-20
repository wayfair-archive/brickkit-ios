//
//  CardScrollBehaviorTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/5/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class CardLayoutBehaviorTests: BrickFlowLayoutBaseTests {
    
    var firstAttributes:UICollectionViewLayoutAttributes!
    var secondAttributes:UICollectionViewLayoutAttributes!
    var thirdAttributes:UICollectionViewLayoutAttributes!
    var fourthAttributes:UICollectionViewLayoutAttributes!
    var secondHeight:CGFloat!
    var behavior:CardLayoutBehavior!

    override func setUp() {
        super.setUp()

        layout.zIndexBehavior = .BottomUp
        
        behavior = CardLayoutBehavior(dataSource: FixedCardLayoutBehaviorDataSource(height: 100))
        behavior.scrollLastBrickToTop = false
        layout.behaviors.insert(behavior)

        let sectionCount = 4
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 300))
    }

    override func tearDown() {
        layout.behaviors.remove(behavior)
        behavior = nil

        firstAttributes = nil
        secondAttributes = nil
        thirdAttributes = nil
        secondHeight = nil

        super.tearDown()
    }

    func testCardScrollBehavior() {

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 0, width: 320, height: 300))
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0))
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: 300, width: 320, height: 300))
        thirdAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0))
        XCTAssertEqual(thirdAttributes?.frame, CGRect(x: 0, y: 400, width: 320, height: 300))
        fourthAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 3, inSection: 0))
        XCTAssertEqual(fourthAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 300))

        XCTAssertTrue(firstAttributes.zIndex < secondAttributes.zIndex)
        XCTAssertTrue(secondAttributes.zIndex < thirdAttributes.zIndex)
        XCTAssertTrue(thirdAttributes.zIndex < fourthAttributes.zIndex)
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 1200))

        layout.collectionView?.contentOffset.y = 100
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 100, width: 320, height: 300))
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0))
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: 300, width: 320, height: 300))
        thirdAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0))
        XCTAssertEqual(thirdAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 300))
        fourthAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 3, inSection: 0))
        XCTAssertEqual(fourthAttributes?.frame, CGRect(x: 0, y: 600, width: 320, height: 300))

        XCTAssertTrue(firstAttributes.zIndex < secondAttributes.zIndex)
        XCTAssertTrue(secondAttributes.zIndex < thirdAttributes.zIndex)
        XCTAssertTrue(thirdAttributes.zIndex < fourthAttributes.zIndex)

        layout.collectionView?.contentOffset.y = 250
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 250, width: 320, height: 300))
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0))
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: 300, width: 320, height: 300))
        thirdAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0))
        XCTAssertEqual(thirdAttributes?.frame, CGRect(x: 0, y: 600, width: 320, height: 300))
        fourthAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 3, inSection: 0))
        XCTAssertEqual(fourthAttributes?.frame, CGRect(x: 0, y: 700, width: 320, height: 300))

        XCTAssertTrue(firstAttributes.zIndex < secondAttributes.zIndex)
        XCTAssertTrue(secondAttributes.zIndex < thirdAttributes.zIndex)
        XCTAssertTrue(thirdAttributes.zIndex < fourthAttributes.zIndex)

        layout.collectionView?.contentOffset.y = 300
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 300, width: 320, height: 300))
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0))
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: 300, width: 320, height: 300))
        thirdAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0))
        XCTAssertEqual(thirdAttributes?.frame, CGRect(x: 0, y: 600, width: 320, height: 300))
        fourthAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 3, inSection: 0))
        XCTAssertEqual(fourthAttributes?.frame, CGRect(x: 0, y: 700, width: 320, height: 300))

        XCTAssertTrue(firstAttributes.zIndex < secondAttributes.zIndex)
        XCTAssertTrue(secondAttributes.zIndex < thirdAttributes.zIndex)
        XCTAssertTrue(thirdAttributes.zIndex < fourthAttributes.zIndex)

        layout.collectionView?.contentOffset.y = 400
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 400, width: 320, height: 300))
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0))
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: 400, width: 320, height: 300))
        thirdAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0))
        XCTAssertEqual(thirdAttributes?.frame, CGRect(x: 0, y: 600, width: 320, height: 300))
        fourthAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 3, inSection: 0))
        XCTAssertEqual(fourthAttributes?.frame, CGRect(x: 0, y: 800, width: 320, height: 300))

        XCTAssertTrue(firstAttributes.zIndex < secondAttributes.zIndex)
        XCTAssertTrue(secondAttributes.zIndex < thirdAttributes.zIndex)
        XCTAssertTrue(thirdAttributes.zIndex < fourthAttributes.zIndex)
    }

    func testScrollNegative() {
        layout.collectionView?.contentOffset.y = -50
        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))

        firstAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 0, width: 320, height: 300))
        secondAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0))
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: 300, width: 320, height: 300))
        thirdAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0))
        XCTAssertEqual(thirdAttributes?.frame, CGRect(x: 0, y: 400, width: 320, height: 300))
        fourthAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 3, inSection: 0))
        XCTAssertEqual(fourthAttributes?.frame, CGRect(x: 0, y: 500, width: 320, height: 300))

        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 1200))
    }

//    func testScrollLastBrickToTop() {
//        behavior.scrollLastBrickToTop = true
//        layout.collectionView?.contentOffset.y = 0
//        layout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Scrolling))
//        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 1380))
//    }


    
}

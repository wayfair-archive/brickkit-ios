//
//  OffsetLayoutBehaviorTests.swift
//  BrickKit
//
//  Created by Justin Shiiba on 6/8/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class OffsetLayoutBehaviorTests: BrickFlowLayoutBaseTests {

    var behavior:OffsetLayoutBehavior!

    override func setUp() {
        super.setUp()
        layout.zIndexBehavior = .bottomUp
    }

    func testEmptyCollectionView() {
        behavior = OffsetLayoutBehavior(dataSource: FixedOffsetLayoutBehaviorDataSource(originOffset: CGSize(width: 20, height: -40), sizeOffset: nil))
        self.layout.behaviors.insert(behavior)
        setDataSources(SectionsCollectionViewDataSource(sections: []), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 300))
        XCTAssertFalse(behavior.hasInvalidatableAttributes())
        let attributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertNil(attributes?.frame)
    }


    func testOriginOffset() {
        let fixedOffsetLayout = FixedOffsetLayoutBehaviorDataSource(originOffset: CGSize(width: 20, height: -40), sizeOffset: nil)
        behavior = OffsetLayoutBehavior(dataSource: fixedOffsetLayout)
        self.layout.behaviors.insert(behavior)
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 300))

        let attributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(attributes?.frame, CGRect(x: 20, y: -40, width: 320, height: 300))
    }

    func testSizeOffset() {
        let fixedOffsetLayout = FixedOffsetLayoutBehaviorDataSource(originOffset: nil, sizeOffset: CGSize(width: -40, height: 20))
        behavior = OffsetLayoutBehavior(dataSource: fixedOffsetLayout)
        self.layout.behaviors.insert(behavior)
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 300))

        let attributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(attributes?.frame, CGRect(x: 0, y: 0, width: 280, height: 320))
    }

    func testOriginAndSizeOffset() {
        let fixedOffsetLayoutBehavior = FixedOffsetLayoutBehaviorDataSource(originOffset: CGSize(width: 20, height: -40), sizeOffset: CGSize(width: -40, height: 20))
        behavior = OffsetLayoutBehavior(dataSource: fixedOffsetLayoutBehavior)
        self.layout.behaviors.insert(behavior)
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 300))

        let attributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(attributes?.frame, CGRect(x: 20, y: -40, width: 280, height: 320))
    }

    func testOffsetAfterScroll() {
        let fixedOffsetLayout = FixedOffsetLayoutBehaviorDataSource(originOffset: CGSize(width: 20, height: -40), sizeOffset: CGSize(width: -40, height: 20))
        behavior = OffsetLayoutBehavior(dataSource: fixedOffsetLayout)
        self.layout.behaviors.insert(behavior)
        setDataSources(SectionsCollectionViewDataSource(sections: [1]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 300))

        let attributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(attributes?.frame, CGRect(x: 20, y: -40, width: 280, height: 320))

        layout.collectionView?.contentOffset.y = 60
        XCTAssertTrue(behavior.hasInvalidatableAttributes())
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))
        XCTAssertEqual(attributes?.frame, CGRect(x: 20, y: -40, width: 280, height: 320))
    }
}

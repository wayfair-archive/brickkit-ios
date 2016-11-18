//
//  MaxZIndexBehaviorTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 7/8/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class MaxZIndexBehaviorTests: BrickFlowLayoutBaseTests {
    
    func testMaxZIndex() {
        let fixedMaxZIndex = FixedMaxZIndexLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0), NSIndexPath(forItem: 1, inSection: 0)])
        let zIndexBehavior = MaxZIndexLayoutBehavior(dataSource: fixedMaxZIndex)
        self.layout.behaviors.insert(zIndexBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        XCTAssertEqual(self.layout.maxZIndex, 19)

        let attributes1 = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertNotNil(attributes1)
        XCTAssertEqual(attributes1?.zIndex, 20)

        let attributes2 = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0))
        XCTAssertNotNil(attributes2)
        XCTAssertEqual(attributes2?.zIndex, 21)
    }

}

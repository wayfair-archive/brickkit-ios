//
//  SetZIndexBehaviorTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 7/8/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class SetZIndexBehaviorTests: BrickFlowLayoutBaseTests {
    
    func testMaxZIndex() {
        let zIndexBehavior = SetZIndexLayoutBehavior(dataSource: FixedSetZIndexLayoutBehaviorDataSource(indexPaths: [NSIndexPath(forItem: 0, inSection: 0) : 1, NSIndexPath(forItem: 1, inSection: 0) : 2]))
        self.layout.behaviors.insert(zIndexBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        let attributes1 = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertNotNil(attributes1)
        XCTAssertEqual(attributes1?.zIndex, 21)

        let attributes2 = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0))
        XCTAssertNotNil(attributes2)
        XCTAssertEqual(attributes2?.zIndex, 22)
    }

}

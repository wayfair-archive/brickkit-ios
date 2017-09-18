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
        let fixedMaxZIndex = FixedMaxZIndexLayoutBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 0), IndexPath(item: 1, section: 0)])
        let zIndexBehavior = MaxZIndexLayoutBehavior(dataSource: fixedMaxZIndex)
        self.layout.behaviors.insert(zIndexBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        XCTAssertEqual(self.layout.maxZIndex, 19)

        let attributes1 = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertNotNil(attributes1)
        XCTAssertEqual(attributes1?.zIndex, 20)

        let attributes2 = layout.layoutAttributesForItem(at: IndexPath(item: 1, section: 0))
        XCTAssertNotNil(attributes2)
        XCTAssertEqual(attributes2?.zIndex, 21)
        
        // Not ideal to always return true but no way to easily determine if there are no index paths given to the datasource
        // that would satisfy the behavior for this to be false.
        XCTAssertTrue(zIndexBehavior.hasInvalidatableAttributes())
    }

}

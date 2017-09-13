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
        let behaviorDataSource = FixedSetZIndexLayoutBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 0) : 1, IndexPath(item: 1, section: 0) : 2])
        let zIndexBehavior = SetZIndexLayoutBehavior(dataSource: behaviorDataSource)
        self.layout.behaviors.insert(zIndexBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        let attributes1 = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertNotNil(attributes1)
        XCTAssertEqual(attributes1?.zIndex, 21)

        let attributes2 = layout.layoutAttributesForItem(at: IndexPath(item: 1, section: 0))
        XCTAssertNotNil(attributes2)
        XCTAssertEqual(attributes2?.zIndex, 22)
        
        // Not ideal to always return true but no way to easily determine if there are no index paths given to the datasource 
        // that would satisfy the behavior for this to be false.
        XCTAssertTrue(zIndexBehavior.hasInvalidatableAttributes())
    }

}

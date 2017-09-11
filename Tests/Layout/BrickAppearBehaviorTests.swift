//
//  BrickAppearBehaviorTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/11/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickAppearBehaviorTests: XCTestCase {

    var attributes: UICollectionViewLayoutAttributes!
    var brickCollectionView: BrickCollectionView!

    override func setUp() {
        super.setUp()

        attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
        attributes.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        brickCollectionView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        brickCollectionView.contentSize = brickCollectionView.frame.size
    }

    func testShouldInitializeWithoutAppearBehavior() {
        let brickLayout = BrickFlowLayout()
        XCTAssertNil(brickLayout.appearBehavior)
    }

    // Mark: - Top

    func testTopAppear() {
        let topAppear = BrickAppearTopBehavior()
        topAppear.configureAttributesForAppearing(attributes, in: brickCollectionView)
        XCTAssertEqual(attributes.frame, CGRect(x: 0, y: -200, width: 320, height: 200))
    }

    func testTopDisappear() {
        let topAppear = BrickAppearTopBehavior()
        topAppear.configureAttributesForDisappearing(attributes, in: brickCollectionView)
        XCTAssertEqual(attributes.frame, CGRect(x: 0, y: -200, width: 320, height: 200))
    }

    // Mark: - Bottom

    func testBottomAppear() {
        let bottomAppear = BrickAppearBottomBehavior()
        bottomAppear.configureAttributesForAppearing(attributes, in: brickCollectionView)
        XCTAssertEqual(attributes.frame, CGRect(x: 0, y: 480, width: 320, height: 200))
    }

    func testBottomDisappear() {
        let bottomAppear = BrickAppearBottomBehavior()
        bottomAppear.configureAttributesForDisappearing(attributes, in: brickCollectionView)
        XCTAssertEqual(attributes.frame, CGRect(x: 0, y: 480, width: 320, height: 200))
    }

    func testBottomAppearWithSmallContentHeight() {
        brickCollectionView.contentSize.height = 10
        let bottomAppear = BrickAppearBottomBehavior()
        bottomAppear.configureAttributesForAppearing(attributes, in: brickCollectionView)
        XCTAssertEqual(attributes.frame, CGRect(x: 0, y: 480, width: 320, height: 200))
    }

    func testBottomAppearWithLargeContentHeight() {
        brickCollectionView.contentSize.height = 1000
        let bottomAppear = BrickAppearBottomBehavior()
        bottomAppear.configureAttributesForAppearing(attributes, in: brickCollectionView)
        XCTAssertEqual(attributes.frame, CGRect(x: 0, y: 1000, width: 320, height: 200))
    }

    // Mark: - Fade

    func testScaleAppear() {
        let scaleAppear = BrickAppearScaleBehavior()
        scaleAppear.configureAttributesForAppearing(attributes, in: brickCollectionView)
        XCTAssertEqual(attributes.alpha, 0)
        XCTAssertEqual(attributes.transform, CGAffineTransform(scaleX: 0.1, y: 0.1))
    }

    func testScaleDisappear() {
        let scaleAppear = BrickAppearScaleBehavior()
        scaleAppear.configureAttributesForDisappearing(attributes, in: brickCollectionView)
        XCTAssertEqual(attributes.alpha, 0)
        XCTAssertEqual(attributes.transform, CGAffineTransform(scaleX: 0.1, y: 0.1))
    }
}

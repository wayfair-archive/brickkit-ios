//
//  RestrictedBrickSizeTest.swift
//  BrickKit
//
//  Created by Peter Cheung on 7/28/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class RestrictedBrickSizeFixedTests: XCTestCase {
    var brickCollectionView: BrickCollectionView!
    
    override func setUp() {
        super.setUp()
    
        brickCollectionView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }
    
    func testChangeBrickSizeGreaterThanMinimum() {
        
        let brick = DummyResizableBrick("Brick", height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .minimumSize(size: .fixed(size: 100))), setHeight: 200)
        brickCollectionView.setupSingleBrickAndLayout(brick)
        let index = brickCollectionView.indexPathsForBricksWithIdentifier("Brick").first!
        let cell = brickCollectionView.cellForItem(at: index) as? DummyResizableBrickCell
        cell?.layoutIfNeeded()
        XCTAssertEqual(cell?.frame.size.height, 200)
    }
    
    func testChangeBrickSizeLessThanMinimum() {

        let brick = DummyResizableBrick("Brick", height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .minimumSize(size: .fixed(size: 100))), setHeight: 50)
        
        brickCollectionView.setupSingleBrickAndLayout(brick)
        let index = brickCollectionView.indexPathsForBricksWithIdentifier("Brick").first!
        let cell = brickCollectionView.cellForItem(at: index) as? DummyResizableBrickCell
        cell?.layoutIfNeeded()
        XCTAssertEqual(cell?.frame.size.height, 100)
    }
    
    func testChangeBrickSizeGreaterThanMaximum() {
        let brick = DummyResizableBrick("Brick", height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .maximumSize(size: .fixed(size: 100))), setHeight: 200)
        
        brickCollectionView.setupSingleBrickAndLayout(brick)
        
        let index = brickCollectionView.indexPathsForBricksWithIdentifier("Brick").first!
        let cell = brickCollectionView.cellForItem(at: index) as? DummyResizableBrickCell
        cell?.layoutIfNeeded()
        XCTAssertEqual(cell?.frame.size.height, 100)
    }
    
    func testChangeBrickSizeLessThanMaximum() {
        let brick = DummyResizableBrick("Brick", height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .maximumSize(size: .fixed(size: 100))), setHeight: 50)
        
        brickCollectionView.setupSingleBrickAndLayout(brick)
        
        let index = brickCollectionView.indexPathsForBricksWithIdentifier("Brick").first!
        let cell = brickCollectionView.cellForItem(at: index) as? DummyResizableBrickCell
        cell?.layoutIfNeeded()
        XCTAssertEqual(cell?.frame.size.height, 50)
    }
}

class RestrictedBrickSizeRatioTests: XCTestCase {
    var brickCollectionView: BrickCollectionView!
    
    override func setUp() {
        super.setUp()
        
        brickCollectionView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }
    
    func testChangeBrickSizeGreaterThanMinimum() {
        let brick = DummyResizableBrick("Brick", height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .minimumSize(size: .ratio(ratio: 1/2))), setHeight: 200)
        
        brickCollectionView.setupSingleBrickAndLayout(brick)
        let index = brickCollectionView.indexPathsForBricksWithIdentifier("Brick").first!
        let cell = brickCollectionView.cellForItem(at: index) as? DummyResizableBrickCell
        cell?.layoutIfNeeded()
        XCTAssertEqual(cell?.frame.size.height, 200)
    }
    
    func testChangeBrickSizeLessThanMinimum() {
        
        let brick = DummyResizableBrick("Brick", height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .minimumSize(size: .ratio(ratio: 1/2))), setHeight: 50)
        
        brickCollectionView.setupSingleBrickAndLayout(brick)
        let index = brickCollectionView.indexPathsForBricksWithIdentifier("Brick").first!
        let cell = brickCollectionView.cellForItem(at: index) as? DummyResizableBrickCell
        cell?.layoutIfNeeded()
        XCTAssertEqual(cell?.frame.size.height, 160)
    }
    
    func testChangeBrickSizeGreaterThanMaximum() {
        let brick = DummyResizableBrick("Brick", height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .maximumSize(size: .ratio(ratio: 1/2))), setHeight: 200)
        
        brickCollectionView.setupSingleBrickAndLayout(brick)
        
        let index = brickCollectionView.indexPathsForBricksWithIdentifier("Brick").first!
        let cell = brickCollectionView.cellForItem(at: index) as? DummyResizableBrickCell
        cell?.layoutIfNeeded()
        XCTAssertEqual(cell?.frame.size.height, 160)
    }
    
    func testChangeBrickSizeLessThanMaximum() {
        let brick = DummyResizableBrick("Brick", height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .maximumSize(size: .ratio(ratio: 1/2))), setHeight: 50)
        
        brickCollectionView.setupSingleBrickAndLayout(brick)
        
        let index = brickCollectionView.indexPathsForBricksWithIdentifier("Brick").first!
        let cell = brickCollectionView.cellForItem(at: index) as? DummyResizableBrickCell
        cell?.layoutIfNeeded()
        XCTAssertEqual(cell?.frame.size.height, 50)
    }
}


class RestrictedBrickSizeIndirectTests: XCTestCase {
    var brickCollectionView: BrickCollectionView!
    
    override func setUp() {
        super.setUp()
        brickCollectionView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }
    
    func testChangeBrickSizeGreaterThanMinimumForPortrait() {
        let brick = DummyResizableBrick("Brick", height: .orientation(landscape: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .minimumSize(size: .fixed(size: 100))), portrait: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .minimumSize(size: .fixed(size: 200)))), setHeight: 50)
        
        brickCollectionView.setupSingleBrickAndLayout(brick)
        let index = brickCollectionView.indexPathsForBricksWithIdentifier("Brick").first!
        let cell = brickCollectionView.cellForItem(at: index) as? DummyResizableBrickCell
        cell?.layoutIfNeeded()
        
        #if os(tvOS) // Landscape
            XCTAssertEqual(cell?.frame.size.height, 100)
        #else // Portrait
            XCTAssertEqual(cell?.frame.size.height, 200)
        #endif
    }
    
    func testBrickSizeGreaterThanMinimumForPortraitRestrictedSizeOrientation() {
        let brick = DummyResizableBrick("Brick", height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .minimumSize(size: .orientation(landscape: .fixed(size: 100), portrait: .fixed(size: 200)))), setHeight: 50)
        
        brickCollectionView.setupSingleBrickAndLayout(brick)
        let index = brickCollectionView.indexPathsForBricksWithIdentifier("Brick").first!
        let cell = brickCollectionView.cellForItem(at: index) as? DummyResizableBrickCell
        cell?.layoutIfNeeded()
        
        #if os(tvOS) // Landscape
            XCTAssertEqual(cell?.frame.size.height, 100)
        #else // Portrait
            XCTAssertEqual(cell?.frame.size.height, 200)
        #endif
    }
}

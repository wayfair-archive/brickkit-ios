//
//  FrameCalculationTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 7/17/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class FrameCalculationTests: XCTestCase {
    var brickView: BrickCollectionView!
    
    override func setUp() {
        super.setUp()

        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    func testFrameInfoAutoHeight() {
        brickView.setupSingleBrickAndLayout(FrameInfoBrick("FrameInfo", width: .fixed(size: 50)))
        let indexPath = brickView.indexPathsForBricksWithIdentifier("FrameInfo").first!
        let frameCell = brickView.cellForItem(at: indexPath) as! FrameInfoBrickCell
        frameCell.layoutIfNeeded()

        XCTAssertEqual(frameCell.firstReportedImageViewFrame, CGRect(x: 20, y: 20, width: 25, height: 25))
    }

    func testFrameInfoFixedHeight() {
        brickView.setupSingleBrickAndLayout(FrameInfoBrick("FrameInfo", width: .fixed(size: 50), height: .fixed(size: 50)))
        let indexPath = brickView.indexPathsForBricksWithIdentifier("FrameInfo").first!
        let frameCell = brickView.cellForItem(at: indexPath) as! FrameInfoBrickCell
        frameCell.layoutIfNeeded()

        XCTAssertEqual(frameCell.firstReportedImageViewFrame, CGRect(x: 20, y: 20, width: 25, height: 25))
    }

    func testGenericBrick() {
        let genericBrick = GenericBrick<TestView>("FrameInfo", size: BrickSize(width: .fixed(size: 50), height: .fixed(size: 50))) { (view, cell) in
        }
        brickView.setupSingleBrickAndLayout(
            genericBrick
        )
        let indexPath = brickView.indexPathsForBricksWithIdentifier("FrameInfo").first!
        let cell = brickView.cellForItem(at: indexPath) as! GenericBrickCell
        cell.layoutIfNeeded()

        let testView = cell.genericContentView as! TestView

        XCTAssertTrue(testView.didUpdateFramesCalled)
    }

}

class TestView: UIView {
    var didUpdateFramesCalled: Bool = false
}

extension TestView: UpdateFramesListener {
    func didUpdateFrames() {
        didUpdateFramesCalled = true
    }
}

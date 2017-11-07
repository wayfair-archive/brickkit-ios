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
        let expect = expectation(description:"Expect framesDidLayout to get called")

        brickView.setupSingleBrickAndLayout(FrameInfoBrick("FrameInfo", width: .fixed(size: 50)))
        let indexPath = brickView.indexPathsForBricksWithIdentifier("FrameInfo").first!
        let frameCell = brickView.cellForItem(at: indexPath) as! FrameInfoBrickCell
        frameCell.layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(frameCell.firstReportedImageViewFrame, CGRect(x: 20, y: 20, width: 25, height: 25))
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testFrameInfoFixedHeight() {
        let expect = expectation(description:"Expect framesDidLayout to get called")

        brickView.setupSingleBrickAndLayout(FrameInfoBrick("FrameInfo", width: .fixed(size: 50), height: .fixed(size: 50)))
        let indexPath = brickView.indexPathsForBricksWithIdentifier("FrameInfo").first!
        let frameCell = brickView.cellForItem(at: indexPath) as! FrameInfoBrickCell
        frameCell.layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(frameCell.firstReportedImageViewFrame, CGRect(x: 20, y: 20, width: 25, height: 25))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testGenericBrick() {
        let expect = expectation(description:"Expect framesDidLayout to get called")

        let genericBrick = GenericBrick<TestView>("FrameInfo", size: BrickSize(width: .fixed(size: 50), height: .fixed(size: 50))) { (view, cell) in
        }
        brickView.setupSingleBrickAndLayout(
            genericBrick
        )
        let indexPath = brickView.indexPathsForBricksWithIdentifier("FrameInfo").first!
        let cell = brickView.cellForItem(at: indexPath) as! GenericBrickCell
        cell.layoutIfNeeded()

        let testView = cell.genericContentView as! TestView

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(testView.didUpdateFramesCalled)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testGenericBrickUIImageViewFrameListener() {
        let expect = expectation(description:"Expect framesDidLayout to get called")
        let mockFrameChangeListener = MockFrameListener()

        let genericBrick = GenericBrick<UIImageView>("FrameInfo", size: BrickSize(width: .fixed(size: 50), height: .fixed(size: 50))) { (view, cell) in
        }

        genericBrick.frameLayoutListener = mockFrameChangeListener

        brickView.setupSingleBrickAndLayout(
            genericBrick
        )
        let indexPath = brickView.indexPathsForBricksWithIdentifier("FrameInfo").first!
        let cell = brickView.cellForItem(at: indexPath) as! GenericBrickCell
        cell.layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(mockFrameChangeListener.didUpdateFramesCalled)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}

class TestView: UIView, FrameLayoutListener {
    var didUpdateFramesCalled: Bool = false
    func didLayoutFrames(cell: GenericBrickCell) {
        didUpdateFramesCalled = true
    }
}

class MockFrameListener: FrameLayoutListener {
    var didUpdateFramesCalled: Bool = false
    func didLayoutFrames(cell: GenericBrickCell) {
        didUpdateFramesCalled = true
    }
}

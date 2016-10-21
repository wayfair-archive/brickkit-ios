//
//  SnapToPointLayoutBehaviorTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class SnapToPointLayoutBehaviorTests: XCTestCase {

    var brickView: BrickCollectionView!
    var repeatCountDataSource: FixedRepeatCountDataSource!

    // Horizontal
    let centerStartHorizontal:CGFloat = 160 - 25
    let leftStartHorizontal:CGFloat = 0
    let rightStartHorizontal:CGFloat = 320 - 50

    // Vertical
    let middleStartVertical:CGFloat = 240 - 25
    let topStartVertical:CGFloat = 0
    let bottomStartVertical:CGFloat = 480 - 50

    override func setUp() {
        super.setUp()
        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    func testWithoutCollectionView() {
        let layout = BrickFlowLayout()
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Horizontal(.Center))
        layout.behaviors.insert(snapBehavior)

        expectFatalError {
            layout.targetContentOffsetForProposedContentOffset(CGPoint.zero, withScrollingVelocity: CGPoint.zero)
        }

    }

    func testWithoutBricks() {
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Horizontal(.Center))
        brickView.layout.behaviors.insert(snapBehavior)

        let contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(CGPoint.zero, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset, CGPoint.zero)
    }

    // Mark: - Horizontal

    func setupHorizontalScroll(repeatCount: Int = 20) {
        brickView.layout.scrollDirection = .Horizontal

        brickView.registerBrickClass(DummyBrick.self)
        let section = BrickSection(bricks: [
            DummyBrick("Brick", width: .Fixed(size: 50), height: .Fixed(size: 50))
            ], inset: 10)
        repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick": repeatCount])
        section.repeatCountDataSource = repeatCountDataSource
        brickView.setSection(section)
        brickView.layoutSubviews()
    }

    func testStartInsetsHorizontal() {
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Horizontal(.Center))
        brickView.layout.behaviors.insert(snapBehavior)
        setupHorizontalScroll()

        //Should start in center
        XCTAssertEqual(brickView.contentInset.left, centerStartHorizontal)
        XCTAssertEqual(brickView.contentInset.right, centerStartHorizontal)
        XCTAssertEqual(brickView.contentOffset.x, -centerStartHorizontal)

        //Should start left
        snapBehavior.scrollDirection = .Horizontal(.Left)
        XCTAssertEqual(brickView.contentInset.left, leftStartHorizontal)
        XCTAssertEqual(brickView.contentInset.right, rightStartHorizontal)

        //Should start right
        snapBehavior.scrollDirection = .Horizontal(.Right)
        XCTAssertEqual(brickView.contentInset.left, rightStartHorizontal)
        XCTAssertEqual(brickView.contentInset.right, leftStartHorizontal)
    }

    func testCenter() {
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Horizontal(.Center))
        brickView.layout.behaviors.insert(snapBehavior)
        setupHorizontalScroll()

        var contentOffset = CGPoint.zero

        //Scroll a little bit further, but not too far
        brickView.contentOffset.x += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, -centerStartHorizontal)

        //Scroll further so it will snap to the next brick
        brickView.contentOffset.x += 50
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, 60-centerStartHorizontal)

        brickView.contentOffset.x += 20
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, 60-centerStartHorizontal)

        //Scroll further so it will snap to the next brick
        brickView.contentOffset.x += 50
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, 120-centerStartHorizontal)

        brickView.contentOffset.x += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, 120-centerStartHorizontal)
        
    }

    func testLeft() {
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Horizontal(.Left))
        brickView.layout.behaviors.insert(snapBehavior)
        setupHorizontalScroll()

        var contentOffset = CGPoint.zero

        //Scroll a little bit further, but not too far
        brickView.contentOffset.x += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, -leftStartHorizontal)

        //Scroll further so it will snap to the next brick
        brickView.contentOffset.x += 50
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, 60-leftStartHorizontal)

        brickView.contentOffset.x += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, 60-leftStartHorizontal)

        //Scroll further so it will snap to the next brick
        brickView.contentOffset.x += 50
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, 120-leftStartHorizontal)

        brickView.contentOffset.x += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, 120-leftStartHorizontal)
        
    }

    func testRight() {
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Horizontal(.Right))
        brickView.layout.behaviors.insert(snapBehavior)
        setupHorizontalScroll()

        var contentOffset = CGPoint.zero

        //Scroll a little bit further, but not too far
        brickView.contentOffset.x += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, -rightStartHorizontal)

        //Scroll further so it will snap to the next brick
        brickView.contentOffset.x += 50
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, 60-rightStartHorizontal)

        brickView.contentOffset.x += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, 60-rightStartHorizontal)

        //Scroll further so it will snap to the next brick
        brickView.contentOffset.x += 50
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, 120-rightStartHorizontal)

        brickView.contentOffset.x += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, 120-rightStartHorizontal)
    }

    // Mark: - Vertical
    func setupVerticalScroll(repeatCount: Int = 20) {
        brickView.layout.scrollDirection = .Vertical

        brickView.registerBrickClass(DummyBrick.self)
        let section = BrickSection(bricks: [
            DummyBrick("Brick", height: .Fixed(size: 50))
            ], inset: 10)
        repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick": repeatCount])
        section.repeatCountDataSource = repeatCountDataSource
        brickView.setSection(section)
        brickView.layoutSubviews()
    }

    func testStartInsetsVerticalTop() {
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Vertical(.Top))
        brickView.layout.behaviors.insert(snapBehavior)
        setupHorizontalScroll()
        XCTAssertEqual(brickView.contentInset.top, topStartVertical)
        XCTAssertEqual(brickView.contentInset.bottom, bottomStartVertical)
    }

    func testStartInsetsVerticalMiddle() {
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Vertical(.Middle))
        brickView.layout.behaviors.insert(snapBehavior)
        setupHorizontalScroll()

        //Should start in center
        XCTAssertEqual(brickView.contentInset.top, middleStartVertical)
        XCTAssertEqual(brickView.contentInset.bottom, middleStartVertical)
        XCTAssertEqual(brickView.contentOffset.y, -middleStartVertical)
    }

    func testStartInsetsVerticalBottom() {
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Vertical(.Bottom))
        brickView.layout.behaviors.insert(snapBehavior)
        setupHorizontalScroll()

        //Should start bottom
        XCTAssertEqual(brickView.contentInset.top, bottomStartVertical)
        XCTAssertEqual(brickView.contentInset.bottom, topStartVertical)
    }
    
    func testMiddle() {
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Vertical(.Middle))
        brickView.layout.behaviors.insert(snapBehavior)
        setupVerticalScroll()

        var contentOffset = CGPoint.zero

        //Scroll a little bit further, but not too far
        brickView.contentOffset.y += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, -middleStartVertical)

        //Scroll further so it will snap to the next brick
        brickView.contentOffset.y += 50
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, 60-middleStartVertical)

        brickView.contentOffset.y += 20
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, 60-middleStartVertical)

        //Scroll further so it will snap to the next brick
        brickView.contentOffset.y += 50
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, 120-middleStartVertical)

        brickView.contentOffset.y += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, 120-middleStartVertical)

    }

    func testTop() {
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Vertical(.Top))
        brickView.layout.behaviors.insert(snapBehavior)
        setupVerticalScroll()

        var contentOffset = CGPoint.zero

        //Scroll a little bit further, but not too far
        brickView.contentOffset.y += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, -topStartVertical)

        //Scroll further so it will snap to the next brick
        brickView.contentOffset.y += 50
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, 60-topStartVertical)

        brickView.contentOffset.y += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, 60-topStartVertical)

        //Scroll further so it will snap to the next brick
        brickView.contentOffset.y += 50
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, 120-topStartVertical)

        brickView.contentOffset.y += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, 120-topStartVertical)

    }

    func testBottom() {
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Vertical(.Bottom))
        brickView.layout.behaviors.insert(snapBehavior)
        setupVerticalScroll()

        var contentOffset = CGPoint.zero

        //Scroll a little bit further, but not too far
        brickView.contentOffset.y += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, -bottomStartVertical)

        //Scroll further so it will snap to the next brick
        brickView.contentOffset.y += 50
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, 60-bottomStartVertical)

        brickView.contentOffset.y += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, 60-bottomStartVertical)

        //Scroll further so it will snap to the next brick
        brickView.contentOffset.y += 50
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, 120-bottomStartVertical)

        brickView.contentOffset.y += 10
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.y, 120-bottomStartVertical)
    }

    func testSnapToTheCenterOfTheContentView() {
        if is32Bit { // Ignoring iPhone 5 or lower for now
            return
        }

        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Horizontal(.Center))
        brickView.layout.behaviors.insert(snapBehavior)

        brickView.layout.scrollDirection = .Horizontal

        brickView.registerBrickClass(DummyBrick.self)
        let section = BrickSection(bricks: [
            DummyBrick("Brick", width: .Ratio(ratio: 0.5), height: .Fixed(size: 50))
            ])
        repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick": 6])
        section.repeatCountDataSource = repeatCountDataSource
        brickView.setSection(section)
        brickView.layoutSubviews()

        var contentOffset = CGPoint.zero

        //Scroll a little bit further, but not too far
        brickView.contentOffset.x = brickView.frame.width
        contentOffset = brickView.collectionViewLayout.targetContentOffsetForProposedContentOffset(brickView.contentOffset, withScrollingVelocity: CGPoint.zero)
        XCTAssertEqual(contentOffset.x, brickView.frame.width + brickView.frame.width / 4)

    }



}

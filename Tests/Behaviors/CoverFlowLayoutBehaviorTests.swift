//
//  CoverFlowLayoutBehaviorTests.swift
//  BrickKit
//
//  Created by Randall Spence on 10/11/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

extension CGAffineTransform {
    var scaleX: CGFloat {
        return self.a
    }

    var scaleY: CGFloat {
        return self.d
    }
}

class CoverFlowLayoutBehaviorTests: XCTestCase {

    var brickView: BrickCollectionView!
    var repeatCountDataSource: FixedRepeatCountDataSource!
    let coverFlowBehavior = CoverFlowLayoutBehavior(minimumScaleFactor: 0.5)

    override func setUp() {
        super.setUp()
        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 480))

        brickView.layout.behaviors.insert(coverFlowBehavior)
        brickView.layout.scrollDirection = .horizontal
        brickView.registerBrickClass(DummyBrick.self)
        let section = BrickSection(bricks: [
            DummyBrick("Brick", width: .ratio(ratio: 1/3), height: .fixed(size: 50))
            ])
        repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick": 20])
        section.repeatCountDataSource = repeatCountDataSource
        brickView.setSection(section)
        brickView.layoutSubviews()
    }

    func testCoverFlowBehaviorBase() {

        let cellBase = brickView.cellForItem(at: IndexPath(item: 0, section: 0))
        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        let cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        let cell3 = brickView.cellForItem(at: IndexPath(item: 2, section: 1))

        XCTAssertEqual(cellBase!.transform.scaleX, 1, accuracy: 0.01)
        XCTAssertEqual(cellBase!.transform.scaleY, 1, accuracy: 0.01)
        XCTAssertEqual(cell1!.transform.scaleX, 2/3, accuracy: 0.01)
        XCTAssertEqual(cell1!.transform.scaleY, 2/3, accuracy: 0.01)
        XCTAssertEqual(cell2!.transform.scaleX, 1, accuracy: 0.01)
        XCTAssertEqual(cell2!.transform.scaleY, 1, accuracy: 0.01)
        XCTAssertEqual(cell3!.transform.scaleX, 2/3, accuracy: 0.01)
        XCTAssertEqual(cell3!.transform.scaleY, 2/3, accuracy: 0.01)
        XCTAssertTrue(coverFlowBehavior.hasInvalidatableAttributes())
    }


    func testCoverFlowBehaviorScrollHalf() {
        brickView.contentOffset.x = brickView.frame.width / 6
        brickView.layoutIfNeeded()

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        let cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        let cell3 = brickView.cellForItem(at: IndexPath(item: 2, section: 1))

        XCTAssertEqual(cell1!.transform.scaleX, 0.5, accuracy: 0.01)
        XCTAssertEqual(cell1!.transform.scaleY, 0.5, accuracy: 0.01)
        XCTAssertEqual(cell2!.transform.scaleX, 5/6, accuracy: 0.01)
        XCTAssertEqual(cell2!.transform.scaleY, 5/6, accuracy: 0.01)
        XCTAssertEqual(cell3!.transform.scaleX, 5/6, accuracy: 0.01)
        XCTAssertEqual(cell3!.transform.scaleY, 5/6, accuracy: 0.01)
    }

    func testCoverFlowBehaviorScrollToEnd() {
        brickView.contentOffset.x = brickView.contentSize.width - brickView.frame.width
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItem(at: IndexPath(item: 17, section: 1))
        let cell2 = brickView.cellForItem(at: IndexPath(item: 18, section: 1))
        let cell3 = brickView.cellForItem(at: IndexPath(item: 19, section: 1))

        XCTAssertEqual(cell1!.transform.scaleX, 2/3, accuracy: 0.01)
        XCTAssertEqual(cell1!.transform.scaleY, 2/3, accuracy: 0.01)
        XCTAssertEqual(cell2!.transform.scaleX, 1, accuracy: 0.01)
        XCTAssertEqual(cell2!.transform.scaleY, 1, accuracy: 0.01)
        XCTAssertEqual(cell3!.transform.scaleX, 2/3, accuracy: 0.01)
        XCTAssertEqual(cell3!.transform.scaleY, 2/3, accuracy: 0.01)
    }

    func testCoverFlowBehaviorScrollNegative() {
        brickView.contentOffset.x = -(brickView.frame.width / 6)
        brickView.layoutIfNeeded()

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        let cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1))
        let cell3 = brickView.cellForItem(at: IndexPath(item: 2, section: 1))

        XCTAssertEqual(cell1!.transform.scaleX, 5/6, accuracy: 0.01)
        XCTAssertEqual(cell1!.transform.scaleY, 5/6, accuracy: 0.01)
        XCTAssertEqual(cell2!.transform.scaleX, 5/6, accuracy: 0.01)
        XCTAssertEqual(cell2!.transform.scaleY, 5/6, accuracy: 0.01)
        XCTAssertEqual(cell3!.transform.scaleX, 0.5, accuracy: 0.01)
        XCTAssertEqual(cell3!.transform.scaleY, 0.5, accuracy: 0.01)
    }

    func testIfContentSizeIsCalculatedCorrectly() {
        XCTAssertEqual(brickView.contentSize, CGSize(width: 2000, height: 50))
    }

    func testIfLayoutAttributesAreCalculatedCorrectly() {
        brickView.contentOffset.x = brickView.frame.width / 6
        brickView.layoutIfNeeded()

        let cell1 = brickView.cellForItem(at: IndexPath(item: 1, section: 1)) as! BrickCell

        guard let layoutAttributes = brickView.layout.layoutAttributesForItem(at: IndexPath(item: 1, section: 1)) else {
            XCTFail("layoutAttributes should not be nil")
            return
        }
        let heightBefore = layoutAttributes.frame.size.height

        let newLayout = cell1.preferredLayoutAttributesFitting(layoutAttributes)
        let heightAfter = newLayout.frame.size.height

        XCTAssertTrue(heightBefore == heightAfter)
    }
}


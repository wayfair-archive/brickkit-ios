//
//  BaseBrickCellTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/7/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class BaseBrickCellTests: XCTestCase {
    var brickView: BrickCollectionView!

    override func setUp() {
        super.setUp()

        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    func testSeparatorDefault() {
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(height: .fixed(size: 100), text: "HELLO WORLD", configureCellBlock: { (cell) in
                cell.addSeparatorLine(100)
            })
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell?.bottomSeparatorLine.superview)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.width, 100)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.height, 0.5)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.origin.x, 0)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.origin.y, 99.5)
        XCTAssertEqual(cell?.bottomSeparatorLine.backgroundColor, UIColor.lightGray)
        XCTAssertNil(cell?.topSeparatorLine.superview)
    }

    func testSeparatorBottomCustom() {
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(height: .fixed(size: 100), text: "HELLO WORLD", configureCellBlock: { (cell) in
                cell.addSeparatorLine(100, onTop: false, xOrigin: 10, backgroundColor: UIColor.blue, height: 1)
            })
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell?.bottomSeparatorLine.superview)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.width, 100)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.height, 1)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.origin.x, 10)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.origin.y, 99)
        XCTAssertEqual(cell?.bottomSeparatorLine.backgroundColor, UIColor.blue)
        XCTAssertNil(cell?.topSeparatorLine.superview)
    }

    func testSeparatorTopCustom() {
        brickView.registerBrickClass(LabelBrick.self)

        
        let section = BrickSection(bricks: [
            LabelBrick(text: "HELLO WORLD", configureCellBlock: { (cell) in
                cell.addSeparatorLine(100, onTop: true, xOrigin: 10, backgroundColor: UIColor.blue, height: 1)
            })
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell?.topSeparatorLine.superview)
        XCTAssertEqual(cell?.topSeparatorLine.frame.width, 100)
        XCTAssertEqual(cell?.topSeparatorLine.frame.height, 1)
        XCTAssertEqual(cell?.topSeparatorLine.frame.origin.x, 10)
        XCTAssertEqual(cell?.topSeparatorLine.frame.origin.y, 0)
        XCTAssertEqual(cell?.topSeparatorLine.backgroundColor, UIColor.blue)
        XCTAssertNil(cell?.bottomSeparatorLine.superview)
    }

    func testAddBoth() {
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(height: .fixed(size: 100), text: "HELLO WORLD", configureCellBlock: { (cell) in
                cell.addSeparatorLine(100, onTop: false)
                cell.addSeparatorLine(100, onTop: true)
            })
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell?.bottomSeparatorLine.superview)
        XCTAssertNotNil(cell?.topSeparatorLine.superview)
    }

    func testMultiple() {
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(height: .fixed(size: 100), text: "HELLO WORLD", configureCellBlock: { (cell) in
                cell.addSeparatorLine(100, xOrigin: 200)
                cell.addSeparatorLine(200)
                cell.addSeparatorLine(300)
            })
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? BaseBrickCell
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.width, 300)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.origin.x, 0)
    }

    func testRemoveSeparators() {
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(height: .fixed(size: 100), text: "HELLO WORLD", configureCellBlock: { (cell) in
                cell.addSeparatorLine(100, onTop: false)
                cell.addSeparatorLine(100, onTop: true)
                cell.removeSeparators()
            })
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? BaseBrickCell
        XCTAssertNil(cell?.bottomSeparatorLine.superview)
        XCTAssertNil(cell?.topSeparatorLine.superview)
        
    }

    func testBackgroundView() {
        let backgroundView1 = UIView()
        backgroundView1.backgroundColor = UIColor.orange
        backgroundView1.tag = 21

        let backgroundView2 = UIView()
        backgroundView2.backgroundColor = UIColor.orange
        backgroundView2.tag = 22

        let backgroundView3 = UIView()
        backgroundView3.backgroundColor = UIColor.orange
        backgroundView3.tag = 23

        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick("Brick", height: .fixed(size: 200), backgroundView: backgroundView1),
            DummyBrick("Brick", height: .fixed(size: 2000), backgroundView: backgroundView2),
            DummyBrick("Brick", height: .fixed(size: 100), backgroundView: backgroundView3),
            DummyBrick("Brick1", height: .fixed(size: 100), backgroundView: backgroundView1),
            ])
        let repeatCount = 20
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": repeatCount])
        section.repeatCountDataSource = repeatCountDataSource

        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell1?.contentView.viewWithTag(21))
        XCTAssertEqual(cell1?.contentView.subviews.first, backgroundView1)


        let cell2 = brickView.cellForItem(at: IndexPath(item: 1, section: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell2?.contentView.viewWithTag(22))
        XCTAssertEqual(cell2?.contentView.subviews.first, backgroundView2)

        brickView.contentOffset = CGPoint(x: 0, y: 2000)
        for _ in 0..<repeatCount {
            brickView.contentOffset.y += 100
            brickView.layoutSubviews()
        }

        let cell3 = brickView.cellForItem(at: IndexPath(item: repeatCount + 2, section: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell3?.contentView.viewWithTag(21))
        XCTAssertEqual(cell3?.contentView.subviews.first, backgroundView1)
    }

    // Mark: - BrickCell
    func testEdgeInsets() {
        brickView.registerNib(UINib(nibName: "LabelWithEdgeInsets", bundle: Bundle(for: self.classForCoder)), forBrickWithIdentifier: "Brick")

        let section = BrickSection(bricks: [
            LabelBrick("Brick", height: .fixed(size: 100), text: "HELLO WORLD", configureCellBlock: { (cell) in
                XCTAssertEqual(cell.defaultEdgeInsets, UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

                cell.topSpaceConstraint = nil
                cell.bottomSpaceConstraint = nil
                cell.leftSpaceConstraint = nil
                cell.rightSpaceConstraint = nil

                XCTAssertEqual(cell.defaultEdgeInsets, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            })
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()
    }

    func testDefaultAccessibilityIdentifierSetFromBrickIdentifier() {
        brickView.registerBrickClass(DummyBrick.self)
        let dummyBrick = DummyBrick("BrickIdentifierThatIsDefaultAccessibilityIdentifier")
        let section = BrickSection(bricks: [dummyBrick])
        brickView.setSection(section)
        brickView.layoutSubviews()
        let dummyCell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? DummyBrickCell
        XCTAssertEqual(dummyBrick.identifier, "BrickIdentifierThatIsDefaultAccessibilityIdentifier")
        XCTAssertNil(dummyCell?.accessibilityHint)
        XCTAssertNil(dummyCell?.accessibilityLabel)
    }

    func testSetAccessibilityIdentifier() {
        brickView.registerBrickClass(DummyBrick.self)
        let dummyBrick = DummyBrick("BrickIdentifierThatIsDefaultAccessibilityIdentifier")
        dummyBrick.accessibilityIdentifier = "AccessibilityIdentifierForDummyBrickCell"
        let section = BrickSection(bricks: [dummyBrick])
        brickView.setSection(section)
        brickView.layoutSubviews()
        let dummyCell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? DummyBrickCell
        XCTAssertEqual(dummyCell?.accessibilityIdentifier, "AccessibilityIdentifierForDummyBrickCell")
        XCTAssertNil(dummyCell?.accessibilityHint)
        XCTAssertNil(dummyCell?.accessibilityLabel)
    }

    func testSetAccessibilityHintAndLabel() {
        brickView.registerBrickClass(DummyBrick.self)
        let dummyBrick = DummyBrick("BrickIdentifierThatIsDefaultAccessibilityIdentifier")
        dummyBrick.accessibilityHint = "Accessibility Hint"
        dummyBrick.accessibilityLabel = "Accessibility Label"
        let section = BrickSection(bricks: [dummyBrick])
        brickView.setSection(section)
        brickView.layoutSubviews()
        let dummyCell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? DummyBrickCell
        XCTAssertEqual(dummyCell?.accessibilityHint, "Accessibility Hint")
        XCTAssertEqual(dummyCell?.accessibilityLabel, "Accessibility Label")
    }
}

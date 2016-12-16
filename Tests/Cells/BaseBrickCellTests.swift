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
            LabelBrick(height: .Fixed(size: 100), text: "HELLO WORLD", configureCellBlock: { (cell) in
                cell.addSeparatorLine(100)
            })
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell?.bottomSeparatorLine.superview)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.width, 100)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.height, 0.5)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.origin.x, 0)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.origin.y, 99.5)
        XCTAssertEqual(cell?.bottomSeparatorLine.backgroundColor, .lightGrayColor())
        XCTAssertNil(cell?.topSeparatorLine.superview)
    }

    func testSeparatorBottomCustom() {
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(height: .Fixed(size: 100), text: "HELLO WORLD", configureCellBlock: { (cell) in
                cell.addSeparatorLine(100, onTop: false, xOrigin: 10, backgroundColor: .blueColor(), height: 1)
            })
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell?.bottomSeparatorLine.superview)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.width, 100)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.height, 1)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.origin.x, 10)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.origin.y, 99)
        XCTAssertEqual(cell?.bottomSeparatorLine.backgroundColor, .blueColor())
        XCTAssertNil(cell?.topSeparatorLine.superview)
    }

    func testSeparatorTopCustom() {
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(text: "HELLO WORLD", configureCellBlock: { (cell) in
                cell.addSeparatorLine(100, onTop: true, xOrigin: 10, backgroundColor: .blueColor(), height: 1)
            })
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell?.topSeparatorLine.superview)
        XCTAssertEqual(cell?.topSeparatorLine.frame.width, 100)
        XCTAssertEqual(cell?.topSeparatorLine.frame.height, 1)
        XCTAssertEqual(cell?.topSeparatorLine.frame.origin.x, 10)
        XCTAssertEqual(cell?.topSeparatorLine.frame.origin.y, 0)
        XCTAssertEqual(cell?.topSeparatorLine.backgroundColor, .blueColor())
        XCTAssertNil(cell?.bottomSeparatorLine.superview)
    }

    func testAddBoth() {
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(height: .Fixed(size: 100), text: "HELLO WORLD", configureCellBlock: { (cell) in
                cell.addSeparatorLine(100, onTop: false)
                cell.addSeparatorLine(100, onTop: true)
            })
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell?.bottomSeparatorLine.superview)
        XCTAssertNotNil(cell?.topSeparatorLine.superview)
    }

    func testMultiple() {
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(height: .Fixed(size: 100), text: "HELLO WORLD", configureCellBlock: { (cell) in
                cell.addSeparatorLine(100, xOrigin: 200)
                cell.addSeparatorLine(200)
                cell.addSeparatorLine(300)
            })
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? BaseBrickCell
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.width, 300)
        XCTAssertEqual(cell?.bottomSeparatorLine.frame.origin.x, 0)
    }

    func testRemoveSeparators() {
        brickView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(height: .Fixed(size: 100), text: "HELLO WORLD", configureCellBlock: { (cell) in
                cell.addSeparatorLine(100, onTop: false)
                cell.addSeparatorLine(100, onTop: true)
                cell.removeSeparators()
            })
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? BaseBrickCell
        XCTAssertNil(cell?.bottomSeparatorLine.superview)
        XCTAssertNil(cell?.topSeparatorLine.superview)
        
    }

    func testBackgroundView() {
        let backgroundView1 = UIView()
        backgroundView1.backgroundColor = .orangeColor()
        backgroundView1.tag = 21

        let backgroundView2 = UIView()
        backgroundView2.backgroundColor = .orangeColor()
        backgroundView2.tag = 22

        let backgroundView3 = UIView()
        backgroundView3.backgroundColor = .orangeColor()
        backgroundView3.tag = 23

        brickView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick("Brick", height: .Fixed(size: 200), backgroundView: backgroundView1),
            DummyBrick("Brick", height: .Fixed(size: 2000), backgroundView: backgroundView2),
            DummyBrick("Brick", height: .Fixed(size: 100), backgroundView: backgroundView3),
            DummyBrick("Brick1", height: .Fixed(size: 100), backgroundView: backgroundView1),
            ])
        let repeatCount = 20
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": repeatCount])
        section.repeatCountDataSource = repeatCountDataSource

        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell1?.contentView.viewWithTag(21))
        XCTAssertEqual(cell1?.contentView.subviews.first, backgroundView1)


        let cell2 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell2?.contentView.viewWithTag(22))
        XCTAssertEqual(cell2?.contentView.subviews.first, backgroundView2)

        brickView.contentOffset = CGPoint(x: 0, y: 2000)
        for _ in 0..<repeatCount {
            brickView.contentOffset.y += 100
            brickView.layoutSubviews()
        }

        let cell3 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: repeatCount + 2, inSection: 1)) as? BaseBrickCell
        XCTAssertNotNil(cell3?.contentView.viewWithTag(21))
        XCTAssertEqual(cell3?.contentView.subviews.first, backgroundView1)
    }
    
    func testBrickViewAppearance() {
        brickView.registerBrickClass(LabelBrick.self)
        
        let testLabelBrick = LabelBrick("AppearanceTest", height: .Fixed(size: 100), text: "Appearance Test")
        testLabelBrick.brickCellAppearanceDataSource = self
        
        brickView.setSection(BrickSection(bricks: [testLabelBrick]))
        brickView.layoutSubviews()
        
        guard let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? BrickCell else {
            XCTAssert(false, "Cell Should Not be nil")
            return
        }
        
        cell.updateBrickCell(for: .Loading)

        XCTAssertEqual(cell.contentView.subviews.last?.backgroundColor, .grayColor())
        XCTAssertEqual(cell.contentView.subviews.last?.tag, 24)
        
        cell.updateBrickCell(for: .Loaded)
        
        guard let labelBrickCell = cell as? LabelBrickCell else {
            XCTAssert(false, "Cell Should be of type LabelBrickCell")
            return
        }
        
        guard let labelView = cell.contentView.subviews.last as? UILabel, labelText = labelView.text else {
            XCTAssert(false, "Visible view should be UILabel")
            return
        }
        XCTAssertEqual(labelText, labelBrickCell.label.text)
        
        cell.updateBrickCell(for: .Error)
        
        XCTAssertEqual(cell.contentView.subviews.last?.backgroundColor, .redColor())
        XCTAssertEqual(cell.contentView.subviews.last?.tag, 25)
    }

    // Mark: - BrickCell
    func testEdgeInsets() {
        brickView.registerNib(UINib(nibName: "LabelWithEdgeInsets", bundle: NSBundle(forClass: self.classForCoder)), forBrickWithIdentifier: "Brick")

        let section = BrickSection(bricks: [
            LabelBrick("Brick", height: .Fixed(size: 100), text: "HELLO WORLD", configureCellBlock: { (cell) in
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
    

}

extension BaseBrickCellTests: BrickCellAppearanceDataSource {
    func viewForLoadingAppearance(with identifier: String) -> UIView? {
        let loadingView = UIView()
        loadingView.backgroundColor = .grayColor()
        loadingView.tag = 24
        return loadingView
    }
    func viewForLoadedAppearance(with identifier: String) -> UIView? {
        return nil
    }
    func viewForErrorAppearance(with identifier: String) -> UIView? {
        let errorView = UIView()
        errorView.backgroundColor = .redColor()
        errorView.tag = 25
        return errorView
    }
}

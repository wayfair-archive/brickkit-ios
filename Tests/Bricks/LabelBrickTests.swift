//
//  LabelBrickTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/2/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class LabelBrickTests: XCTestCase {

    private let LabelBrickIdentifier = "LabelBrickIdentifier"

    var brickCollectionView: BrickCollectionView!
    var labelBrick: LabelBrick!

    override func setUp() {
        super.setUp()

        brickCollectionView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    func setupLabelBrickWithModel(model: LabelBrickCellModel) -> LabelBrickCell? {
        return setupSection(LabelBrick(LabelBrickIdentifier, dataSource: model))
    }

    func setupLabelBrick(text: String, configureCellBlock: ConfigureLabelBlock? = nil) -> LabelBrickCell? {
        return setupSection(LabelBrick(LabelBrickIdentifier, text: text, configureCellBlock: { cell in
            cell.label.font = UIFont(name: "Avenir-Medium", size: 14)
            configureCellBlock?(cell: cell)
            }))
    }

    func setupSection(labelBrick: LabelBrick) -> LabelBrickCell? {
        brickCollectionView.registerBrickClass(LabelBrick.self)
        self.labelBrick = labelBrick
        let section = BrickSection(bricks: [
            labelBrick
            ])
        brickCollectionView.setSection(section)
        brickCollectionView.layoutSubviews()

        return labelCell
    }

    var labelCell: LabelBrickCell? {
        let cell = brickCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? LabelBrickCell
        cell?.layoutIfNeeded()
        return cell
    }

    func testLabelBrick() {
        let cell = setupLabelBrick("Hello World")

        XCTAssertEqual(cell?.label.text, "Hello World")

        XCTAssertEqual(cell?.topSpaceConstraint?.constant, 0)
        XCTAssertEqual(cell?.bottomSpaceConstraint?.constant, 0)
        XCTAssertEqual(cell?.leftSpaceConstraint?.constant, 0)
        XCTAssertEqual(cell?.rightSpaceConstraint?.constant, 0)

        XCTAssertEqualWithAccuracy(cell?.frame, CGRectMake(0, 0, 320, 20), accuracy: CGRectMake(0, 0, 1, 1))
        XCTAssertEqualWithAccuracy(cell?.label.frame, CGRectMake(0, 0, 320, 20), accuracy: CGRectMake(0, 0, 1, 1))
        
    }

    func testLabelBrickMultiLine() {
        let cell = setupLabelBrick("Hello World\nHello World")

        XCTAssertEqual(cell?.label.text, "Hello World\nHello World")
        
        XCTAssertEqualWithAccuracy(cell?.frame, CGRectMake(0, 0, 320, 39), accuracy: CGRectMake(0, 0, 1, 1))
        XCTAssertEqualWithAccuracy(cell?.label.frame, CGRectMake(0, 0, 320, 39), accuracy: CGRectMake(0, 0, 1, 1))
    }

    func testLabelBrickEdgeInsets() {
        let cell = setupLabelBrick("Hello World", configureCellBlock: { cell in
            cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 10)
            })

        XCTAssertEqual(cell?.topSpaceConstraint?.constant, 5)
        XCTAssertEqual(cell?.leftSpaceConstraint?.constant, 5)
        XCTAssertEqual(cell?.bottomSpaceConstraint?.constant, 10)
        XCTAssertEqual(cell?.rightSpaceConstraint?.constant, 10)

        XCTAssertEqualWithAccuracy(cell?.frame, CGRectMake(0, 0, 320, 35), accuracy: CGRectMake(0, 0, 1, 1))
        XCTAssertEqualWithAccuracy(cell?.label.frame, CGRectMake(5, 5, 305, 20), accuracy: CGRectMake(0, 0, 1, 1))
    }

    func testLabelBrickEdgeInsetsMultiLine() {
        let cell = setupLabelBrick("Hello World\nHello World", configureCellBlock: { cell in
            cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 10)
            })

        guard let cellFrame = cell?.frame, let labelFrame = cell?.label.frame else {
            XCTAssertEqual(cell?.frame, CGRectMake(0, 0, 320, 54))
            XCTAssertEqual(cell?.label.frame, CGRectMake(0, 0, 305, 39))
            return
        }
        
        XCTAssertEqualWithAccuracy(cellFrame, CGRectMake(0, 0, 320, 54), accuracy: CGRectMake(0, 0, 1, 1))
        XCTAssertEqualWithAccuracy(labelFrame, CGRectMake(5, 5, 305, 39), accuracy: CGRectMake(0, 0, 1, 1))
    }

    func testChangeText() {
        var cell = setupLabelBrick("Hello World")

        XCTAssertEqual(cell?.label.text, "Hello World")

        labelBrick.text = "World Hello"
        XCTAssertEqual(labelBrick.text, "World Hello")

        brickCollectionView.reloadBricksWithIdentifiers([LabelBrickIdentifier], shouldReloadCell: false)
        cell = labelCell
        XCTAssertEqual(cell?.label.text, "World Hello")

        labelBrick.text = "Hello World"
        brickCollectionView.reloadBricksWithIdentifiers([LabelBrickIdentifier], shouldReloadCell: true)
        brickCollectionView.layoutIfNeeded()
        cell = labelCell
        XCTAssertEqual(cell?.label.text, "Hello World")
    }

    func testLabelChangeText() {
        let labelBrick = LabelBrick(text: "Hello World")
        labelBrick.text = "World Hello"
        XCTAssertEqual(labelBrick.text, "World Hello")
    }

    func testLabelConfigureCellBlock() {
        let configureCellBlock: ConfigureLabelBlock = { cell in
        }
        let labelBrick = LabelBrick(text: "Hello World")
        labelBrick.configureCellBlock = configureCellBlock
        XCTAssertNotNil(labelBrick.configureCellBlock)
    }

    func testLabelTextShouldBeEmptyStringWhenSettingToNil() {
        let labelBrick = LabelBrick(text: "Hello World")
        labelBrick.text = nil
        XCTAssertEqual(labelBrick.text, "")
    }

    func testCantSetTextOfLabelBrickWithWrongDataSource() {
        expectFatalError {
            let labelBrick = LabelBrick(dataSource: FixedLabelDataSource())
            labelBrick.text = "Hello World"
        }
    }

    func testCantGetTextOfLabelBrickWithWrongDataSource() {
        expectFatalError {
            let labelBrick = LabelBrick(dataSource: FixedLabelDataSource())
            let _ = labelBrick.text
        }
    }

    func testCantSetConfigureCellBlockOfLabelBrickWithWrongDataSource() {
        expectFatalError {
            let labelBrick = LabelBrick(dataSource: FixedLabelDataSource())
            labelBrick.configureCellBlock = { cell in
            }
        }
    }

    func testCantGetConfigureCellBlockOfLabelBrickWithWrongDataSource() {
        expectFatalError {
            let labelBrick = LabelBrick(dataSource: FixedLabelDataSource())
            let _ = labelBrick.configureCellBlock
        }
    }

    func testLabelModelWithTextColor() {
        let cell = setupLabelBrickWithModel(LabelBrickCellModel(text: "Hello World", textColor: UIColor.blueColor()))
        XCTAssertEqual(cell?.label.textColor, UIColor.blueColor())
    }

    func testLabelWithDecorationImageBrickCellModelWithWrongNib() {
        let image = UIImage(named: "chevron", inBundle: LabelBrick.bundle, compatibleWithTraitCollection: nil)!
        let cell = setupLabelBrickWithModel(LabelWithDecorationImageBrickCellModel(text: "Hello World", image: image))
        XCTAssertNil(cell?.imageView?.image)
    }

    func testLabelWithDecorationImageBrickCellModel() {
        brickCollectionView.registerNib(LabelBrickNibs.Image, forBrickWithIdentifier: LabelBrickIdentifier)
        let image = UIImage(named: "chevron", inBundle: LabelBrick.bundle, compatibleWithTraitCollection: nil)!
        let cell = setupLabelBrickWithModel(LabelWithDecorationImageBrickCellModel(text: "Hello World", image: image))
        XCTAssertEqual(cell?.imageView?.image, image)
    }

    func testLabelImage() {
        brickCollectionView.registerNib(LabelBrickNibs.Image, forBrickWithIdentifier: LabelBrickIdentifier)
        let image = UIImage(named: "chevron", inBundle: LabelBrick.bundle, compatibleWithTraitCollection: nil)!
        let cell = setupLabelBrickWithModel(LabelWithDecorationImageBrickCellModel(text: "Hello World", image: image))
        XCTAssertEqual(cell?.imageView?.image, image)
    }

    func testLabelWithButton() {
        brickCollectionView.registerNib(LabelBrickNibs.Button, forBrickWithIdentifier: LabelBrickIdentifier)

        
        let cell = setupLabelBrick("Hello World", configureCellBlock: { cell in
            XCTAssertNotNil(cell.button)
            cell.button?.setTitle("BUTTON", forState: .Normal)
            cell.button?.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
        })
        
        XCTAssertNotNil(cell?.button)
        XCTAssertEqual(cell?.button?.titleLabel?.text, "BUTTON")
        
        let buttonWidth = cell?.button?.frame.size.width ?? 61
        
        #if os(iOS)
            let cellSize = CGSize(width: 320, height: 32)
            let buttonSize = CGSize(width: 320 - buttonWidth, height: 32)
        #else
            let cellSize = CGSize(width: 320, height: 60)
            let buttonSize = CGSize(width: 320 - buttonWidth, height: 60)
        #endif
        
        XCTAssertEqualWithAccuracy(cell?.frame, CGRect(origin: CGPoint.zero, size: cellSize), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertEqualWithAccuracy(cell?.label.frame, CGRect(origin: CGPoint.zero, size: buttonSize), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    func testLabelWithButtonEdgeInsets() {
        brickCollectionView.registerNib(LabelBrickNibs.Button, forBrickWithIdentifier: LabelBrickIdentifier)

        
        let cell = setupLabelBrick("Hello World", configureCellBlock: { cell in
            XCTAssertNotNil(cell.button)
            cell.button?.setTitle("BUTTON", forState: .Normal)
            cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            cell.button?.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
        })

        XCTAssertNotNil(cell?.button)
        
        let buttonWidth = cell?.button?.frame.size.width ?? 61
        
        XCTAssertEqual(cell?.button?.titleLabel?.text, "BUTTON")
        
        #if os(iOS)
            let cellSize = CGSize(width: 320, height: 42)
            let buttonSize = CGSize(width: 320 - buttonWidth - 10, height: 32)
        #else
            let cellSize = CGSize(width: 320, height: 70)
            let buttonSize = CGSize(width: 320 - buttonWidth - 10, height: 60)
        #endif
        
        XCTAssertEqualWithAccuracy(cell?.frame, CGRect(origin: CGPoint.zero, size: cellSize), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertEqualWithAccuracy(cell?.label.frame, CGRect(origin: CGPoint(x: 5.0, y: 5.0), size: buttonSize), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    func testLabelDelegate() {
        brickCollectionView.registerNib(LabelBrickNibs.Button, forBrickWithIdentifier: LabelBrickIdentifier)

        let delegate = FixedLabelDelegate()
        let cell = setupSection(LabelBrick(LabelBrickIdentifier, dataSource: FixedLabelDataSource(), delegate: delegate))

        // Ideally cell?.button?.sendActionsForControlEvents(.TouchUpInside) is called, but this doesn't work in XCTests
        cell?.buttonTapped(cell!.button!)
        XCTAssertTrue(delegate.buttonTouched)
    }

}

class FixedLabelDataSource: LabelBrickCellDataSource {
    func configureLabelBrickCell(cell: LabelBrickCell) {
    }
}

class FixedLabelDelegate: LabelBrickCellDelegate {
    var buttonTouched = false
    func buttonTouchedForLabelBrickCell(cell: LabelBrickCell) {
        buttonTouched = true
    }
    
}

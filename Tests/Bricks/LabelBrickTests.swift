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

    fileprivate let LabelBrickIdentifier = "LabelBrickIdentifier"

    var brickCollectionView: BrickCollectionView!
    var labelBrick: LabelBrick!

    override func setUp() {
        super.setUp()

        brickCollectionView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    func setupLabelBrickWithModel(_ model: LabelBrickCellModel) -> LabelBrickCell? {
        return setupSection(LabelBrick(LabelBrickIdentifier, dataSource: model))
    }

    func setupLabelBrick(_ text: String, configureCellBlock: ConfigureLabelBlock? = nil) -> LabelBrickCell? {
        return setupSection(LabelBrick(LabelBrickIdentifier, text: text, configureCellBlock: { cell in
            cell.label.font = UIFont(name: "Avenir-Medium", size: 14)
            configureCellBlock?(cell)
            }))
    }

    func setupSection(_ labelBrick: LabelBrick) -> LabelBrickCell? {
        self.labelBrick = labelBrick
        let section = BrickSection(bricks: [
            labelBrick
            ])
        brickCollectionView.setupSectionAndLayout(section)

        return labelCell
    }

    var labelCell: LabelBrickCell? {
        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? LabelBrickCell
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
        XCTAssertEqual(cell?.backgroundColor, UIColor.clear)
        XCTAssertEqual(cell?.label.backgroundColor, UIColor.clear)

        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: 0, width: 320, height: 20), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertEqual(cell?.label.frame, CGRect(x: 0, y: 0, width: 320, height: 20), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
        
    }

    func testLabelBrickMultiLine() {
        let cell = setupLabelBrick("Hello World\nHello World")

        XCTAssertEqual(cell?.label.text, "Hello World\nHello World")
        
        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: 0, width: 320, height: 39), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertEqual(cell?.label.frame, CGRect(x: 0, y: 0, width: 320, height: 39), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    func testLabelBrickEdgeInsets() {
        let cell = setupLabelBrick("Hello World", configureCellBlock: { cell in
            cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 10)
            })

        XCTAssertEqual(cell?.topSpaceConstraint?.constant, 5)
        XCTAssertEqual(cell?.leftSpaceConstraint?.constant, 5)
        XCTAssertEqual(cell?.bottomSpaceConstraint?.constant, 10)
        XCTAssertEqual(cell?.rightSpaceConstraint?.constant, 10)

        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: 0, width: 320, height: 35), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertEqual(cell?.label.frame, CGRect(x: 5, y: 5, width: 305, height: 20), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    func testLabelBrickEdgeInsetsMultiLine() {
        let cell = setupLabelBrick("Hello World\nHello World", configureCellBlock: { cell in
            cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 10)
            })

        guard let cellFrame = cell?.frame, let labelFrame = cell?.label.frame else {
            XCTAssertEqual(cell?.frame, CGRect(x: 0, y: 0, width: 320, height: 54))
            XCTAssertEqual(cell?.label.frame, CGRect(x: 0, y: 0, width: 305, height: 39))
            return
        }
        
        XCTAssertEqual(cellFrame, CGRect(x: 0, y: 0, width: 320, height: 54), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertEqual(labelFrame, CGRect(x: 5, y: 5, width: 305, height: 39), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
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
        let cell = setupLabelBrickWithModel(LabelBrickCellModel(text: "Hello World", textColor: UIColor.blue))
        XCTAssertEqual(cell?.label.textColor, UIColor.blue)
    }

    func testLabelWithDecorationImageBrickCellModelWithWrongNib() {
        let image = UIImage(named: "chevron", in: LabelBrick.bundle, compatibleWith: nil)!
        let cell = setupLabelBrickWithModel(LabelWithDecorationImageBrickCellModel(text: "Hello World", image: image))
        XCTAssertNil(cell?.imageView?.image)
    }

    func testLabelWithDecorationImageBrickCellModel() {
        brickCollectionView.registerNib(LabelBrickNibs.Image, forBrickWithIdentifier: LabelBrickIdentifier)
        let image = UIImage(named: "chevron", in: LabelBrick.bundle, compatibleWith: nil)!
        let cell = setupLabelBrickWithModel(LabelWithDecorationImageBrickCellModel(text: "Hello World", image: image))
        XCTAssertEqual(cell?.imageView?.image, image)
    }

    func testLabelImage() {
        brickCollectionView.registerNib(LabelBrickNibs.Image, forBrickWithIdentifier: LabelBrickIdentifier)
        let image = UIImage(named: "chevron", in: LabelBrick.bundle, compatibleWith: nil)!
        let cell = setupLabelBrickWithModel(LabelWithDecorationImageBrickCellModel(text: "Hello World", image: image))
        XCTAssertEqual(cell?.imageView?.image, image)
    }

    func testLabelWithButton() {
        brickCollectionView.registerNib(LabelBrickNibs.Button, forBrickWithIdentifier: LabelBrickIdentifier)
        
        let cell = setupLabelBrick("Hello World", configureCellBlock: { cell in
            XCTAssertNotNil(cell.button)
            cell.button?.setTitle("Button", for: .normal)
            cell.button?.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
        })
        
        XCTAssertNotNil(cell?.button)
        XCTAssertEqual(cell?.button?.titleLabel?.text, "Button")
        
        let buttonWidth = cell?.button?.frame.size.width ?? 61
        
        #if os(iOS)
            let cellSize = CGSize(width: 320, height: 32)
            let buttonSize = CGSize(width: 320 - buttonWidth, height: 32)
        #else
            let cellSize = CGSize(width: 320, height: 60)
            let buttonSize = CGSize(width: 320 - buttonWidth, height: 60)
        #endif
        
        XCTAssertEqual(cell?.frame, CGRect(origin: CGPoint.zero, size: cellSize), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertEqual(cell?.label.frame, CGRect(origin: CGPoint.zero, size: buttonSize), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    func testLabelWithButtonEdgeInsets() {
        brickCollectionView.registerNib(LabelBrickNibs.Button, forBrickWithIdentifier: LabelBrickIdentifier)

        
        let cell = setupLabelBrick("Hello World", configureCellBlock: { cell in
            XCTAssertNotNil(cell.button)
            cell.button?.setTitle("Button", for: UIControlState())
            cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            cell.button?.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
        })

        XCTAssertNotNil(cell?.button)
        
        let buttonWidth = cell?.button?.frame.size.width ?? 61
        
        XCTAssertEqual(cell?.button?.titleLabel?.text, "Button")
        
        #if os(iOS)
            let cellSize = CGSize(width: 320, height: 42)
            let buttonSize = CGSize(width: 320 - buttonWidth - 10, height: 32)
        #else
            let cellSize = CGSize(width: 320, height: 70)
            let buttonSize = CGSize(width: 320 - buttonWidth - 10, height: 60)
        #endif
        
        XCTAssertEqual(cell?.frame, CGRect(origin: CGPoint.zero, size: cellSize), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertEqual(cell?.label.frame, CGRect(origin: CGPoint(x: 5.0, y: 5.0), size: buttonSize), accuracy: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    func testLabelDelegate() {
        brickCollectionView.registerNib(LabelBrickNibs.Button, forBrickWithIdentifier: LabelBrickIdentifier)

        let delegate = FixedLabelDelegate()
        let cell = setupSection(LabelBrick(LabelBrickIdentifier, dataSource: FixedLabelDataSource(), delegate: delegate))

        // Ideally cell?.button?.sendActionsForControlEvents(.TouchUpInside) is called, but this doesn't work in XCTests
        cell?.buttonTapped(cell!.button!)
        XCTAssertTrue(delegate.buttonTouched)
    }

    func testOverrideContentSource() {
        brickCollectionView.registerNib(LabelBrickNibs.Button, forBrickWithIdentifier: LabelBrickIdentifier)

        let overrideSource = MockOverrideContentSource()
        let labelBrick = LabelBrick(text: "Hello World")
        labelBrick.overrideContentSource = overrideSource
        let _ = setupSection(labelBrick)

        XCTAssertTrue(overrideSource.didCallResetContent)
        XCTAssertTrue(overrideSource.didCallOverrideContent)
    }

    func testLabelResetsBeforeReusing() {
        brickCollectionView.registerBrickClass(LabelBrick.self)

        let model = LabelBrickCellModel(text: "TEST", textColor: .red) { cell in
            cell.label.textAlignment = .right
            cell.label.isHidden = true
            cell.label.attributedText = NSAttributedString()
            cell.label.numberOfLines = 1
            cell.isHidden = true
            cell.accessoryView = UIView()
            cell.backgroundColor = .green
            cell.label.backgroundColor = .red
            cell.label.text = "TEST"
            cell.accessoryView = UIView()
        }

        let section = BrickSection(bricks: [
            LabelBrick("labelBrick", dataSource: model),
            ])

        brickCollectionView.setSection(section)
        brickCollectionView.layoutSubviews()

        let cell = brickCollectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? LabelBrickCell
        cell?.updateContent()
        cell?.layoutIfNeeded()

        XCTAssertEqual(cell?.label.numberOfLines, 1)
        XCTAssertEqual(cell?.label.backgroundColor, .red)
        XCTAssertEqual(cell?.backgroundColor, .green)
        XCTAssertNotNil(cell?.accessoryView)
        XCTAssertNotNil(cell?.label.attributedText)
        XCTAssertEqual(cell?.label.text, "TEST")
        XCTAssertEqual(cell?.label.textAlignment, .right)

        cell?.prepareForReuse()

        XCTAssertEqual(cell?.label.textAlignment, .natural)
        XCTAssertEqual(cell?.label.numberOfLines, 0)
        XCTAssertEqual(cell?.label.backgroundColor, .clear)
        XCTAssertEqual(cell?.backgroundColor, .clear)
        XCTAssertNil(cell?.accessoryView)
        XCTAssertNil(cell?.label.attributedText)
        XCTAssertNil(cell?.label.text)
    }
}

class FixedLabelDataSource: LabelBrickCellDataSource {
    func configureLabelBrickCell(_ cell: LabelBrickCell) {
    }
}

class FixedLabelDelegate: LabelBrickCellDelegate {
    var buttonTouched = false
    func buttonTouchedForLabelBrickCell(_ cell: LabelBrickCell) {
        buttonTouched = true
    }
    
}

class MockOverrideContentSource: OverrideContentSource {
    var didCallOverrideContent = false
    var didCallResetContent = false

    func overrideContent(for brickCell: BrickCell) {
        didCallOverrideContent = true
    }

    func resetContent(for brickCell: BrickCell) {
        didCallResetContent = true
    }
}

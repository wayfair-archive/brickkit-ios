//
//  ButtonBrickTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/6/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class ButtonBrickTests: XCTestCase {
    
    private let ButtonBrickIdentifier = "ButtonBrickIdentifier"

    var brickCollectionView: BrickCollectionView!
    var buttonBrick: ButtonBrick!

    override func setUp() {
        super.setUp()

        brickCollectionView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }
    func noOp() {
        // no op for mock gesture
    }

    func setupButtonBrickWithModel(model: ButtonBrickCellModel) -> ButtonBrickCell? {
        return setupSection(ButtonBrick(ButtonBrickIdentifier, dataSource: model))
    }

    func setupButtonBrick(title: String, configureButtonBlock: ConfigureButtonBlock? = nil) -> ButtonBrickCell? {
        return setupSection(ButtonBrick(ButtonBrickIdentifier, title: title, configureButtonBlock: configureButtonBlock))
    }

    func setupSection(buttonBrick: ButtonBrick) -> ButtonBrickCell? {
        brickCollectionView.registerBrickClass(ButtonBrick.self)
        self.buttonBrick = buttonBrick
        let section = BrickSection(bricks: [
            buttonBrick
            ])
        brickCollectionView.setSection(section)
        brickCollectionView.layoutSubviews()

        return buttonCell
    }

    var buttonCell: ButtonBrickCell? {
        let cell = brickCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? ButtonBrickCell
        cell?.layoutIfNeeded()
        return cell
    }

    func testButtonBrick() {
        let cell = setupButtonBrick("Hello World")

        XCTAssertEqual(cell?.button.titleLabel?.text, "Hello World")

        XCTAssertEqual(cell?.topSpaceConstraint?.constant, 0)
        XCTAssertEqual(cell?.bottomSpaceConstraint?.constant, 0)
        XCTAssertEqual(cell?.leftSpaceConstraint?.constant, 0)
        XCTAssertEqual(cell?.rightSpaceConstraint?.constant, 0)
        
        let buttonSize = CGSize(width: 320, height: 30)
        XCTAssertEqual(cell?.frame, CGRect(origin: CGPoint.zero, size: buttonSize))
        XCTAssertEqual(cell?.button.frame, CGRect(origin: CGPoint.zero, size: buttonSize))

    }

    func testButtonBrickMultiLine() {
        let cell = setupButtonBrick("Hello World\nHello World")

        XCTAssertEqual(cell?.button.titleLabel?.text, "Hello World\nHello World")

        let buttonSize = CGSize(width: 320, height: 48)
        XCTAssertEqual(cell?.frame, CGRect(origin: CGPoint.zero, size: buttonSize))
        XCTAssertEqual(cell?.button.frame, CGRect(origin: CGPoint.zero, size: buttonSize))
    }

    func testButtonBrickEdgeInsets() {
        let cell = setupButtonBrick("Hello World", configureButtonBlock: { cell in
            cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 10)
        })

        XCTAssertEqual(cell?.topSpaceConstraint?.constant, 5)
        XCTAssertEqual(cell?.leftSpaceConstraint?.constant, 5)
        XCTAssertEqual(cell?.bottomSpaceConstraint?.constant, 10)
        XCTAssertEqual(cell?.rightSpaceConstraint?.constant, 10)

        let cellSize = CGSize(width: 320, height: 45)
        let buttonSize = CGSize(width: 305, height: 30)

        XCTAssertEqual(cell?.frame, CGRect(origin: CGPoint.zero, size: cellSize))
        XCTAssertEqual(cell?.button.frame, CGRect(origin: CGPoint(x: 5, y: 5), size: buttonSize))
    }

    func testButtonBrickEdgeInsetsMultiLine() {
        let cell = setupButtonBrick("Hello World\nHello World", configureButtonBlock: { cell in
            cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 10)
        })

        let cellSize = CGSize(width: 320, height: 63)
        let buttonSize = CGSize(width: 305, height: 48)

        XCTAssertEqual(cell?.frame, CGRect(origin: CGPoint.zero, size: cellSize))
        XCTAssertEqual(cell?.button.frame, CGRect(origin: CGPoint(x: 5, y: 5), size: buttonSize))
    }

    func testChangeText() {
        var cell = setupButtonBrick("Hello World")

        XCTAssertEqual(cell?.button.titleLabel?.text, "Hello World")

        buttonBrick.title = "World Hello"
        XCTAssertEqual(buttonBrick.title, "World Hello")

        brickCollectionView.reloadBricksWithIdentifiers([ButtonBrickIdentifier], shouldReloadCell: false)
        cell = buttonCell
        XCTAssertEqual(cell?.button.titleForState(.Normal), "World Hello")

        buttonBrick.title = "Hello World"
        brickCollectionView.reloadBricksWithIdentifiers([ButtonBrickIdentifier], shouldReloadCell: true)
        brickCollectionView.layoutIfNeeded()
        cell = buttonCell
        XCTAssertEqual(cell?.button.titleLabel?.text, "Hello World")
    }

    func testSetupButtonBlock() {
        let expectation = expectationWithDescription("Should call setup button block")

        let model = ButtonBrickCellModel(title: "Hello World", configureButtonBlock: { (cell) in
            expectation.fulfill()
        })
        setupButtonBrickWithModel(model)

        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testButtonChangeText() {
        let buttonBrick = ButtonBrick(title: "Hello World")
        buttonBrick.title = "World Hello"
        XCTAssertEqual(buttonBrick.title, "World Hello")
    }

    func testButtonConfigureCellBlock() {
        let configureButtonBlock: ConfigureButtonBlock = { cell in
        }
        let buttonBrick = ButtonBrick(title: "Hello World")
        buttonBrick.configureButtonBlock = configureButtonBlock
        XCTAssertNotNil(buttonBrick.configureButtonBlock)
    }

    func testButtonTextShouldBeEmptyStringWhenSettingToNil() {
        let buttonBrick = ButtonBrick(title: "Hello World")
        buttonBrick.title = nil
        XCTAssertEqual(buttonBrick.title, "")
    }

    func testCantSetTextOfButtonBrickWithWrongDataSource() {
        expectFatalError {
            let buttonBrick = ButtonBrick(dataSource: FixedButtonDataSource())
            buttonBrick.title = "Hello World"
        }
    }

    func testCantGetTextOfButtonBrickWithWrongDataSource() {
        expectFatalError {
            let buttonBrick = ButtonBrick(dataSource: FixedButtonDataSource())
            let _ = buttonBrick.title
        }
    }

    func testCantSetConfigureCellBlockOfButtonBrickWithWrongDataSource() {
        expectFatalError {
            let buttonBrick = ButtonBrick(dataSource: FixedButtonDataSource())
            buttonBrick.configureButtonBlock = { cell in
            }
        }
    }

    func testCantGetConfigureCellBlockOfButtonBrickWithWrongDataSource() {
        expectFatalError {
            let buttonBrick = ButtonBrick(dataSource: FixedButtonDataSource())
            let _ = buttonBrick.configureButtonBlock
        }
    }

    func testButtonBrickChevronEdgeInsets() {
        brickCollectionView.registerNib(ButtonBrickNibs.Chevron, forBrickWithIdentifier: ButtonBrickIdentifier)
        let cell = setupButtonBrick("Hello World", configureButtonBlock: { cell in
            cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 10)
        })

        XCTAssertEqual(cell?.topSpaceConstraint?.constant, 5)
        XCTAssertEqual(cell?.leftSpaceConstraint?.constant, 5)
        XCTAssertEqual(cell?.bottomSpaceConstraint?.constant, 10)
        XCTAssertEqual(cell?.rightSpaceConstraint?.constant, 10)

        #if os(iOS)
            let cellSize = CGSize(width: 320, height: 45)
            let buttonSize = CGSize(width: 320 - 15 - cell!.rightImage!.frame.width, height: 30)
        #else
            let cellSize = CGSize(width: 320, height: 101)
            let buttonSize = CGSize(width: 320 - 15 - cell!.rightImage!.frame.width, height: 86)
        #endif
        
        XCTAssertEqual(cell?.frame, CGRect(origin: CGPoint.zero, size: cellSize))
        XCTAssertEqual(cell?.button.frame, CGRect(origin: CGPoint(x: 5, y: 5), size: buttonSize))
    }

    func testButtonBrickChevronEdgeInsetsMultiLine() {
        brickCollectionView.registerNib(ButtonBrickNibs.Chevron, forBrickWithIdentifier: ButtonBrickIdentifier)
        let cell = setupButtonBrick("Hello World\nHello World", configureButtonBlock: { cell in
            cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 10)
        })

        #if os(iOS)
            let cellSize = CGSize(width: 320, height: 63)
            let buttonSize = CGSize(width: 320 - 15 - cell!.rightImage!.frame.width, height: 48)
        #else
            let cellSize = CGSize(width: 320, height: 147)
            let buttonSize = CGSize(width: 320 - 15 - cell!.rightImage!.frame.width, height: 132)
        #endif
        
        XCTAssertEqual(cell?.frame, CGRect(origin: CGPoint.zero, size: cellSize))
        XCTAssertEqual(cell?.button.frame, CGRect(origin: CGPoint(x: 5, y: 5), size: buttonSize))
    }

    func testButtonDelegate() {
        let delegate = FixedButtonDelegate()
        let cell = setupSection(ButtonBrick(ButtonBrickIdentifier, dataSource: FixedButtonDataSource(), delegate: delegate))
        
        // Ideally cell?.button?.sendActionsForControlEvents(.TouchUpInside) is called, but this doesn't work in XCTests
        cell?.didTapButton(cell!.button!)
        XCTAssertTrue(delegate.buttonTouched)
    }

    func testBrickCellTapDelegate() {
        let tapDelegate = MockBrickCellTapDelegate()
        let delegate = FixedButtonDelegate()
        let brick = ButtonBrick(ButtonBrickIdentifier, dataSource: FixedButtonDataSource(), delegate: delegate)
        brick.brickCellTapDelegate = tapDelegate
        let cell = setupSection(brick)

        cell?.didTapCell()
        XCTAssertTrue(tapDelegate.didTapBrickCellCalled)
    }

    func testNilBrickCellTapDelegate() {
        let tapDelegate = MockBrickCellTapDelegate()
        let delegate = FixedButtonDelegate()
        let cell = setupSection(ButtonBrick(ButtonBrickIdentifier, dataSource: FixedButtonDataSource(), delegate: delegate))

        XCTAssertNil(cell?.gestureRecognizers)

        cell?.didTapCell()
        XCTAssertFalse(tapDelegate.didTapBrickCellCalled)
    }

    func testMultipleBrickCellTapDelegate() {
        let tapDelegate = MockBrickCellTapDelegate()
        let delegate = FixedButtonDelegate()
        let brick = ButtonBrick(ButtonBrickIdentifier, dataSource: FixedButtonDataSource(), delegate: delegate)
        brick.brickCellTapDelegate = tapDelegate

        let cell = setupSection(brick)

        for _ in 0..<10 {
            brickCollectionView.reloadData()
        }

        XCTAssertTrue(cell?.gestureRecognizers?.count == 1)
    }
}

class FixedButtonDataSource: ButtonBrickCellDataSource {
    func configureButtonBrick(cell: ButtonBrickCell) {
    }
}

class FixedButtonDelegate: ButtonBrickCellDelegate {
    var buttonTouched = false
    func didTapOnButtonForButtonBrickCell(cell: ButtonBrickCell) {
        buttonTouched = true
    }

}

class MockBrickCellTapDelegate: NSObject, BrickCellTapDelegate {
    var didTapBrickCellCalled = false

    func didTapBrickCell(brickCell: BrickCell) {
        didTapBrickCellCalled = true
    }

}


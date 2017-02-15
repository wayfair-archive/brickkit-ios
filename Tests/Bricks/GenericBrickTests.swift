//
//  GenericBrickTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 1/23/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

private let GenericLabelBrickIdentifier = "GenericLabelBrick"
private let GenericButtonBrickIdentifier = "GenericButtonBrick"

class GenericBrickTests: XCTestCase {
    var brickCollectionView: BrickCollectionView!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        brickCollectionView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    fileprivate func firstCellForIdentifier<T: BrickCell>(_ identifier: String) -> T? {
        guard let indexPath = brickCollectionView.indexPathsForBricksWithIdentifier(identifier).first else {
            return nil
        }
        return brickCollectionView.cellForItem(at: indexPath) as? T
    }

    func testGenericBrickWithLabel() {
        brickCollectionView.setupSingleBrickAndLayout(GenericBrick<UILabel>(GenericLabelBrickIdentifier, width: .ratio(ratio: 1), height: .fixed(size: 50)) { label, view in
            })

        let cell: GenericBrickCell? = firstCellForIdentifier(GenericLabelBrickIdentifier)

        XCTAssertNotNil(cell)

        XCTAssertTrue(cell!.genericContentView is UILabel)
        XCTAssertTrue(cell!.contentView.subviews.first is UILabel)
    }

    func testGenericBrickWithButton() {
        brickCollectionView.setupSingleBrickAndLayout(GenericBrick<UIButton>(GenericButtonBrickIdentifier, size: BrickSize(width: .ratio(ratio: 1), height: .fixed(size: 50))) { button, view in
            })

        let cell: GenericBrickCell? = firstCellForIdentifier(GenericButtonBrickIdentifier)

        XCTAssertNotNil(cell)

        XCTAssertTrue(cell!.genericContentView is UIButton)
        XCTAssertTrue(cell!.contentView.subviews.first is UIButton)
    }

    func testThatLabelIsInitialized() {
        let text = "Hello World"
        brickCollectionView.setupSingleBrickAndLayout(GenericBrick<UILabel>(GenericLabelBrickIdentifier, size: BrickSize(width: .ratio(ratio: 1), height: .fixed(size: 50))) { label, view in
            label.text = text
            })

        let cell: GenericBrickCell? = firstCellForIdentifier(GenericLabelBrickIdentifier)

        let label = cell!.genericContentView as! UILabel
        XCTAssertEqual(label.text, text)
        XCTAssertEqual(label.frame, CGRect(x: 0, y: 0, width: 320, height: 50))
    }

    func testThatLabelHasEdgeInsets() {
        let genericBrick = GenericBrick<UILabel>(GenericLabelBrickIdentifier, size: BrickSize(width: .ratio(ratio: 1), height: .fixed(size: 50))) { label, view in
            view.edgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
        }
        brickCollectionView.setupSingleBrickAndLayout(genericBrick)

        let cell: GenericBrickCell? = firstCellForIdentifier(GenericLabelBrickIdentifier)
        cell?.layoutIfNeeded()

        let label = cell!.genericContentView as! UILabel
        XCTAssertEqual(cell?.contentView.frame, CGRect(x: 0, y: 0, width: 320, height: 50))
        XCTAssertEqual(label.frame, CGRect(x: 10, y: 5, width: 290, height: 30))
    }

    func testThatRepeatCountWorks() {
        let genericBrick = GenericBrick<UILabel>(GenericLabelBrickIdentifier, size: BrickSize(width: .ratio(ratio: 1), height: .fixed(size: 50))) { label, cell in
            label.text = "LABEL " + String(cell.index)
        }

        let section = BrickSection(bricks: [genericBrick])
        let repeatCount = FixedRepeatCountDataSource(repeatCountHash: [GenericLabelBrickIdentifier: 5])
        section.repeatCountDataSource = repeatCount
        brickCollectionView.setupSectionAndLayout(section)

        let indexPaths = brickCollectionView.indexPathsForBricksWithIdentifier(GenericLabelBrickIdentifier)
        XCTAssertEqual(indexPaths.count, 5)

        let label0 = (brickCollectionView.cellForItem(at: indexPaths[0]) as! GenericBrickCell).genericContentView as! UILabel
        XCTAssertEqual(label0.text, "LABEL 0")
        let label1 = (brickCollectionView.cellForItem(at: indexPaths[1]) as! GenericBrickCell).genericContentView as! UILabel
        XCTAssertEqual(label1.text, "LABEL 1")
        let label2 = (brickCollectionView.cellForItem(at: indexPaths[2]) as! GenericBrickCell).genericContentView as! UILabel
        XCTAssertEqual(label2.text, "LABEL 2")
        let label3 = (brickCollectionView.cellForItem(at: indexPaths[3]) as! GenericBrickCell).genericContentView as! UILabel
        XCTAssertEqual(label3.text, "LABEL 3")
        let label4 = (brickCollectionView.cellForItem(at: indexPaths[4]) as! GenericBrickCell).genericContentView as! UILabel
        XCTAssertEqual(label4.text, "LABEL 4")
    }

    func testThatBackgroundColorIsNotReset() {
        brickCollectionView.setupSingleBrickAndLayout(GenericBrick<UILabel>(GenericLabelBrickIdentifier, width: .ratio(ratio: 1), height: .fixed(size: 50), backgroundColor: UIColor.orange) { label, view in
                label.backgroundColor = UIColor.red
            })

        let cell: GenericBrickCell? = firstCellForIdentifier(GenericLabelBrickIdentifier)

        XCTAssertEqual(cell?.genericContentView?.backgroundColor, UIColor.red)
        XCTAssertEqual(cell?.contentView.backgroundColor, UIColor.orange)
    }


}

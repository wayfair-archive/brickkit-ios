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
    var cell: GenericBrickCell!

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
}

class GenericBrickTestUILabel: GenericBrickTests {

    override func setUp() {
        super.setUp()

        brickCollectionView.setupSingleBrickAndLayout(GenericBrick<UILabel>(GenericLabelBrickIdentifier, width: .ratio(ratio: 1), height: .fixed(size: 50)) { label, view in
            label.text = "Hello World"
        })
        cell = firstCellForIdentifier(GenericLabelBrickIdentifier)
    }

    func testThatCellIsNotNil() {
        XCTAssertNotNil(cell)
    }

    func testThatTheContentViewIsAUILabel() {
        XCTAssertTrue(cell!.genericContentView is UILabel)
    }

    func testThatTheFistSubviewOfTheContentViewIsAUILabel() {
        XCTAssertTrue(cell!.contentView.subviews.first is UILabel)
    }

    func testThatTheLabelHasTheTextSetInTheConfigureView() {
        let label = cell!.genericContentView as! UILabel
        XCTAssertEqual(label.text, "Hello World")
    }

    func testThatTheLabelHasTheSizeOfTheWrappedLabel() {
        let label = cell!.genericContentView as! UILabel
        XCTAssertEqual(label.frame, CGRect(x: 0, y: 0, width: 320, height: 50))
    }
}

class GenericBrickTestHeight: GenericBrickTests {
    
    override func setUp() {
        super.setUp()
        // UIView has no intrinsic content size
        brickCollectionView.setupSingleBrickAndLayout(GenericBrick<UIView>(GenericButtonBrickIdentifier, size: BrickSize(width: .ratio(ratio: 1), height: .fixed(size: 50))) { button, view in
        })
        cell = firstCellForIdentifier(GenericButtonBrickIdentifier)
    }
    
    func testHeight() {
        XCTAssertEqual(CGFloat(0), cell.heightForBrickView(withWidth: 200))
        cell.customHeightProvider = { width in
            return 100
        }
        XCTAssertEqual(CGFloat(100), cell.heightForBrickView(withWidth: 200))
    }
}

class GenericBrickTestUILabelWithEdgeInsets: GenericBrickTests {

    override func setUp() {
        super.setUp()

        brickCollectionView.setupSingleBrickAndLayout(GenericBrick<UILabel>(GenericLabelBrickIdentifier, width: .ratio(ratio: 1), height: .fixed(size: 50)) { label, view in
            label.text = "Hello World"
            view.edgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
        })
        cell = firstCellForIdentifier(GenericLabelBrickIdentifier)
        cell.layoutIfNeeded()
    }

    func testThatTheLabelHasTheSizeOfTheWrappedLabel() {
        let label = cell!.genericContentView as! UILabel
        XCTAssertEqual(label.frame, CGRect(x: 10, y: 5, width: 290, height: 30))
    }

    func testThatTheCellSizeHasTheSizeOfTheLabelPlusEdgeInsets() {
        XCTAssertEqual(cell.contentView.frame, CGRect(x: 0, y: 0, width: 320, height: 50))
    }
}

class GenericBrickTestUIButton: GenericBrickTests {

    override func setUp() {
        super.setUp()

        brickCollectionView.setupSingleBrickAndLayout(GenericBrick<UIButton>(GenericButtonBrickIdentifier, size: BrickSize(width: .ratio(ratio: 1), height: .fixed(size: 50))) { button, view in
        })
        cell = firstCellForIdentifier(GenericButtonBrickIdentifier)
    }

    func testThatCellIsNotNil() {
        XCTAssertNotNil(cell)
    }

    func testThatTheContentViewIsAUIButton() {
        XCTAssertTrue(cell!.genericContentView is UIButton)
    }

    func testThatTheFistSubviewOfTheContentViewIsAUIButton() {
        XCTAssertTrue(cell!.contentView.subviews.first is UIButton)
    }

}

/// Test to verify the case when the brick of the GenericBrickCell is not a GenericBrick
/// Technically this should never happen, but the cases should be covered
class GenericBrickTestWrongBrick: XCTestCase {
    var genericBrickCell: GenericBrickCell!
    override func setUp() {
        super.setUp()

        genericBrickCell = GenericBrickCell(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        genericBrickCell.setContent(Brick(), index: 0, collectionIndex: 0, collectionIdentifier: nil)
    }

    func testThatGenericContentViewIsNil() {
        XCTAssertNil(genericBrickCell.genericContentView)
    }

    func testThatTopConstraintIsNil() {
        XCTAssertNil(genericBrickCell.topSpaceConstraint)
    }

    func testThatBottomConstraintIsNil() {
        XCTAssertNil(genericBrickCell.bottomSpaceConstraint)
    }

    func testThatLeftConstraintIsNil() {
        XCTAssertNil(genericBrickCell.leftSpaceConstraint)
    }

    func testThatRightConstraintIsNil() {
        XCTAssertNil(genericBrickCell.rightSpaceConstraint)
    }
}

/// Test to verify the support of repeat count with a GenericBrick
class GenericBrickTestRepeatCount: GenericBrickTests {
    var indexPaths: [IndexPath]!

    override func setUp() {
        super.setUp()

        let genericBrick = GenericBrick<UILabel>(GenericLabelBrickIdentifier, size: BrickSize(width: .ratio(ratio: 1), height: .fixed(size: 50))) { label, cell in
            label.text = "LABEL " + String(cell.index)
        }

        let section = BrickSection(bricks: [genericBrick])
        let repeatCount = FixedRepeatCountDataSource(repeatCountHash: [GenericLabelBrickIdentifier: 5])
        section.repeatCountDataSource = repeatCount
        brickCollectionView.setupSectionAndLayout(section)

        indexPaths = brickCollectionView.indexPathsForBricksWithIdentifier(GenericLabelBrickIdentifier).sorted(by: { (first, other) in
            return first.section < other.section || first.item < other.item
        })
    }

    func testThatTheIndexPathCountIsTheSameAsTheRepeatCount() {
        XCTAssertEqual(indexPaths.count, 5)
    }

    func testThatLabel0HasLabel0Text() {
        let label0 = (brickCollectionView.cellForItem(at: indexPaths[0]) as! GenericBrickCell).genericContentView as! UILabel
        XCTAssertEqual(label0.text, "LABEL 0")
    }

    func testThatLabel1HasLabel1Text() {
        let label1 = (brickCollectionView.cellForItem(at: indexPaths[1]) as! GenericBrickCell).genericContentView as! UILabel
        XCTAssertEqual(label1.text, "LABEL 1")
    }

    func testThatLabel2HasLabel2Text() {
        let label2 = (brickCollectionView.cellForItem(at: indexPaths[2]) as! GenericBrickCell).genericContentView as! UILabel
        XCTAssertEqual(label2.text, "LABEL 2")
    }

    func testThatLabel3HasLabel3Text() {
        let label3 = (brickCollectionView.cellForItem(at: indexPaths[3]) as! GenericBrickCell).genericContentView as! UILabel
        XCTAssertEqual(label3.text, "LABEL 3")
    }

    func testThatLabel4HasLabel4Text() {
        let label4 = (brickCollectionView.cellForItem(at: indexPaths[4]) as! GenericBrickCell).genericContentView as! UILabel
        XCTAssertEqual(label4.text, "LABEL 4")
    }

}

/// Test to verify setting the backgroundColor of the genericContentView as well as the contentView itself
/// This test was added after finding some raise condition between the `configureView`-call and resetting the backgroundColor in `GenericBrickCell`
class GenericBrickTestBackgroundColor: GenericBrickTests {

    override func setUp() {
        super.setUp()

        brickCollectionView.setupSingleBrickAndLayout(GenericBrick<UILabel>(GenericLabelBrickIdentifier, width: .ratio(ratio: 1), height: .fixed(size: 50), backgroundColor: UIColor.orange) { label, view in
            label.backgroundColor = UIColor.red
        })
        cell = firstCellForIdentifier(GenericLabelBrickIdentifier)
    }

    func testThatTheLabelBackgroundColorIsSetToRed() {
        XCTAssertEqual(cell.genericContentView?.backgroundColor, UIColor.red)
    }

    func testThatTheCellBackgroundColorIsSetToRed() {
        XCTAssertEqual(cell.contentView.backgroundColor, UIColor.orange)
    }

    func testThatWhenReloadingTheBackgroundColorIsStillOrange() {
        brickCollectionView.reloadBricksWithIdentifiers([GenericLabelBrickIdentifier])
        cell = firstCellForIdentifier(GenericLabelBrickIdentifier)
        XCTAssertEqual(cell.contentView.backgroundColor, UIColor.orange)
    }

}

/// Test to verify adding an `accessoryView`
class GenericBrickTestAccessoryView: GenericBrickTests {
    var label: UILabel!

    override func setUp() {
        super.setUp()

        brickCollectionView.setupSingleBrickAndLayout(GenericBrick<UILabel>(GenericLabelBrickIdentifier, width: .ratio(ratio: 1), height: .fixed(size: 50)) { label, cell in
            let accessoryView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 20)))
            accessoryView.addConstraint(accessoryView.widthAnchor.constraint(equalToConstant: accessoryView.frame.width))
            accessoryView.addConstraint(accessoryView.heightAnchor.constraint(equalToConstant: accessoryView.frame.height))

            accessoryView.backgroundColor = .red
            cell.accessoryView = accessoryView
            self.cell = cell
            self.label = label
        })
        cell.contentView.layoutSubviews()
    }

    func testThatTheAccessoryViewIsAddedToTheContentView() {
        XCTAssertEqual(cell.accessoryView?.superview, cell.contentView)

    }

    func testThatSettingAnAccessoryViewAddsItToTheRight() {
        XCTAssertEqual(cell.accessoryView?.frame, CGRect(origin: CGPoint(x: 220, y: 15), size: CGSize(width: 100, height: 20)))
    }

    func testThatAccessoryIsCenteredVertically() {
        XCTAssertEqual(cell.accessoryView?.frame.origin, CGPoint(x: 220, y: 15))
    }
    
}

/// Test to verify adding an `accessoryView`, but the cell has edgeInsets
class GenericBrickTestAccessoryViewWithEdgeInsets: GenericBrickTests {
    var label: UILabel!

    override func setUp() {
        super.setUp()

        brickCollectionView.setupSingleBrickAndLayout(GenericBrick<UILabel>(GenericLabelBrickIdentifier, width: .ratio(ratio: 1), height: .fixed(size: 50)) { label, cell in
            let accessoryView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 20)))
            accessoryView.addConstraint(accessoryView.widthAnchor.constraint(equalToConstant: accessoryView.frame.width))
            accessoryView.addConstraint(accessoryView.heightAnchor.constraint(equalToConstant: accessoryView.frame.height))

            accessoryView.backgroundColor = .red
            cell.accessoryView = accessoryView
            cell.edgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
            self.cell = cell
            self.label = label
        })
        cell.contentView.layoutSubviews()
    }

    func testThatTheLabelHasTheSizeOfTheWrappedLabel() {
        XCTAssertEqual(label.frame, CGRect(x: 10, y: 5, width: 190, height: 30))
    }

    func testThatTheAccessoryViewHasEdgeInsets() {
        XCTAssertEqual(cell.accessoryView?.frame, CGRect(x: 200, y: 10, width: 100, height: 20))
    }
}

/// Test to verify that the old `accessoryView` is removed from the view when a new one is set
class GenericBrickTestAccessoryViewReplace: GenericBrickTests {
    var label: UILabel!
    var oldAccessoryView: UIView!

    override func setUp() {
        super.setUp()

        brickCollectionView.setupSingleBrickAndLayout(GenericBrick<UILabel>(GenericLabelBrickIdentifier, width: .ratio(ratio: 1), height: .fixed(size: 50)) { label, cell in
            let accessoryView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 20)))
            accessoryView.backgroundColor = .red
            cell.accessoryView = accessoryView
            self.cell = cell
            self.label = label
        })

        oldAccessoryView = cell.accessoryView
        let accessoryView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 20)))
        accessoryView.backgroundColor = .orange
        cell.accessoryView = accessoryView
    }

    func testThatTheOldOneIsRemoved() {
        XCTAssertNil(oldAccessoryView?.superview)
    }

    func testThatAccessoryViewHasNewBackgroundColor() {
        XCTAssertEqual(cell.accessoryView?.backgroundColor, .orange)
    }

}

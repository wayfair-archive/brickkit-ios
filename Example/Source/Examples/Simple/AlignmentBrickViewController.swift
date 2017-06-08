
//
//  AlignmentBrickViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 12/6/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class HorizontalSegmentedControl: SegmentHeaderBrickDataSource {
    static let identifier = "Horizontal"

    var selectedSegmentIndex: Int = 0

    var titles: [String] {
        return ["Left", "Center", "Right", "Justified"]
    }
    
}
class VerticalSegmentedControl: SegmentHeaderBrickDataSource {
    static let identifier = "Vertical"

    var selectedSegmentIndex: Int = 0

    var titles: [String] {
        return ["Top", "Center", "Bottom"]
    }
    
}

class AlignmentBrickViewController: BrickViewController, HasTitle {

    class var brickTitle: String {
        return "Alignment"
    }
    class var subTitle: String {
        return "Example how to use BrickAlignment"
    }

    var brickSection1: BrickSection!
    var brickSection2: BrickSection!
    var brickSection3: BrickSection!

    var horizontalSegmentedControl = HorizontalSegmentedControl()
    var verticalSegmentedControl = VerticalSegmentedControl()

    var horizontalSelectedSegmentIndex: Int = 0 {
        didSet {
        }
    }

    func updateAligments() {
        let horizontalAlignment: BrickHorizontalAlignment
        switch horizontalSegmentedControl.selectedSegmentIndex {
        case 1: horizontalAlignment = .center
        case 2: horizontalAlignment = .right
        case 3: horizontalAlignment = .justified
        default: horizontalAlignment = .left
        }

        let verticalAlignment: BrickVerticalAlignment
        switch verticalSegmentedControl.selectedSegmentIndex {
        case 1: verticalAlignment = .center
        case 2: verticalAlignment = .bottom
        default: verticalAlignment = .top
        }

        let alignment = BrickAlignment(horizontal: horizontalAlignment, vertical: verticalAlignment)
        brickSection1.alignment = alignment
        brickSection2.alignment = alignment
        brickSection3.alignment = alignment

        self.brickCollectionView.invalidateBricks(false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.brickCollectionView.registerBrickClass(LabelBrick.self)
        self.brickCollectionView.registerBrickClass(SegmentHeaderBrick.self)

        brickSection1 = BrickSection(backgroundColor: .brickGray1, bricks: [
            LabelBrick(width: .fixed(size: 70), height: .fixed(size: 100), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .fixed(size: 70), height: .fixed(size: 50), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .fixed(size: 70), height: .fixed(size: 75), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            ], inset: 10)

        brickSection2 = BrickSection(backgroundColor: .brickGray1, bricks: [
            LabelBrick(width: .ratio(ratio: 1/3), height: .fixed(size: 100), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .ratio(ratio: 1/3), height: .fixed(size: 50), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            ], inset: 10)

        brickSection3 = BrickSection(backgroundColor: .brickGray1, bricks: [
            LabelBrick(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 1/3), height: .fixed(size: 100), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            ], inset: 10)

        brickSection3.repeatCountDataSource = self

        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                LabelBrick(text: "Horizontal", configureCellBlock: LabelBrickCell.configure),
                SegmentHeaderBrick(HorizontalSegmentedControl.identifier, dataSource: horizontalSegmentedControl, delegate: self),
                ]),
            BrickSection(bricks: [
                LabelBrick(text: "Vertical", configureCellBlock: LabelBrickCell.configure),
                SegmentHeaderBrick(VerticalSegmentedControl.identifier, dataSource: verticalSegmentedControl, delegate: self),
                ]),
            brickSection1,
            brickSection2,
            brickSection3
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

        self.setSection(section)
    }

}

extension AlignmentBrickViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return 5
        } else {
            return 1
        }
    }
}

extension AlignmentBrickViewController: SegmentHeaderBrickDelegate {
    func segementHeaderBrickCell(cell: SegmentHeaderBrickCell, didSelectIndex index: Int) {
        if cell.brick.identifier == HorizontalSegmentedControl.identifier {
            self.horizontalSegmentedControl.selectedSegmentIndex = index
        } else if cell.brick.identifier == VerticalSegmentedControl.identifier {
            self.verticalSegmentedControl.selectedSegmentIndex = index
        }
        updateAligments()
    }
}


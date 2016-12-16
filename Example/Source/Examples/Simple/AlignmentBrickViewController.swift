//
//  AlignmentBrickViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 12/6/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class AlignmentBrickViewController: BrickViewController {

    override class var title: String {
        return "Alignment"
    }
    override class var subTitle: String {
        return "Example how to use BrickAlignment"
    }

    var brickSection1: BrickSection!
    var brickSection2: BrickSection!
    var brickSection3: BrickSection!

    var selectedSegmentIndex: Int = 0 {
        didSet {
            let alignment: BrickAlignment
            switch selectedSegmentIndex {
            case 1: alignment = .Center
            case 2: alignment = .Right
            case 3: alignment = .Justified
            default: alignment = .Left
            }
            brickSection1.alignment = alignment
            brickSection2.alignment = alignment
            brickSection3.alignment = alignment
            self.brickCollectionView.invalidateBricks()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.brickCollectionView.registerBrickClass(LabelBrick.self)
        self.brickCollectionView.registerBrickClass(SegmentHeaderBrick.self)

        brickSection1 = BrickSection(backgroundColor: .brickGray1, bricks: [
            LabelBrick(width: .Fixed(size: 60), height: .Fixed(size: 100), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .Fixed(size: 60), height: .Fixed(size: 100), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .Fixed(size: 60), height: .Fixed(size: 100), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            ], inset: 10)

        brickSection2 = BrickSection(backgroundColor: .brickGray1, bricks: [
            LabelBrick(width: .Ratio(ratio: 1/3), height: .Fixed(size: 100), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .Ratio(ratio: 1/3), height: .Fixed(size: 100), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            ], inset: 10)

        brickSection3 = BrickSection(backgroundColor: .brickGray1, bricks: [
            LabelBrick(BrickIdentifiers.repeatLabel, width: .Ratio(ratio: 1/3), height: .Fixed(size: 100), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            ], inset: 10)

        brickSection3.repeatCountDataSource = self

        let section = BrickSection(bricks: [
            SegmentHeaderBrick(dataSource: self, delegate: self),
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

extension AlignmentBrickViewController: SegmentHeaderBrickDataSource {

    var titles: [String] {
        return ["Left", "Center", "Right", "Justified"]
    }

}

extension AlignmentBrickViewController: SegmentHeaderBrickDelegate {
    func segementHeaderBrickCell(cell: SegmentHeaderBrickCell, didSelectIndex index: Int) {
        self.selectedSegmentIndex = index
    }
}


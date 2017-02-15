//
//  BaseSectionBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit


let Group = "Group"

class BaseSectionBrickViewController: BrickApp.BaseBrickController {
    let numberOfLabels = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        self.brickCollectionView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            BrickSection(Group, bricks: [
                LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray2, text: "SECTION 1", configureCellBlock: LabelBrickCell.configure),
                LabelBrick(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 0.5), backgroundColor: .brickGray1, dataSource: self),
                ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)),
            BrickSection(Group, backgroundColor: .brickGray3, bricks: [
                LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray2, text: "SECTION 2 BRICK 1", configureCellBlock: LabelBrickCell.configure),
                LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray4, text: "SECTION 2 BRICK 2", configureCellBlock: LabelBrickCell.configure),
                LabelBrick(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 0.5), backgroundColor: .brickGray1, dataSource: self),
                ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
            ])
        section.repeatCountDataSource = self

        self.setSection(section)
    }
}

extension BaseSectionBrickViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return numberOfLabels
        } else {
            return 1
        }
    }
}

extension BaseSectionBrickViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        cell.label.text = "BRICK \(cell.index + 1)"
        cell.configure()
    }
}

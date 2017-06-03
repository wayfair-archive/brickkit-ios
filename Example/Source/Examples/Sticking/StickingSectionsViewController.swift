//
//  StickingSectionsViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/2/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

private let StickySection = "Sticky Section"

class StickingSectionsViewController: BrickApp.BaseBrickController, HasTitle {

    class var brickTitle: String {
        return "Sticky Sections"
    }

    class var subTitle: String {
        return "Example of sticking sections"
    }

    let numberOfLabels = 20
    var repeatLabel: LabelBrick!
    var titleLabelModel: LabelBrickCellModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.brickCollectionView.registerBrickClass(LabelBrick.self)

        behavior = StickyLayoutBehavior(dataSource: self)

        repeatLabel = LabelBrick(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 0.5), backgroundColor: .brickGray1, dataSource: self)

        let section = BrickSection(backgroundColor: UIColor.clear, bricks: [
            BrickSection(backgroundColor: .brickGray3, bricks: [
                BrickSection(StickySection, backgroundColor: .brickGray5, bricks: [
                    LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray2, text: "Sticking Section 1".uppercased(), configureCellBlock: LabelBrickCell.configure),
                    LabelBrick(BrickIdentifiers.titleLabel, width: .ratio(ratio: 0.5), backgroundColor: .brickGray4, text: "Brick 1-1".uppercased(), configureCellBlock: LabelBrickCell.configure),
                    LabelBrick(BrickIdentifiers.titleLabel, width: .ratio(ratio: 0.5), backgroundColor: .brickGray4, text: "Brick 2-1".uppercased(), configureCellBlock: LabelBrickCell.configure),
                    ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)),
                repeatLabel,
                ]),
            BrickSection(backgroundColor: .brickGray3, bricks: [
                BrickSection(StickySection, backgroundColor: .brickGray5, bricks: [
                    LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray2, text: "Sticking Section 2".uppercased(), configureCellBlock: LabelBrickCell.configure),
                    LabelBrick(BrickIdentifiers.titleLabel, width: .ratio(ratio: 0.5), backgroundColor: .brickGray4, text: "Brick 1-2".uppercased(), configureCellBlock: LabelBrickCell.configure),
                    LabelBrick(BrickIdentifiers.titleLabel, width: .ratio(ratio: 0.5), backgroundColor: .brickGray4, text: "Brick 2-2".uppercased(), configureCellBlock: LabelBrickCell.configure),
                    ]),
                repeatLabel,
                ]),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        section.repeatCountDataSource = self

        self.setSection(section)
    }
}

extension StickingSectionsViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(_ stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return identifier == StickySection
    }
}

extension StickingSectionsViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return numberOfLabels
        } else {
            return 1
        }
    }
}

extension StickingSectionsViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        cell.label.text = "BRICK \(cell.index + 1)"
        cell.configure()
    }
}

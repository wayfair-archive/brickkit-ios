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

class StickingSectionsViewController: BrickApp.BaseBrickController {

    override class var title: String {
        return "Sticky Sections"
    }

    override class var subTitle: String {
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

        repeatLabel = LabelBrick(BrickIdentifiers.repeatLabel, width: .Ratio(ratio: 0.5), backgroundColor: .brickGray1, dataSource: self)

        let configureCell: (cell: LabelBrickCell) -> Void = { cell in
            cell.configure()
        }

        let section = BrickSection(backgroundColor: .clearColor(), bricks: [
            BrickSection(backgroundColor: .brickGray3, bricks: [
                BrickSection(StickySection, backgroundColor: .brickGray5, bricks: [
                    LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray2, text: "Sticking Section 1".uppercaseString, configureCellBlock: configureCell),
                    LabelBrick(BrickIdentifiers.titleLabel, width: .Ratio(ratio: 0.5), backgroundColor: .brickGray4, text: "Brick 1-1".uppercaseString, configureCellBlock: configureCell),
                    LabelBrick(BrickIdentifiers.titleLabel, width: .Ratio(ratio: 0.5), backgroundColor: .brickGray4, text: "Brick 2-1".uppercaseString, configureCellBlock: configureCell),
                    ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)),
                repeatLabel,
                ]),
            BrickSection(backgroundColor: .brickGray3, bricks: [
                BrickSection(StickySection, backgroundColor: .brickGray5, bricks: [
                    LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray2, text: "Sticking Section 2".uppercaseString, configureCellBlock: configureCell),
                    LabelBrick(BrickIdentifiers.titleLabel, width: .Ratio(ratio: 0.5), backgroundColor: .brickGray4, text: "Brick 1-2".uppercaseString, configureCellBlock: configureCell),
                    LabelBrick(BrickIdentifiers.titleLabel, width: .Ratio(ratio: 0.5), backgroundColor: .brickGray4, text: "Brick 2-2".uppercaseString, configureCellBlock: configureCell),
                    ]),
                repeatLabel,
                ]),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        section.repeatCountDataSource = self

        self.setSection(section)
    }
}

extension StickingSectionsViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
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
    func configureLabelBrickCell(cell: LabelBrickCell) {
        cell.label.text = "BRICK \(cell.index + 1)"
        cell.configure()
    }
}

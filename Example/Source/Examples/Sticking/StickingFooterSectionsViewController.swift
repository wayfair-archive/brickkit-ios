//
//  StickingFooterSectionsViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/3/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//
import UIKit
import BrickKit

private let StickySection = "Sticky Section"

class StickingFooterSectionsViewController: BrickApp.BaseBrickController {

    override class var title: String {
        return "Sticking Footer Sections"
    }
    override class var subTitle: String {
        return "Example of sticking footer sections"
    }

    let numberOfLabels = 50
    var repeatLabel: LabelBrick!
    var titleLabelModel: LabelBrickCellModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = self.brickCollectionView.layout
        layout.zIndexBehavior = .BottomUp

        self.brickCollectionView.registerBrickClass(LabelBrick.self)

        behavior = StickyFooterLayoutBehavior(dataSource: self)

        repeatLabel = LabelBrick(BrickIdentifiers.repeatLabel, width: .Ratio(ratio:0.5), backgroundColor:.lightGrayColor(), dataSource:self)


        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                repeatLabel,
                BrickSection(StickySection, backgroundColor: .brickGray2, bricks: [
                    LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray1, text: "Sticking Section 1", configureCellBlock: LabelBrickCell.configure),
                    LabelBrick(BrickIdentifiers.titleLabel, width: .Ratio(ratio: 0.5), backgroundColor: .brickGray3, text: "Brick 1-1", configureCellBlock: LabelBrickCell.configure),
                    LabelBrick(BrickIdentifiers.titleLabel, width: .Ratio(ratio: 0.5), backgroundColor: .brickGray5, text: "Brick 2-1", configureCellBlock: LabelBrickCell.configure),
                    ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)),
                ]),
            BrickSection(bricks: [
                repeatLabel,
                BrickSection(StickySection, backgroundColor: .brickGray2, bricks: [
                    LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray1, text: "Sticking Section 2", configureCellBlock: LabelBrickCell.configure),
                    LabelBrick(BrickIdentifiers.titleLabel, width: .Ratio(ratio: 0.5), backgroundColor: .brickGray3, text: "Brick 1-2", configureCellBlock: LabelBrickCell.configure),
                    LabelBrick(BrickIdentifiers.titleLabel, width: .Ratio(ratio: 0.5), backgroundColor: .brickGray5, text: "Brick 2-2", configureCellBlock: LabelBrickCell.configure),
                    ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)),
                ])
            ])
        section.repeatCountDataSource = self


        self.setSection(section)
    }
}

extension StickingFooterSectionsViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return identifier == StickySection
    }
}

extension StickingFooterSectionsViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return numberOfLabels
        } else {
            return 1
        }
    }
}

extension StickingFooterSectionsViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(cell: LabelBrickCell) {
        cell.label.text = "Label \(cell.index + 1)"
        cell.configure()
    }
}

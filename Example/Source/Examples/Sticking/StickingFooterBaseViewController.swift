//
//  StickingFooterBaseViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/3/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

private let StickySection = "Sticky Section"
private let FooterTitle = "FooterTitle"

class StickingFooterBaseViewController: BrickApp.BaseBrickController {

    override class var title: String {
        return "Sticking Footer"
    }

    override class var subTitle: String {
        return "Example of Sticking Footers"
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

        repeatLabel = LabelBrick(BrickIdentifiers.repeatLabel, width: .Ratio(ratio: 0.5), backgroundColor: .brickGray1, dataSource: self)
        titleLabelModel = LabelBrickCellModel(text: "HEADER")

        let footerSection = BrickSection(StickySection, backgroundColor: .whiteColor(), bricks: [
            LabelBrick(FooterTitle, backgroundColor: .lightGrayColor(), dataSource: LabelBrickCellModel(text: "Footer Title")),
            LabelBrick("Label 1", width: .Ratio(ratio: 0.5), backgroundColor: .lightGrayColor(), dataSource: LabelBrickCellModel(text: "Footer Label 1")),
            LabelBrick("Label 2", width: .Ratio(ratio: 0.5), backgroundColor: .lightGrayColor(), dataSource: LabelBrickCellModel(text: "Footer Label 2")),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        let section = BrickSection("Test", backgroundColor: .whiteColor(), bricks: [
            repeatLabel,
            footerSection
            ])
        section.repeatCountDataSource = self

        self.setSection(section)
    }
}

extension StickingFooterBaseViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return numberOfLabels
        } else {
            return 1
        }
    }
}

extension StickingFooterBaseViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(cell: LabelBrickCell) {
        cell.label.text = "BRICK \(cell.index + 1)"
        cell.configure()
    }
}


extension StickingFooterBaseViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return identifier == StickySection
    }
}

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

class StickingFooterBaseViewController: BrickApp.BaseBrickController, HasTitle {

    class var brickTitle: String {
        return "Sticking Footer"
    }

    class var subTitle: String {
        return "Example of Sticking Footers"
    }

    let numberOfLabels = 50
    var repeatLabel: LabelBrick!

    override func viewDidLoad() {
        super.viewDidLoad()


        let layout = self.brickCollectionView.layout
        layout.zIndexBehavior = .bottomUp

        self.brickCollectionView.registerBrickClass(LabelBrick.self)

        let behavior = StickyFooterLayoutBehavior(dataSource: self)
        self.brickCollectionView.layout.behaviors.insert(behavior)

        let footerSection = BrickSection(StickySection, backgroundColor: UIColor.white, bricks: [
            LabelBrick(FooterTitle, backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "Footer Title")),
            LabelBrick(width: .ratio(ratio: 0.5), backgroundColor: UIColor.lightGray, dataSource: LabelBrickCellModel(text: "Footer Label 1")),
            LabelBrick(width: .ratio(ratio: 0.5), backgroundColor: UIColor.lightGray, dataSource: LabelBrickCellModel(text: "Footer Label 2")),
            ], inset: 5, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        let section = BrickSection(backgroundColor: UIColor.white, bricks: [
            LabelBrick(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 0.5), height: .auto(estimate: .fixed(size: 38)), backgroundColor: .brickGray1, dataSource: self),
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
    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        cell.label.text = "BRICK \(cell.index + 1)"
        cell.configure()
    }
}


extension StickingFooterBaseViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(_ stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return identifier == StickySection
    }
}

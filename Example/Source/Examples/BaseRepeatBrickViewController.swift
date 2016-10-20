//
//  BaseRepeatBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class BaseRepeatBrickViewController: BrickApp.BaseBrickController {

    let numberOfLabels = 100
    var repeatLabel: LabelBrick!
    var titleLabelModel: LabelBrickCellModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.brickCollectionView.registerBrickClass(LabelBrick.self)

        repeatLabel = LabelBrick(BrickIdentifiers.repeatLabel, width: .Ratio(ratio: 0.5), height: .Auto(estimate: .Fixed(size: 50)), backgroundColor: .brickGray3, dataSource: self)

        titleLabelModel = LabelBrickCellModel(text: "HEADER", configureCellBlock: { cell in
            cell.configure()
        })
        
        let section = BrickSection(bricks: [
            LabelBrick(BrickIdentifiers.titleLabel, height: .Auto(estimate: .Fixed(size: 50)), backgroundColor: .brickGray1, dataSource: titleLabelModel),
            repeatLabel,
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        section.repeatCountDataSource = self

        self.setSection(section)
    }

}

extension BaseRepeatBrickViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return numberOfLabels
        } else {
            return 1
        }
    }
}

extension BaseRepeatBrickViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(cell: LabelBrickCell) {
        cell.label.text = "BRICK \(cell.index + 1)"
        cell.configure()
    }
}

//
//  HugeRepeatBrickViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 11/17/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class HugeRepeatBrickViewController: BrickViewController, LabelBrickCellDataSource, BrickRepeatCountDataSource {

    override class var title: String {
        return "Huge Repeat"
    }
    override class var subTitle: String {
        return "Example how to repeat a huge amount of bricks"
    }

    let numberOfLabels = 500000

    override func viewDidLoad() {
        super.viewDidLoad()

        self.brickCollectionView.registerBrickClass(LabelBrick.self)

        self.view.backgroundColor = .brickBackground

        let section = BrickSection(bricks: [
            LabelBrick(BrickIdentifiers.repeatLabel, width: .Ratio(ratio: 1/2), height: .Auto(estimate: .Fixed(size: 50)), backgroundColor: .brickGray1, dataSource: self),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        section.repeatCountDataSource = self

        self.setSection(section)
    }

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return numberOfLabels
        } else {
            return 1
        }
    }

    func configureLabelBrickCell(cell: LabelBrickCell) {
        var text = ""

        for _ in 0...cell.index {
            if !text.isEmpty {
                text += " "
            }
            text += "BRICK \(cell.index)"
        }
        cell.label.text = text
        cell.configure()
    }
}

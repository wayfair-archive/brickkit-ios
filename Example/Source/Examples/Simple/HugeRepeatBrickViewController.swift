//
//  HugeRepeatBrickViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 11/17/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class HugeRepeatBrickViewController: BrickViewController, LabelBrickCellDataSource, BrickRepeatCountDataSource, HasTitle {

    class var brickTitle: String {
        return "Huge Repeat"
    }
    class var subTitle: String {
        return "Example how to repeat a huge amount of bricks"
    }

    let numberOfLabels = 1000000

    override func viewDidLoad() {
        super.viewDidLoad()

        self.brickCollectionView.registerBrickClass(LabelBrick.self)

        self.view.backgroundColor = .brickBackground

        let section = BrickSection(bricks: [
            LabelBrick(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 1/2), height: .auto(estimate: .fixed(size: 50)), backgroundColor: .brickGray1, dataSource: self),
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

    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        var text = ""

        for _ in 0...min(cell.index, 5) {
            if !text.isEmpty {
                text += " "
            }
            text += "BRICK \(cell.index)"
        }
        cell.label.text = text
        cell.configure()
    }
}

//
//  HorizontalScrollBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/12/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

class SimpleHorizontalScrollBrickViewController: BrickApp.BaseBrickController, BrickRepeatCountDataSource, LabelBrickCellDataSource, HasTitle {

    class var brickTitle: String {
        return "Basic Horizontal Scroll"
    }
    class var subTitle: String {
        return "How to use horizontal scroll"
    }

    let numberOfLabels = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.layout.scrollDirection = .horizontal
        self.brickCollectionView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(backgroundColor: .brickSection, bricks: [
            LabelBrick(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 0.5), backgroundColor: .brickGray5, dataSource: self),
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
        cell.label.text = "BRICK \(cell.index + 1)"
        cell.configure()
    }
}

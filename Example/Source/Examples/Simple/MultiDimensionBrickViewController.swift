//
//  MultiDimensionBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class MultiDimensionBrickViewController: BrickViewController, LabelBrickCellDataSource, BrickRepeatCountDataSource, HasTitle {

    class var brickTitle: String {
        return "Multi Dimension"
    }
    
    class var subTitle: String {
        return "Different way of setting dimensions"
    }

    let numberOfLabels = 200

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.brickCollectionView.registerBrickClass(LabelBrick.self)

        let width: BrickDimension =
            .horizontalSizeClass(
                regular: .orientation(
                    landscape: .ratio(ratio: 1/3),
                    portrait: .ratio(ratio: 1/2)
                ),
                compact: .orientation(
                    landscape: .ratio(ratio: 1/8),
                    portrait: .ratio(ratio: 1/2)
                )
        )

        let height: BrickDimension =
            .horizontalSizeClass(
                regular: .orientation(
                    landscape: .fixed(size: 200),
                    portrait: .fixed(size: 100)
                ),
                compact: .orientation(
                    landscape: .fixed(size: 100),
                    portrait: .fixed(size: 50)
                )
        )

        let header = LabelBrick(backgroundColor: .brickGray1, text: "ROTATE THE DEVICE TO SEE THE DIFFERENCE", configureCellBlock: LabelBrickCell.configure)

        let section = BrickSection(bricks: [
            header,
            LabelBrick(BrickIdentifiers.repeatLabel, width: width, height: height, backgroundColor: .brickGray3, dataSource: self),
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
        let text = "BRICK \(cell.index + 1)".uppercased()
        cell.label.text = text
        cell.configure()
    }

}

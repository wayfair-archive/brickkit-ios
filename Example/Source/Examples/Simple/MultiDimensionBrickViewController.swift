//
//  MultiDimensionBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class MultiDimensionBrickViewController: BrickViewController, LabelBrickCellDataSource, BrickRepeatCountDataSource {

    override class var title: String {
        return "Multi Dimension"
    }
    
    override class var subTitle: String {
        return "Different way of setting dimensions"
    }

    let numberOfLabels = 200

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.brickCollectionView.registerBrickClass(LabelBrick.self)

        let width: BrickDimension =
            .HorizontalSizeClass(
                regular: .Orientation(
                    landscape: .Ratio(ratio: 1/3),
                    portrait: .Ratio(ratio: 1/2)
                ),
                compact: .Orientation(
                    landscape: .Ratio(ratio: 1/8),
                    portrait: .Ratio(ratio: 1/2)
                )
        )

        let height: BrickDimension =
            .HorizontalSizeClass(
                regular: .Orientation(
                    landscape: .Fixed(size: 200),
                    portrait: .Fixed(size: 100)
                ),
                compact: .Orientation(
                    landscape: .Fixed(size: 100),
                    portrait: .Fixed(size: 50)
                )
        )

        let header = LabelBrick(backgroundColor: .brickGray1, text: "ROTATE THE DEVICE TO SEE THE DIFFERENCE", configureCellBlock: { cell in
            cell.configure()
        })

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

    func configureLabelBrickCell(cell: LabelBrickCell) {
        let text = "BRICK \(cell.index + 1)".uppercaseString
        cell.label.text = text
        cell.configure()
    }

}

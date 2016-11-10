//
//  HorizontalScrollSectionBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/9/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

private let leftLabel = "leftLabel"
private let rightLabel = "leftLabel"

class HorizontalScrollSectionBrickViewController: BrickApp.BaseBrickController, BrickRepeatCountDataSource {

    override class var title: String {
        return "Horizontal Scroll"
    }
    override class var subTitle: String {
        return "How to use horizontal scroll with a CollectionBrick"
    }


    let numberOfCollections = 9

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerBrickClass(CollectionBrick.self)
        self.registerBrickClass(LabelBrick.self)

        let section1 = BrickSection(backgroundColor: .brickGray1, bricks: [
            ImageBrick(BrickIdentifiers.repeatLabel, width: .Ratio(ratio: 1/4), height: .Ratio(ratio: 1), backgroundColor: .brickGray3, dataSource: self),
            ] , inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        section1.repeatCountDataSource = self

        let section2 = BrickSection(backgroundColor: .brickGray1, bricks: [
            ImageBrick(BrickIdentifiers.repeatLabel, width: .Ratio(ratio: 1/2), height: .Ratio(ratio: 1), backgroundColor: .brickGray3, dataSource: self),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        section2.repeatCountDataSource = self

        let section3 = BrickSection(backgroundColor: .brickGray1, bricks: [
            ImageBrick(BrickIdentifiers.repeatLabel, width: .Fixed(size: 100), height: .Ratio(ratio: 1), backgroundColor: .brickGray3, dataSource: self),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        section3.repeatCountDataSource = self

        let configureCell: ConfigureLabelBlock = { cell in
            cell.label.textAlignment = .Center
            cell.configure()
        }

        let section = BrickSection(backgroundColor: .whiteColor(), bricks: [
            LabelBrick(backgroundColor: .brickGray3, text: "1/4 Ratio", configureCellBlock: configureCell),
            CollectionBrick("Collection 1", backgroundColor: .brickGray1, scrollDirection: .Horizontal, dataSource: CollectionBrickCellModel(section: section1), brickTypes:[ImageBrick.self]),
            LabelBrick(backgroundColor: .brickGray3, text: "1/2 Ratio", configureCellBlock: configureCell),
            CollectionBrick("Collection 2", backgroundColor: .brickGray3, scrollDirection: .Horizontal, dataSource: CollectionBrickCellModel(section: section2), brickTypes:[ImageBrick.self]),
            LabelBrick(backgroundColor: .brickGray3, text: "100px Fixed", configureCellBlock: configureCell),
            CollectionBrick("Collection 3", backgroundColor: .brickGray5, scrollDirection: .Horizontal, dataSource: CollectionBrickCellModel(section: section3), brickTypes:[ImageBrick.self]),
            ])

        self.setSection(section)
    }

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return numberOfCollections
        } else {
            return 1
        }
    }

}

extension HorizontalScrollSectionBrickViewController: ImageBrickDataSource {
    func imageForImageBrickCell(cell: ImageBrickCell) -> UIImage? {
        return UIImage(named: "image\(cell.index)")
    }

    func contentModeForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return .ScaleAspectFill
    }
}



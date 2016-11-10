//
//  SimpleCollectionBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/8/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class SimpleCollectionBrickViewController: BrickApp.BaseBrickController {
    let image = UIImage(named: "wayfair")!

    override class var title: String {
        return "Simple CollectionBrick"
    }
    override class var subTitle: String {
        return "How to use a CollectionBrick"
    }

    var simpleSection: BrickSection!
    var titleBrick: LabelBrick!
    var subtitleBrick: LabelBrick!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.registerBrickClass(CollectionBrick.self)

        let collectionSection = BrickSection(bricks: [
            ImageBrick(width: .Ratio(ratio: 1/2), height: .Ratio(ratio: 1), dataSource: ImageBrickModel(image: image, contentMode: .ScaleAspectFit)),
            BrickSection(width: .Ratio(ratio: 1/2), bricks: [
                LabelBrick(backgroundColor: .brickGray2, dataSource: LabelBrickCellModel(text: "MODEL", configureCellBlock: BaseBrickController.configureCell)),
                LabelBrick(backgroundColor: .brickGray4, dataSource: LabelBrickCellModel(text: "USING A COLLECTION BRICKCELL MODEL", configureCellBlock: BaseBrickController.configureCell))
                ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        ])

        let section = BrickSection(bricks: [
            CollectionBrick(backgroundColor: .brickSection, dataSource: CollectionBrickCellModel(section: collectionSection), brickTypes: [LabelBrick.self, ImageBrick.self]),
            CollectionBrick(backgroundColor: .brickSection, dataSource: self, brickTypes: [LabelBrick.self, ImageBrick.self]),
            ], inset: 50)

        self.setSection(section)

    }

}

extension SimpleCollectionBrickViewController: CollectionBrickCellDataSource {

    func sectionForCollectionBrickCell(cell: CollectionBrickCell) -> BrickSection {
        let collectionSection = BrickSection(bricks: [
            ImageBrick(width: .Ratio(ratio: 1/2), height: .Ratio(ratio: 1), dataSource: ImageBrickModel(image: image, contentMode: .ScaleAspectFit)),
            BrickSection(width: .Ratio(ratio: 1/2), bricks: [
                LabelBrick(backgroundColor: .brickGray2, dataSource: LabelBrickCellModel(text: "DATASOURCE", configureCellBlock: BaseBrickController.configureCell)),
                LabelBrick(backgroundColor: .brickGray4, dataSource: LabelBrickCellModel(text: "USING A COLLECTION BRICKCELL DATASOURCE", configureCellBlock: BaseBrickController.configureCell))
                ])
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        return collectionSection
    }

}

//
//  RepeatCollectionBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/8/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit



class RepeatCollectionBrickViewController: BrickApp.BaseBrickController, BrickRepeatCountDataSource {

    struct Identifiers {
        static let collectionBrick = "collectionBrick"
        static let titleLabel = "titleLabel"
        static let subTitleLabel = "subTitleLabel"
    }

    override class var title: String {
        return "Repeat CollectionBrick"
    }
    override class var subTitle: String {
        return "How to repeat a CollectionBrick"
    }


    var collectionSection: BrickSection!
    let numberOfCollections = 9

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        collectionSection = BrickSection(bricks: [
            ImageBrick(width: .Ratio(ratio: 1/2), height: .Ratio(ratio: 1), dataSource: self),
            BrickSection(width: .Ratio(ratio: 1/2), bricks: [
                LabelBrick(RepeatCollectionBrickViewController.Identifiers.titleLabel, backgroundColor: .brickGray2, dataSource: self),
                LabelBrick(RepeatCollectionBrickViewController.Identifiers.subTitleLabel, backgroundColor: .brickGray4, dataSource: self)
                ])
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        self.registerBrickClass(CollectionBrick.self)

        let section = BrickSection(bricks: [
            CollectionBrick(RepeatCollectionBrickViewController.Identifiers.collectionBrick, dataSource: self)
            ], inset: 20)
        section.repeatCountDataSource = self

        self.setSection(section)

    }


    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == RepeatCollectionBrickViewController.Identifiers.collectionBrick {
            return numberOfCollections
        } else {
            return 1
        }
    }

}

extension RepeatCollectionBrickViewController: CollectionBrickCellDataSource {

    func configureCollectionBrickViewForBrickCollectionCell(brickCollectionCell: CollectionBrickCell) {
        brickCollectionCell.brickCollectionView.registerBrickClass(LabelBrick.self)
        brickCollectionCell.brickCollectionView.registerBrickClass(ImageBrick.self)
    }

    func sectionForCollectionBrickCell(cell: CollectionBrickCell) -> BrickSection {
        return collectionSection
    }
    
}

extension RepeatCollectionBrickViewController: ImageBrickDataSource {
    func imageForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIImage? {
        return UIImage(named: "image\(imageBrickCell.collectionIndex)")
    }

    func contentModeForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return .ScaleAspectFill
    }
}

extension RepeatCollectionBrickViewController: LabelBrickCellDataSource {

    func configureLabelBrickCell(cell: LabelBrickCell) {
        let identifier = cell.brick.identifier
        let collectionIndex = cell.collectionIndex + 1

        if identifier == RepeatCollectionBrickViewController.Identifiers.titleLabel {
            cell.label.text = "Title \(collectionIndex)".uppercaseString
        } else if identifier == RepeatCollectionBrickViewController.Identifiers.subTitleLabel {
            cell.label.text = "SubTitle \(collectionIndex)".uppercaseString
        }

    }
}


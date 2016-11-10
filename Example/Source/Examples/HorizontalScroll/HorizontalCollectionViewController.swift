//
//  HorizontalCollectionViewController.swift
//  BrickKit iOS Example
//
//  Created by Ruben Cagnie on 10/13/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

class HorizontalCollectionViewController: BrickViewController {

    override class var title: String {
        return "Collection Horizontal Scroll"
    }

    override class var subTitle: String {
        return "Horizontally scrolling of CollectionBricks"
    }

    var collectionSection: BrickSection!
    let numberOfCollections = 9

    struct Identifiers {
        static let collectionBrick = "CollectionBrick"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground
        self.layout.scrollDirection = .Horizontal
        self.brickCollectionView.registerBrickClass(ImageBrick.self)

        self.view.backgroundColor = .brickBackground

        self.brickCollectionView.layout.alignRowHeights = true

        collectionSection = BrickSection(bricks: [
            ImageBrick(width: .Ratio(ratio: 1/2), height: .Ratio(ratio: 1), dataSource: self),
            BrickSection(width: .Ratio(ratio: 1/2), bricks: [
                LabelBrick(RepeatCollectionBrickViewController.Identifiers.titleLabel, backgroundColor: .brickGray2, dataSource: self),
                LabelBrick(RepeatCollectionBrickViewController.Identifiers.subTitleLabel, backgroundColor: .brickGray4, dataSource: self)
                ])
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        self.registerBrickClass(CollectionBrick.self)

        let section = BrickSection(bricks: [
            CollectionBrick(HorizontalCollectionViewController.Identifiers.collectionBrick, width: .Ratio(ratio: 1/2), backgroundColor: .brickSection, dataSource: self, brickTypes: [LabelBrick.self, ImageBrick.self])
            ], inset: 20)
        section.repeatCountDataSource = self

        self.setSection(section)

    }

}

extension HorizontalCollectionViewController: BrickRepeatCountDataSource {

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == HorizontalCollectionViewController.Identifiers.collectionBrick {
            return numberOfCollections
        } else {
            return 1
        }
    }

}

extension HorizontalCollectionViewController: CollectionBrickCellDataSource {

    func sectionForCollectionBrickCell(cell: CollectionBrickCell) -> BrickSection {
        return collectionSection
    }

}

extension HorizontalCollectionViewController: ImageBrickDataSource {
    func imageForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIImage? {
        return UIImage(named: "image\(imageBrickCell.collectionIndex)")
    }

    func contentModeForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return .ScaleAspectFill
    }
}

extension HorizontalCollectionViewController: LabelBrickCellDataSource {

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


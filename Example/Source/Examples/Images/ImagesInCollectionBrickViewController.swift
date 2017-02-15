//
//  ImagesInCollectionBrickViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 10/19/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class ImagesInCollectionBrickViewController: BrickViewController {

    override class var title: String {
        return "Images in CollectionBrick"
    }
    override class var subTitle: String {
        return "Shows how to use images in a CollectionBrick"
    }

    let numberOfImages = 9

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        registerBrickClass(CollectionBrick.self)

        let collectionSection = BrickSection(backgroundColor: .brickGray1, bricks: [
            ImageBrick(BrickIdentifiers.repeatLabel, dataSource: self),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        collectionSection.repeatCountDataSource = self

        let section = BrickSection(bricks: [
            CollectionBrick(dataSource: CollectionBrickCellModel(section: collectionSection), brickTypes: [ImageBrick.self])
            ])

        self.setSection(section)
    }

}

extension ImagesInCollectionBrickViewController: BrickRepeatCountDataSource {

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return numberOfImages
        } else {
            return 1
        }
    }

}

extension ImagesInCollectionBrickViewController: ImageBrickDataSource {
    func imageForImageBrickCell(cell: ImageBrickCell) -> UIImage? {
        return UIImage(named: "image\(cell.index)")
    }

    func contentModeForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return .scaleAspectFill
    }
}

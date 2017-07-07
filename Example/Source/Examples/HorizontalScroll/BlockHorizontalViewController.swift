//
//  BlockHorizontalViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/13/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

class BlockHorizontalViewController: BrickViewController, HasTitle {

    class var brickTitle: String {
        return "1:1 Horizontal Scroll"
    }
    class var subTitle: String {
        return "Scroll images as cubes"
    }

    let numberOfImages = 9

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground
        self.layout.scrollDirection = .horizontal
        self.brickCollectionView.registerBrickClass(ImageBrick.self)

        let section = BrickSection(backgroundColor: .brickGray1, bricks: [
            ImageBrick(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 1/4), height: .ratio(ratio: 1), backgroundColor: .brickGray3, dataSource: self),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        section.repeatCountDataSource = self

        self.setSection(section)
    }

}

extension BlockHorizontalViewController: BrickRepeatCountDataSource {

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return numberOfImages
        } else {
            return 1
        }
    }

}

extension BlockHorizontalViewController: ImageBrickDataSource {
    func imageForImageBrickCell(_ cell: ImageBrickCell) -> UIImage? {
        return UIImage(named: "image\(cell.index)")
    }

    func contentModeForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return .scaleAspectFill
    }
}

//
//  RepeatCollectionBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/8/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit



class RepeatCollectionBrickViewController: BrickApp.BaseBrickController, BrickRepeatCountDataSource, HasTitle {

    struct Identifiers {
        static let collectionBrick = "collectionBrick"
        static let titleLabel = "titleLabel"
        static let subTitleLabel = "subTitleLabel"
    }

    class var brickTitle: String {
        return "Repeat CollectionBrick"
    }
    class var subTitle: String {
        return "How to repeat a CollectionBrick"
    }


    var collectionSection: BrickSection!
    let numberOfCollections = 9

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        collectionSection = BrickSection(bricks: [
            ImageBrick(width: .ratio(ratio: 1/2), height: .ratio(ratio: 1), dataSource: self),
            BrickSection(width: .ratio(ratio: 1/2), bricks: [
                LabelBrick(RepeatCollectionBrickViewController.Identifiers.titleLabel, backgroundColor: .brickGray2, dataSource: self),
                LabelBrick(RepeatCollectionBrickViewController.Identifiers.subTitleLabel, backgroundColor: .brickGray4, dataSource: self)
                ])
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))


        let section = BrickSection(bricks: [
            CollectionBrick(RepeatCollectionBrickViewController.Identifiers.collectionBrick, dataSource: self, brickTypes: [LabelBrick.self, ImageBrick.self])
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

    func sectionForCollectionBrickCell(_ cell: CollectionBrickCell) -> BrickSection {
        return collectionSection
    }
    
    func registerBricks(for cell: CollectionBrickCell) {
        cell.brickCollectionView.registerNib(LabelBrickNibs.Image, forBrickWithIdentifier: RepeatCollectionBrickViewController.Identifiers.subTitleLabel)
    }
    
}

extension RepeatCollectionBrickViewController: ImageBrickDataSource {
    func imageForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> UIImage? {
        return UIImage(named: "image\(imageBrickCell.collectionIndex)")
    }

    func contentModeForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return .scaleAspectFill
    }
}

extension RepeatCollectionBrickViewController: LabelBrickCellDataSource {

    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        let identifier = cell.brick.identifier
        let collectionIndex = cell.collectionIndex + 1

        if identifier == RepeatCollectionBrickViewController.Identifiers.titleLabel {
            cell.label.text = "Title \(collectionIndex)".uppercased()
        } else if identifier == RepeatCollectionBrickViewController.Identifiers.subTitleLabel {
            cell.label.text = "SubTitle \(collectionIndex)".uppercased()
        }
        
        cell.imageView?.translatesAutoresizingMaskIntoConstraints = true
        cell.imageView?.frame = CGRect(origin: cell.imageView?.frame.origin ?? CGPoint.zero, size: CGSize(width: 30, height: 30))
        cell.imageView?.clipsToBounds = true
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.image = UIImage(named: "wayfair")
        
    }
}


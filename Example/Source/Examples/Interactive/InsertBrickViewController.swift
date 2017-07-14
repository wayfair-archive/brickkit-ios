//
//  InsertBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 8/5/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

private let Section = "Section"

class InsertBrickViewController: BrickApp.BaseBrickController, HasTitle {

    var data: [String] = ["Brick 1"]

    class var brickTitle: String {
        return "Insert Brick"
    }

    class var subTitle: String {
        return "Shows different ways of inserting a brick"
    }

    var selectedSegmentIndex: Int = 0
    var titles: [String] = []

    var selectedAppearSegmentIndex: Int = 0 {
        didSet {
            let appearBehavior: BrickAppearBehavior?
            switch selectedAppearSegmentIndex {
            case 1: appearBehavior = BrickAppearTopBehavior()
            case 2: appearBehavior = BrickAppearBottomBehavior()
            case 3: appearBehavior = ScaleAppearBehavior(scale: 0.5)
            default: appearBehavior = nil
            }
            self.layout.appearBehavior = appearBehavior
        }
    }

    var appearTitles: [String] {
        return ["No animation", "From top", "From bottom", "Fade in"]
    }

    var insertToIndex: Int {
        switch selectedInsertSegmentIndex {
        case 1: return data.count / 2
        case 2: return data.count
        default: return 0
        }
    }

    var selectedInsertSegmentIndex: Int = 0

    var insertTitles: [String] {
        return ["On top", "In the middle", "At the bottom"]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground
        self.brickCollectionView.registerBrickClass(LabelBrick.self)
        self.brickCollectionView.registerBrickClass(SegmentHeaderBrick.self)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(InsertBrickViewController.insertBrick))

        let section = BrickSection(Section, bricks: [
            BrickSection(bricks: [SegmentHeaderBrick("AppearSegmentHeaderBrick", dataSource: self, delegate: self),
                                  SegmentHeaderBrick("InsertSegmentHeaderBrick", dataSource: self, delegate: self)]),
            LabelBrick(BrickIdentifiers.repeatLabel, height: .auto(estimate:  .fixed(size: 150)), backgroundColor: UIColor.lightGray, dataSource: self)
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        section.repeatCountDataSource = self

        self.setSection(section)
    }

    @objc func insertBrick() {
        let newElement = "BRICK \(data.count + 1)"
        let index = insertToIndex
        if selectedInsertSegmentIndex == 2 {
            data.append(newElement)
        } else {
            data.insert(newElement, at: index)
        }
        updateRepeatCounts(fixedInsertedIndexPaths: [IndexPath(item: index + 1, section: 1)])
    }

    func removeBrick(indexPath: IndexPath) {
        data.remove(at: indexPath.item - 1)
        updateRepeatCounts(fixedDeletedIndexPaths: [indexPath])
    }

    func updateRepeatCounts(fixedInsertedIndexPaths: [IndexPath] = [], fixedDeletedIndexPaths: [IndexPath] = []) {
        UIView.animate(withDuration: 1 /*, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn*/, animations: {
            self.brickCollectionView.updateAt(insertedIndexPaths: fixedInsertedIndexPaths, deletedIndexPaths: fixedDeletedIndexPaths)
        })
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let brickInfo = self.brickCollectionView.brickInfo(at: indexPath)
        if brickInfo.brick.identifier == BrickIdentifiers.repeatLabel {
            removeBrick(indexPath: indexPath)
        }
    }
}


extension InsertBrickViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return data.count
        } else {
            return 1
        }
    }
}

extension InsertBrickViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        cell.label.text = data[cell.index]
        cell.configure()
    }
}

extension InsertBrickViewController: SegmentHeaderBrickDataSource {
    func configure(cell: SegmentHeaderBrickCell) {
        switch cell.identifier {
        case "AppearSegmentHeaderBrick":
            titles = appearTitles
            selectedSegmentIndex = selectedAppearSegmentIndex
        case "InsertSegmentHeaderBrick":
            titles = insertTitles
            selectedSegmentIndex = selectedInsertSegmentIndex
        default: break
        }
    }

}

extension InsertBrickViewController: SegmentHeaderBrickDelegate {
    func segementHeaderBrickCell(cell: SegmentHeaderBrickCell, didSelectIndex index: Int) {
        switch cell.identifier {
        case "AppearSegmentHeaderBrick": self.selectedAppearSegmentIndex = index
        case "InsertSegmentHeaderBrick": self.selectedInsertSegmentIndex = index
        default: break
        }
    }
}

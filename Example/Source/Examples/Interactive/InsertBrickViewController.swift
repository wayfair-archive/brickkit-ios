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

class InsertBrickViewController: BrickApp.BaseBrickController {
    
    override class var title: String {
        return "Insert Brick"
    }

    override class var subTitle: String {
        return "Shows different ways of inserting a brick"
    }

    var selectedSegmentIndex: Int = 0 {
        didSet {
            let appearBehavior: BrickAppearBehavior?
            switch selectedSegmentIndex {
            case 1: appearBehavior = BrickAppearTopBehavior()
            case 2: appearBehavior = BrickAppearBottomBehavior()
            default: appearBehavior = nil
            }
            self.layout.appearBehavior = appearBehavior
        }
    }

    var titles: [String] {
        return ["No animation", "From top", "From bottom"]
    }

    var numberOfLabels = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground
        self.brickCollectionView.registerBrickClass(LabelBrick.self)
        self.brickCollectionView.registerBrickClass(SegmentHeaderBrick.self)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(InsertBrickViewController.insertBrick))

        let section = BrickSection(Section, bricks: [
            SegmentHeaderBrick(dataSource: self, delegate: self),
            LabelBrick(BrickIdentifiers.repeatLabel, backgroundColor: UIColor.lightGray, dataSource: self)
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        section.repeatCountDataSource = self

        self.setSection(section)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollToBottom()
    }

    func insertBrick() {
        numberOfLabels += 1
        updateRepeatCounts()
    }

    func removeBrick(indexPath: IndexPath) {
        self.numberOfLabels -= 1
        updateRepeatCounts(fixedDeletedIndexPaths: [indexPath])
    }

    func updateRepeatCounts(fixedDeletedIndexPaths: [IndexPath]? = nil) {
        UIView.animate(withDuration: 0.5, animations: {
            self.brickCollectionView.invalidateRepeatCounts(reloadAllSections: false) { (completed, insertedIndexPaths, deletedIndexPaths) in
                if let indexPath = insertedIndexPaths.first {
                    self.brickCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: false)
                }
            }
        })
    }

    func scrollToBottom() {
        let diffY = brickCollectionView.collectionViewLayout.collectionViewContentSize.height - brickCollectionView.bounds.height
        if (diffY + brickCollectionView.contentInset.top) > 0 {
            brickCollectionView.contentOffset = CGPoint(x: 0, y: diffY)
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        let brickInfo = self.brickCollectionView.brickInfo(at: indexPath)
        if brickInfo.brick.identifier == BrickIdentifiers.repeatLabel {
            removeBrick(indexPath: indexPath)
        }
    }
}


extension InsertBrickViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return numberOfLabels
        } else {
            return 1
        }
    }
}

extension InsertBrickViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        cell.label.text = "BRICK \(cell.index + 1)"
        cell.configure()
    }
}

extension InsertBrickViewController: SegmentHeaderBrickDataSource {

}

extension InsertBrickViewController: SegmentHeaderBrickDelegate {
    func segementHeaderBrickCell(cell: SegmentHeaderBrickCell, didSelectIndex index: Int) {
        self.selectedSegmentIndex = index
    }
}



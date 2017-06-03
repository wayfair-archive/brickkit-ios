//
//  SimpleRepeatBrickViewController.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

class SimpleRepeatBrickViewController: BrickViewController, LabelBrickCellDataSource, BrickRepeatCountDataSource, HasTitle {
    
    class var brickTitle: String {
        return "Simple Repeat"
    }
    class var subTitle: String {
        return "Example how to use the repeatCountDataSource"
    }

    let numberOfLabels = 100

    override func viewDidLoad() {
        super.viewDidLoad()

        self.brickCollectionView.registerBrickClass(LabelBrick.self)

        self.view.backgroundColor = .brickBackground

        let section = BrickSection(bricks: [
            LabelBrick(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 1/2), height: .auto(estimate: .fixed(size: 50)), backgroundColor: .brickGray1, dataSource: self),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        section.repeatCountDataSource = self

        self.setSection(section)
        updateNavigationItem()
    }

    func updateNavigationItem() {
        let selector: Selector = #selector(SimpleRepeatBrickViewController.toggleAlignBehavior)
        let title = self.brickCollectionView.section.alignRowHeights ? "Don't Align" : "Align"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: selector)
    }

    @objc func toggleAlignBehavior() {
        self.brickCollectionView.section.alignRowHeights = !self.brickCollectionView.section.alignRowHeights
        brickCollectionView.reloadData()
        updateNavigationItem()
    }

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return numberOfLabels
        } else {
            return 1
        }
    }

    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        var text = ""

        for _ in 0...cell.index {
            if !text.isEmpty {
                text += "\n"
            }
            text += "BRICK \(cell.index)"
        }
        cell.label.text = text
        cell.configure()
    }
}

//
//  SimpleRepeatBrickViewController.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

class SimpleRepeatBrickViewController: BrickViewController, LabelBrickCellDataSource, BrickRepeatCountDataSource {
    
    override class var title: String {
        return "Simple Repeat"
    }
    override class var subTitle: String {
        return "Example how to use the repeatCountDataSource"
    }

    let numberOfLabels = 50

    override func viewDidLoad() {
        super.viewDidLoad()

        self.brickCollectionView.registerBrickClass(LabelBrick.self)

        self.layout.alignRowHeights = true

        self.view.backgroundColor = .brickBackground

        let section = BrickSection(bricks: [
            LabelBrick(BrickIdentifiers.repeatLabel, width: .Ratio(ratio: 0.5), height: .Auto(estimate: .Fixed(size: 50)), backgroundColor: .brickGray1, dataSource: self),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        section.repeatCountDataSource = self

        self.setSection(section)
        updateNavigationItem()
    }

    func updateNavigationItem() {
        let selector: Selector = #selector(SimpleRepeatBrickViewController.toggleAlignBehavior)
        let title = self.layout.alignRowHeights ? "Don't Align" : "Align"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: selector)
    }

    func toggleAlignBehavior() {
        self.layout.alignRowHeights = !self.layout.alignRowHeights
        updateNavigationItem()
    }

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return numberOfLabels
        } else {
            return 1
        }
    }

    func configureLabelBrickCell(cell: LabelBrickCell) {
        var text = ""
        for _ in 0...cell.index {
            if !text.isEmpty {
                text += "\n"
            }
            text += "BRICK \(cell.index + 1)"
        }
        cell.label.text = text
        cell.configure()
    }
}

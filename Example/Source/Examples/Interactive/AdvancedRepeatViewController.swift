//
//  AdvancedRepeatViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/23/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

private let Item = "Item"
private let ItemsSection = "ItemsSection"

private let Title = "Title"
private let TitleSection = "TitleSection"

private let LoadButton = "LoadButton"
private let LoadButtonSection = "LoadButtonSection"

private let WholeSection = "WholeSection"

class AdvancedRepeatViewController: BrickApp.BaseBrickController, HasTitle {

    class var brickTitle: String {
        return "Advanced Repeat"
    }
    class var subTitle: String {
        return "How to repeat bricks in bulk"
    }

    var items = [String]()
    var loadButton : ButtonBrick!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.backgroundColor = .brickBackground

        registerBrickClass(LabelBrick.self)
        registerBrickClass(ButtonBrick.self)

        loadButton = ButtonBrick(LoadButton, title: "Load Items".uppercased(), configureButtonBlock: { cell in
            cell.configure()
        }) { cell in
            self.loadItems()
        }

        let section = BrickSection(WholeSection, bricks: [
            BrickSection(LoadButtonSection, backgroundColor: .brickGray5, bricks: [
                loadButton
                ]),
            BrickSection(ItemsSection, backgroundColor: .brickGray1, bricks: [
                LabelBrick(Item, width: .ratio(ratio: 1/2), height: .auto(estimate: .fixed(size: 38)), backgroundColor: .brickGray3, dataSource: self),
                ], inset: 5, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)),
            ])

        section.repeatCountDataSource = self

        setSection(section)

    }

    func loadItems() {
        if items.isEmpty {
            loadButton.title = "Remove items".uppercased()
            items = []
            for index in 0..<30 {
                items.append("BRICK \(index + 1)")
            }
        } else {
            loadButton.title = "Load items".uppercased()
            items.removeAll()
        }

        self.brickCollectionView.invalidateBricks()
    }
}


extension AdvancedRepeatViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == Item {
            return items.count
        } else {
            return 1
        }
    }
}

extension AdvancedRepeatViewController: LabelBrickCellDataSource {

    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        cell.label.text = items[cell.index]
        cell.configure()
    }

}

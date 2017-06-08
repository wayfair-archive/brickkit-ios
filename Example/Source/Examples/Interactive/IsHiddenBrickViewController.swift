//
//  HideBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/16/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

class IsHiddenBrickViewController: BrickApp.BaseBrickController, HasTitle {

    class var brickTitle: String {
        return "Hide Bricks with isHidden flag"
    }
    class var subTitle: String {
        return "Example of hiding bricks with the isHidden flag"
    }

    struct Identifiers {
        static let HideBrickButton = "HideBrickButton"
        static let HideSectionButton = "HideSectionButton"

        static let SimpleBrick = "SimpleBrick"
        static let SimpleSection = "SimpleSection"
    }

    var hideBrickButton: ButtonBrick!
    var hideSectionButton: ButtonBrick!
    var hiddenBrick: Brick!
    var hiddenSection: BrickSection!

    override func viewDidLoad() {
        super.viewDidLoad()

        hiddenBrick = LabelBrick(HideBrickViewController.Identifiers.SimpleBrick, backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "BRICK", configureCellBlock: LabelBrickCell.configure))
        hideBrickButton = ButtonBrick(HideBrickViewController.Identifiers.HideBrickButton, backgroundColor: .brickGray1, title: titleForHideBrickButton) { [weak self] _ in
            self?.hideBrick()
        }

        hiddenSection = BrickSection(HideBrickViewController.Identifiers.SimpleSection, backgroundColor: .brickGray3, bricks: [
            LabelBrick(width: .ratio(ratio: 0.5), backgroundColor: .brickGray5, dataSource: LabelBrickCellModel(text: "BRICK", configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(width: .ratio(ratio: 0.5), backgroundColor: .brickGray5, dataSource: LabelBrickCellModel(text: "BRICK", configureCellBlock: LabelBrickCell.configure)),
            ])
        hideSectionButton = ButtonBrick(HideBrickViewController.Identifiers.HideSectionButton, backgroundColor: .brickGray1, title: titleForHideSectionButton) { [weak self] _ in
            self?.hideSection()
        }

        self.collectionView?.backgroundColor = .brickBackground

        let section = BrickSection(bricks: [
            hiddenBrick,
            hideBrickButton,
            hiddenSection,
            hideSectionButton
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

        self.setSection(section)
    }

    var titleForHideBrickButton: String {
        return "\(hiddenBrick.isHidden ? "Show" : "Hide") Brick".uppercased()
    }

    var titleForHideSectionButton: String {
        return "\(hiddenSection.isHidden ? "Show" : "Hide") Section".uppercased()
    }

    func hideBrick() {
        hiddenBrick.isHidden = !hiddenBrick.isHidden
        hideBrickButton.title = titleForHideBrickButton
        brickCollectionView.invalidateVisibility()
        reloadBricksWithIdentifiers([HideBrickViewController.Identifiers.HideBrickButton])
    }

    func hideSection() {
        hiddenSection.isHidden = !hiddenSection.isHidden
        hideSectionButton.title = titleForHideSectionButton
        brickCollectionView.invalidateVisibility()
        reloadBricksWithIdentifiers([HideBrickViewController.Identifiers.HideSectionButton])
    }
    
}


//
//  HideBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/16/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

class HideBrickViewController: BrickApp.BaseBrickController, HasTitle {

    class var brickTitle: String {
        return "Hide Bricks"
    }
    class var subTitle: String {
        return "Example of hiding bricks"
    }

    struct Identifiers {
        static let HideBrickButton = "HideBrickButton"
        static let HideSectionButton = "HideSectionButton"

        static let SimpleBrick = "SimpleBrick"
        static let SimpleSection = "SimpleSection"
    }

    var hideBrickButton: ButtonBrick!
    var hideSectionButton: ButtonBrick!

    var brickHidden = false
    var sectionHidden = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerBrickClass(ButtonBrick.self)
        self.registerBrickClass(LabelBrick.self)

        self.layout.hideBehaviorDataSource = self

        hideBrickButton = ButtonBrick(HideBrickViewController.Identifiers.HideBrickButton, backgroundColor: .brickGray1, title: titleForHideBrickButton) { [weak self] _ in
            self?.hideBrick()
        }

        hideSectionButton = ButtonBrick(HideBrickViewController.Identifiers.HideSectionButton, backgroundColor: .brickGray1, title: titleForHideSectionButton) { [weak self] _ in
            self?.hideSection()
        }

        self.collectionView?.backgroundColor = .brickBackground

        let section = BrickSection(bricks: [
            LabelBrick(HideBrickViewController.Identifiers.SimpleBrick, backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "BRICK", configureCellBlock: LabelBrickCell.configure)),
            hideBrickButton,
            BrickSection(HideBrickViewController.Identifiers.SimpleSection, backgroundColor: .brickGray3, bricks: [
                LabelBrick(width: .ratio(ratio: 0.5), backgroundColor: .brickGray5, dataSource: LabelBrickCellModel(text: "BRICK", configureCellBlock: LabelBrickCell.configure)),
                LabelBrick(width: .ratio(ratio: 0.5), backgroundColor: .brickGray5, dataSource: LabelBrickCellModel(text: "BRICK", configureCellBlock: LabelBrickCell.configure)),
                ]),
            hideSectionButton
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

        self.setSection(section)
    }

    var titleForHideBrickButton: String {
        return "\(brickHidden ? "Show" : "Hide") Brick".uppercased()
    }

    var titleForHideSectionButton: String {
        return "\(sectionHidden ? "Show" : "Hide") Section".uppercased()
    }

    func hideBrick() {
        brickHidden = !brickHidden
        hideBrickButton.title = titleForHideBrickButton
        brickCollectionView.invalidateVisibility()
        reloadBricksWithIdentifiers([HideBrickViewController.Identifiers.HideBrickButton])
    }

    func hideSection() {
        sectionHidden = !sectionHidden
        hideSectionButton.title = titleForHideSectionButton
        brickCollectionView.invalidateVisibility()
        reloadBricksWithIdentifiers([HideBrickViewController.Identifiers.HideSectionButton])
    }

}

extension HideBrickViewController: HideBehaviorDataSource {

    func hideBehaviorDataSource(shouldHideItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        switch identifier {
        case HideBrickViewController.Identifiers.SimpleBrick:
            return brickHidden
        case HideBrickViewController.Identifiers.SimpleSection:
            return sectionHidden
        default:
            return false
        }
    }
}


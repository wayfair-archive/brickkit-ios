//
//  EmbeddedSpotlightSnapScrollingViewController.swift
//  BrickKit
//
//  Created by DJ Riefler on 10/4/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

private let spotlightBrick = "SpotlightBrick"
class EmbeddedSpotlightSnapScrollingViewController: BaseScrollingViewController {
    override class var title: String {
        return "Snap Spotlight"
    }
    override class var subTitle: String {
        return "Spotlight with SnapToPointBehavior"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let spotlightHeight: CGFloat = 300
        let notInSpotlightHeight: CGFloat = 150

        let section = BrickSection(bricks: [
            LabelBrick(height: .Fixed(size: notInSpotlightHeight), backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "Not in the spotlight".uppercaseString, configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(height: .Fixed(size: notInSpotlightHeight), backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "Neither am I".uppercaseString, configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(height: .Fixed(size: notInSpotlightHeight), backgroundColor: .brickGray5, dataSource: LabelBrickCellModel(text: "Or me".uppercaseString, configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(spotlightBrick, height: .Fixed(size: spotlightHeight), backgroundColor: .brickGray2, dataSource: LabelBrickCellModel(text: "Im the first brick in spotlight".uppercaseString, configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(spotlightBrick, height: .Fixed(size: spotlightHeight), backgroundColor: .brickGray4, dataSource: LabelBrickCellModel(text: "Spotlight Brick 2".uppercaseString, configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(spotlightBrick, height: .Fixed(size: spotlightHeight), backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "Spotlight Brick 3".uppercaseString, configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(spotlightBrick, height: .Fixed(size: spotlightHeight), backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "Spotlight Brick 4".uppercaseString, configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(spotlightBrick, height: .Fixed(size: spotlightHeight), backgroundColor: .brickGray5, dataSource: LabelBrickCellModel(text: "Spotlight Brick 5".uppercaseString, configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(spotlightBrick, height: .Fixed(size: spotlightHeight), backgroundColor: .brickGray2, dataSource: LabelBrickCellModel(text: "Spotlight Brick 6".uppercaseString, configureCellBlock: LabelBrickCell.configure)),
            ])
        self.setSection(section)

        let spotlightBehavior = SpotlightLayoutBehavior(dataSource: self)
        spotlightBehavior.lastBrickStretchy = true
        spotlightBehavior.scrollLastBrickToTop = false

        behavior = spotlightBehavior
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .Vertical(.Top))

        self.layout.behaviors.insert(snapBehavior)

    }
}

extension EmbeddedSpotlightSnapScrollingViewController: SpotlightLayoutBehaviorDataSource {
    func spotlightLayoutBehavior(behavior: SpotlightLayoutBehavior, smallHeightForItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGFloat? {
        return identifier == spotlightBrick ? 100 : nil
    }
}

//
//  EmbeddedSpotlightSnapScrollingViewController.swift
//  BrickKit
//
//  Created by DJ Riefler on 10/4/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

private let spotlightBrick = "SpotlightBrick"
class EmbeddedSpotlightSnapScrollingViewController: BaseScrollingViewController, HasTitle {
    class var brickTitle: String {
        return "Snap Spotlight"
    }
    class var subTitle: String {
        return "Spotlight with SnapToPointBehavior"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let spotlightHeight: CGFloat = 300
        let notInSpotlightHeight: CGFloat = 150

        let section = BrickSection(bricks: [
            LabelBrick(height:
                .fixed(size: notInSpotlightHeight), backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "Not in the spotlight".uppercased(), configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(height: .fixed(size: notInSpotlightHeight), backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "Neither am I".uppercased(), configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(height: .fixed(size: notInSpotlightHeight), backgroundColor: .brickGray5, dataSource: LabelBrickCellModel(text: "Or me".uppercased(), configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(spotlightBrick, height: .fixed(size: spotlightHeight), backgroundColor: .brickGray2, dataSource: LabelBrickCellModel(text: "Im the first brick in spotlight".uppercased(), configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(spotlightBrick, height: .fixed(size: spotlightHeight), backgroundColor: .brickGray4, dataSource: LabelBrickCellModel(text: "Spotlight Brick 2".uppercased(), configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(spotlightBrick, height: .fixed(size: spotlightHeight), backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "Spotlight Brick 3".uppercased(), configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(spotlightBrick, height: .fixed(size: spotlightHeight), backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "Spotlight Brick 4".uppercased(), configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(spotlightBrick, height: .fixed(size: spotlightHeight), backgroundColor: .brickGray5, dataSource: LabelBrickCellModel(text: "Spotlight Brick 5".uppercased(), configureCellBlock: LabelBrickCell.configure)),
            LabelBrick(spotlightBrick, height: .fixed(size: spotlightHeight), backgroundColor: .brickGray2, dataSource: LabelBrickCellModel(text: "Spotlight Brick 6".uppercased(), configureCellBlock: LabelBrickCell.configure)),
            ])
        self.setSection(section)

        let spotlightBehavior = SpotlightLayoutBehavior(dataSource: self)
        spotlightBehavior.lastBrickStretchy = true
        spotlightBehavior.scrollLastBrickToTop = false

        behavior = spotlightBehavior
        let snapBehavior = SnapToPointLayoutBehavior(scrollDirection: .vertical(.top))

        self.layout.behaviors.insert(snapBehavior)

    }
}

extension EmbeddedSpotlightSnapScrollingViewController: SpotlightLayoutBehaviorDataSource {
    func spotlightLayoutBehavior(_ behavior: SpotlightLayoutBehavior, smallHeightForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGFloat? {
        return identifier == spotlightBrick ? 100 : nil
    }
}

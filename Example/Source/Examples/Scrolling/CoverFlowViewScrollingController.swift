//
//  CoverFlowScrollingViewController.swift
//  BrickKit-Example
//
//  Created by Randall Spence on 10/11/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import BrickKit

class CoverFlowScrollingViewController: BrickViewController, HasTitle {
    class var brickTitle: String {
        return "Cover Flow"
    }
    
    class var subTitle: String {
        return "Cover Flow layout behavior"
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerBrickClass(LabelBrick.self)

        self.view.backgroundColor = .brickBackground

        let section = BrickSection(bricks: [
            LabelBrick("Brick 1", width: .ratio(ratio: 0.5), height: .ratio(ratio: 1.0), backgroundColor: .brickGray1, dataSource: self),
            LabelBrick("Brick 2", width: .ratio(ratio: 0.5), height: .ratio(ratio: 1.0), backgroundColor: .brickGray3, dataSource: self),
            LabelBrick("Brick 3", width: .ratio(ratio: 0.5), height: .ratio(ratio: 1.0), backgroundColor: .brickGray5, dataSource: self),
            LabelBrick("Brick 4", width: .ratio(ratio: 0.5), height: .ratio(ratio: 1.0), backgroundColor: .brickGray2, dataSource: self),
            LabelBrick("Brick 5", width: .ratio(ratio: 0.5), height: .ratio(ratio: 1.0), backgroundColor: .brickGray4, dataSource: self),
            LabelBrick("Brick 6", width: .ratio(ratio: 0.5), height: .ratio(ratio: 1.0), backgroundColor: .brickGray1, dataSource: self),
            ])

        self.setSection(section)


        let snapToBehavior = SnapToPointLayoutBehavior(scrollDirection: .horizontal(.center))
        self.brickCollectionView.layout.behaviors.insert(snapToBehavior)

        self.brickCollectionView.layout.behaviors.insert(CoverFlowLayoutBehavior(minimumScaleFactor: 0.75))

        layout.scrollDirection = .horizontal
    }

}

extension CoverFlowScrollingViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        cell.configure()
        cell.label.text = cell.brick.identifier.uppercased()
    }
}

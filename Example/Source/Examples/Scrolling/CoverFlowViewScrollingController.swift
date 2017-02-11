//
//  CoverFlowScrollingViewController.swift
//  BrickKit-Example
//
//  Created by Randall Spence on 10/11/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import BrickKit

class CoverFlowScrollingViewController: BrickViewController {
    override class var title: String {
        return "Cover Flow"
    }
    
    override class var subTitle: String {
        return "Cover Flow layout behavior"
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerBrickClass(LabelBrick.self)

        self.view.backgroundColor = .brickBackground

        let section = BrickSection(bricks: [
            LabelBrick("Brick 1", width: .Ratio(ratio: 0.5), height: .Ratio(ratio: 1.0), backgroundColor: .brickGray1, dataSource: self),
            LabelBrick("Brick 2", width: .Ratio(ratio: 0.5), height: .Ratio(ratio: 1.0), backgroundColor: .brickGray3, dataSource: self),
            LabelBrick("Brick 3", width: .Ratio(ratio: 0.5), height: .Ratio(ratio: 1.0), backgroundColor: .brickGray5, dataSource: self),
            LabelBrick("Brick 4", width: .Ratio(ratio: 0.5), height: .Ratio(ratio: 1.0), backgroundColor: .brickGray2, dataSource: self),
            LabelBrick("Brick 5", width: .Ratio(ratio: 0.5), height: .Ratio(ratio: 1.0), backgroundColor: .brickGray4, dataSource: self),
            LabelBrick("Brick 6", width: .Ratio(ratio: 0.5), height: .Ratio(ratio: 1.0), backgroundColor: .brickGray1, dataSource: self),
            ])

        self.setSection(section)


        let snapToBehavior = SnapToPointLayoutBehavior(scrollDirection: .Horizontal(.Center))
        self.brickCollectionView.layout.behaviors.insert(snapToBehavior)

        self.brickCollectionView.layout.behaviors.insert(CoverFlowLayoutBehavior(minimumScaleFactor: 0.75))

        layout.scrollDirection = .Horizontal
    }

}

extension CoverFlowScrollingViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(cell: LabelBrickCell) {
        cell.configure()
        cell.label.text = cell.brick.identifier.uppercased()
    }
}

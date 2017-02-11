//
//  BaseScrollingViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/4/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

class BaseScrollingViewController: BrickApp.BaseBrickController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.registerBrickClass(LabelBrick.self)

        let height:CGFloat = 300
        let section = BrickSection("Test", bricks: [
            LabelBrick(BrickIdentifiers.repeatLabel, height: .fixed(size: height), backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "Brick 1")),
            LabelBrick(BrickIdentifiers.repeatLabel, height: .fixed(size: height), backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "Brick 2")),
            LabelBrick(BrickIdentifiers.repeatLabel, height: .fixed(size: height), backgroundColor: .brickGray5, dataSource: LabelBrickCellModel(text: "Brick 3")),
            LabelBrick(BrickIdentifiers.repeatLabel, height: .fixed(size: height), backgroundColor: .brickGray2, dataSource: LabelBrickCellModel(text: "Brick 4")),
            LabelBrick(BrickIdentifiers.repeatLabel, height: .fixed(size: height), backgroundColor: .brickGray4, dataSource: LabelBrickCellModel(text: "Brick 5")),
            LabelBrick(BrickIdentifiers.repeatLabel, height: .fixed(size: height), backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "Brick 6")),
            ])

        self.setSection(section)
    }
}

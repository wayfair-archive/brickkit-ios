//
//  FillBrickViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 12/4/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class FillBrickViewController: BrickViewController {
    override class var title: String {
        return "Fill Example"
    }

    override class var subTitle: String {
        return "Example of using the Fill BrickDimension"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerBrickClass(LabelBrick.self)

        self.view.backgroundColor = .brickBackground

        let configureCell: (cell: LabelBrickCell) -> Void = { cell in
            cell.configure()
        }

        let section = BrickSection(bricks: [
            LabelBrick(width: .Fixed(size: 50), backgroundColor: .brickGray1, text: "BRICK", configureCellBlock: configureCell),
            LabelBrick(width: .Fill, backgroundColor: .brickGray3, text: "BRICK", configureCellBlock: configureCell),
            LabelBrick(width: .Fill, backgroundColor: .brickGray5, text: "BRICK", configureCellBlock: configureCell),
            LabelBrick(width: .Fixed(size: 50), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: configureCell),
            BrickSection(width: .Fill, backgroundColor: .brickGray4, bricks: [
                LabelBrick(width: .Ratio(ratio: 0.25), backgroundColor: .brickGray1, text: "BRICK", configureCellBlock: configureCell),
                LabelBrick(width: .Fill, backgroundColor: .brickGray3, text: "BRICK", configureCellBlock: configureCell),
                ])
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10))

        self.setSection(section)
    }
    
}


//
//  FillBrickViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 12/4/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class FillBrickViewController: BrickViewController, HasTitle {
    class var brickTitle: String {
        return "Fill Example"
    }

    class var subTitle: String {
        return "Example of using the Fill BrickDimension"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerBrickClass(LabelBrick.self)

        self.view.backgroundColor = .brickBackground

        let section = BrickSection(bricks: [
            LabelBrick(width: .fixed(size: 100), backgroundColor: .brickGray1, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .fill, backgroundColor: .brickGray3, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .fill, backgroundColor: .brickGray5, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .fixed(size: 100), backgroundColor: .brickGray2, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            BrickSection(width: .fill, backgroundColor: .brickGray4, bricks: [
                LabelBrick(width: .ratio(ratio: 1/3), backgroundColor: .brickGray1, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
                LabelBrick(width: .fill, backgroundColor: .brickGray3, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
                ])
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10))

        self.setSection(section)
    }
    
}


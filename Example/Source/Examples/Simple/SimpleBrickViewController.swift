//
//  SimpleBrickViewController.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

class SimpleBrickViewController: BrickApp.BaseBrickController, HasTitle {

    class var brickTitle: String {
        return "Simple Example"
    }
    
    class var subTitle: String {
        return "Basic example of using different brick widths and dynamic heights"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        let section = BrickSection(bricks: [
            LabelBrick(backgroundColor: .brickGray1, text: "BRICK 1", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(backgroundColor: .brickGray3, text: "MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .ratio(ratio: 1/2), backgroundColor: .brickGray5, text: "1/2 BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .ratio(ratio: 1/2), backgroundColor: .brickGray5, text: "1/2 BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .ratio(ratio: 1/3), backgroundColor: .brickGray2, text: "1/3 BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .ratio(ratio: 1/3), backgroundColor: .brickGray2, text: "1/3 BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(width: .ratio(ratio: 1/3), backgroundColor: .brickGray2, text: "1/3 BRICK", configureCellBlock: LabelBrickCell.configure),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

        self.setSection(section)
    }

}

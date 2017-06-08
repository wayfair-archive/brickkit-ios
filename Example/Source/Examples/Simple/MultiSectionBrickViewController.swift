//
//  MultiSectionBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/14/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class MultiSectionBrickViewController: BrickApp.BaseBrickController, HasTitle {
    
    class var brickTitle: String {
        return "Multi Sections"
    }
    
    class var subTitle: String {
        return "Example that shows the power of using sections in sections"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(width: .ratio(ratio: 0.5), backgroundColor: .brickGray1, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            BrickSection(width: .ratio(ratio: 0.5) , backgroundColor: .brickGray1, bricks: [
                LabelBrick(backgroundColor: .brickGray3, text: "BRICK\nBRICK", configureCellBlock: LabelBrickCell.configure),
                LabelBrick(backgroundColor: .brickGray3, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
                LabelBrick(backgroundColor: .brickGray3, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
                ], inset: 10),
            BrickSection(backgroundColor: .brickGray1, bricks: [
                BrickSection(width: .ratio(ratio: 1/3), backgroundColor: .brickGray3, bricks: [
                    LabelBrick(backgroundColor: .brickGray5, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
                    LabelBrick(backgroundColor: .brickGray5, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
                    ], inset: 5),
                BrickSection(width: .ratio(ratio: 2/3), backgroundColor: .brickGray3, bricks: [
                    LabelBrick(backgroundColor: .brickGray5, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
                    LabelBrick(backgroundColor: .brickGray5, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
                    LabelBrick(backgroundColor: .brickGray5, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
                    ], inset: 15),
                ], inset: 5, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)),
            BrickSection(width: .ratio(ratio: 0.5) , backgroundColor: .brickGray1, bricks: [
                LabelBrick(backgroundColor: .brickGray3, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
                LabelBrick(backgroundColor: .brickGray3, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
                ], inset: 10),
            LabelBrick(width: .ratio(ratio: 0.5), backgroundColor: .brickGray1, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            LabelBrick(backgroundColor: .brickGray1, text: "BRICK", configureCellBlock: LabelBrickCell.configure),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

        self.setSection(section)
    }
    
}

//
//  SimpleBrickViewController.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

class SimpleBrickViewController: BrickApp.BaseBrickController {

    override class var title: String {
        return "Simple Example"
    }
    
    override class var subTitle: String {
        return "Basic example of using different brick widths and dynamic heights"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerBrickClass(LabelBrick.self)

        self.view.backgroundColor = .brickBackground

        let configureCell: (cell: LabelBrickCell) -> Void = { cell in
            cell.configure()
        }

        let section = BrickSection(bricks: [
            LabelBrick(backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "BRICK 1", configureCellBlock: configureCell)),
            LabelBrick(backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK", configureCellBlock: configureCell)),
            LabelBrick(width: .Ratio(ratio: 1/2), backgroundColor: .brickGray5, dataSource: LabelBrickCellModel(text: "1/2 BRICK", configureCellBlock: configureCell)),
            LabelBrick(width: .Ratio(ratio: 1/2), backgroundColor: .brickGray5, dataSource: LabelBrickCellModel(text: "1/2 BRICK", configureCellBlock: configureCell)),
            LabelBrick(width: .Ratio(ratio: 1/3), backgroundColor: .brickGray2, dataSource: LabelBrickCellModel(text: "1/3 BRICK", configureCellBlock: configureCell)),
            LabelBrick(width: .Ratio(ratio: 1/3), backgroundColor: .brickGray2, dataSource: LabelBrickCellModel(text: "1/3 BRICK", configureCellBlock: configureCell)),
            LabelBrick(width: .Ratio(ratio: 1/3), backgroundColor: .brickGray2, dataSource: LabelBrickCellModel(text: "1/3 BRICK", configureCellBlock: configureCell)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

        self.setSection(section)
    }

}

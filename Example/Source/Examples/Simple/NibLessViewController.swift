
//
//  NibLessViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 10/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class NibLessViewController: BrickViewController, HasTitle {

    class var brickTitle: String {
        return "Nibless Brick"
    }

    class var subTitle: String {
        return "Example of using a Brick without a nib"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .brickBackground

        registerBrickClass(NiblessBrick.self)

        let section = BrickSection(bricks: [
            NiblessBrick(backgroundColor: .brickGray1, text: "BRICK", image: UIImage(named: "logo_splash")!, configureCell: NibLessViewController.configureCell),
            NiblessBrick(width: .ratio(ratio: 1/2), backgroundColor: .brickGray3, text: "BRICK", image: UIImage(named: "logo_inapp")!, configureCell: NibLessViewController.configureCell),
            NiblessBrick(width: .ratio(ratio: 1/2), backgroundColor: .brickGray3, text: "BRICK", image: UIImage(named: "logo_inapp")!, configureCell: NibLessViewController.configureCell)
            ], inset: 10)
        setSection(section)
    }

    static func configureCell(cell: NiblessBrickCell) {
        cell.label.textAlignment = .center
        cell.label.textColor = cell.brick.backgroundColor.complemetaryColor
    }

}

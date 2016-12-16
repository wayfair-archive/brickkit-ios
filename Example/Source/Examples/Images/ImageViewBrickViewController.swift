//
//  ImageBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/15/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class ImageViewBrickViewController: BrickViewController {

    override class var title: String {
        return "Image URL Example"
    }
    override class var subTitle: String {
        return "ImageBrick using UIImage"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        registerBrickClass(ImageBrick.self)
        registerBrickClass(LabelBrick.self)

        let section = BrickSection("RootSection", bricks: [
            LabelBrick("L1", height: .Fixed(size: 38), backgroundColor: .brickGray1, text: "Fixed height with ScaleAspectFit", configureCellBlock: LabelBrickCell.configure),
            ImageBrick("I1", width: .Ratio(ratio: 1), height: .Fixed(size: 50), backgroundColor: .brickGray3, dataSource: ImageBrickModel(image: UIImage(named: "image0")!, contentMode: .ScaleAspectFit)),
            LabelBrick("L1", height: .Fixed(size: 38), backgroundColor: .brickGray1, text: "Dynamic height", configureCellBlock: LabelBrickCell.configure),
            ImageBrick("I1", width: .Ratio(ratio: 1), height: .Auto(estimate: .Fixed(size: 50)), backgroundColor: .brickGray3, dataSource: ImageBrickModel(image: UIImage(named: "image1")!, contentMode: .ScaleAspectFit)),
            LabelBrick("L1", height: .Fixed(size: 38), backgroundColor: .brickGray1, text: "Fixed height with ScaleAspectFill", configureCellBlock: LabelBrickCell.configure),
            ImageBrick("I1", width: .Ratio(ratio: 1), height: .Fixed(size: 50), backgroundColor: .brickGray3, dataSource: ImageBrickModel(image: UIImage(named: "image2")!, contentMode: .ScaleAspectFill)),
            ], inset: 10)

        self.setSection(section)

    }
}

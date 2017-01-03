//
//  ImageBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/15/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class ImageURLBrickViewController: BrickViewController {

    override class var title: String {
        return "Image URL Example"
    }
    override class var subTitle: String {
        return "ImageBrick using NSURL"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        registerBrickClass(ImageBrick.self)
        registerBrickClass(LabelBrick.self)

        let imageURL = NSURL(string:"https://secure.img2.wfrcdn.com/lf/8/hash/2664/10628031/1/custom_image.jpg")!

        let section = BrickSection("RootSection", bricks: [
            LabelBrick("L1", height: .Fixed(size: 38), backgroundColor: .brickGray1, text: "Below is an image brick with fixed height", configureCellBlock: LabelBrickCell.configure),
            ImageBrick("I1", width: .Ratio(ratio: 1), height: .Fixed(size: 50), backgroundColor: .brickGray3, dataSource: ImageURLBrickModel(url: imageURL, contentMode: .ScaleAspectFit)),
            LabelBrick("L1", height: .Fixed(size: 38), backgroundColor: .brickGray1, text: "Below is an image brick loaded dynamically", configureCellBlock: LabelBrickCell.configure),
            ImageBrick("I1", width: .Ratio(ratio: 1), height: .Auto(estimate: .Fixed(size: 50)), backgroundColor: .brickGray3, dataSource: ImageURLBrickModel(url: imageURL, contentMode: .ScaleAspectFit)),
            LabelBrick("L1", height: .Fixed(size: 38), backgroundColor: .brickGray1, text: "Below is an image brick with fixed height", configureCellBlock: LabelBrickCell.configure),
            ImageBrick("I1", width: .Ratio(ratio: 1), height: .Fixed(size: 50), backgroundColor: .brickGray3, dataSource: ImageURLBrickModel(url: imageURL, contentMode: .ScaleAspectFill)),
            ], inset: 10)

        self.setSection(section)

    }

}

//
//  ImageBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/15/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class ImageURLBrickViewController: BrickViewController, HasTitle {

    class var brickTitle: String {
        return "Image URL Example"
    }
    class var subTitle: String {
        return "ImageBrick using NSURL"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        registerBrickClass(ImageBrick.self)
        registerBrickClass(LabelBrick.self)

        let imageURL = URL(string:"https://secure.img2.wfrcdn.com/lf/8/hash/2664/10628031/1/custom_image.jpg")!

        let section = BrickSection("RootSection", bricks: [
            LabelBrick("L1", height: .fixed(size: 38), backgroundColor: .brickGray1, text: "Below is an image brick with fixed height", configureCellBlock: LabelBrickCell.configure),
            ImageBrick("I1", width: .ratio(ratio: 1), height: .fixed(size: 50), backgroundColor: .brickGray3, dataSource: ImageURLBrickModel(url: imageURL as URL, contentMode: .scaleAspectFit)),
            LabelBrick("L1", height: .fixed(size: 38), backgroundColor: .brickGray1, text: "Below is an image brick loaded dynamically", configureCellBlock: LabelBrickCell.configure),
            ImageBrick("I1", width: .ratio(ratio: 1), height: .auto(estimate: .fixed(size: 50)), backgroundColor: .brickGray3, dataSource: ImageURLBrickModel(url: imageURL, contentMode: .scaleAspectFit)),
            LabelBrick("L1", height: .fixed(size: 38), backgroundColor: .brickGray1, text: "Below is an image brick with fixed height", configureCellBlock: LabelBrickCell.configure),
            ImageBrick("I1", width: .ratio(ratio: 1), height: .fixed(size: 50), backgroundColor: .brickGray3, dataSource: ImageURLBrickModel(url: imageURL, contentMode: .scaleAspectFill)),
            ], inset: 10)

        self.setSection(section)

    }

}

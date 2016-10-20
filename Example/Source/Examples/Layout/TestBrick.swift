//
//  TestBrick.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit
import UIKit

class TestBrick: Brick {
    var image: UIImage? = UIImage(named: "ImageCarouselExample")
}

class TestBrickCell: BrickCell, Bricklike {
    typealias BrickType = TestBrick

    @IBOutlet weak var imageView: UIImageView!

    override func updateContent() {
        super.updateContent()
        self.imageView.image = brick.image
    }
}

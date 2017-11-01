//
//  FrameInfoBrick.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 7/17/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

class FrameInfoBrick: Brick {
}

class FrameInfoBrickCell: BrickCell, Bricklike {
    typealias BrickType = FrameInfoBrick
    
    @IBOutlet weak var imageView: UIImageView!

    var firstReportedImageViewFrame: CGRect?

    override open func framesDidLayout() {
        super.framesDidLayout()
        assert(Thread.isMainThread)
        if firstReportedImageViewFrame == nil {
            firstReportedImageViewFrame = self.imageView.frame
        }
    }
}

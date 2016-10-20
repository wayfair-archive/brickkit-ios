//
//  SizeClassBrick.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class SizeClassBrick: Brick {
    var text: String?
    var color: UIColor?
}

class SizeClassBrickCell: BrickCell, Bricklike {
    typealias BrickType = SizeClassBrick

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    override func updateContent() {
        super.updateContent()

        view.backgroundColor = self.brick.color
        label.text = self.brick.text
        label.textColor = self.brick.backgroundColor.complemetaryColor

        infoLabel.textColor = self.brick.color?.complemetaryColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        infoLabel?.text = "\(frame.height)px HEIGHT"
    }

}

//
//  TwoLabelBrick.swift
//  BrickKit iOS Example
//
//  Created by Ruben Cagnie on 10/11/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import BrickKit

class TwoLabelBrick: LabelBrick {
}


class TwoLabelBrickCell: LabelBrickCell {
    @IBOutlet weak var subLabel: UILabel!

    override func updateContent() {
        super.updateContent()

        self.imageView?.image = UIImage(named: "chevron", inBundle: NSBundle(forClass: LabelBrickCell.classForCoder()), compatibleWithTraitCollection: nil)
    }
}

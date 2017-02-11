//
//  TwoLabelBrick.swift
//  BrickKit iOS Example
//
//  Created by Ruben Cagnie on 10/11/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import BrickKit

class TwoLabelBrick: LabelBrick {

    // Return nil, so the brick is loaded from the nib instead of the GenericBrickCell
    override class var cellClass: UICollectionViewCell.Type? {
        return nil
    }

    override class var bundle: Bundle {
        return Bundle(forClass: TwoLabelBrick.self)
    }

}


class TwoLabelBrickCell: LabelBrickCell {
    @IBOutlet weak var subLabel: UILabel!

    override func updateContent() {
        super.updateContent()

        self.imageView?.image = UIImage(named: "chevron", inBundle: Bundle(forClass: LabelBrickCell.classForCoder()), compatibleWithTraitCollection: nil)
    }
}

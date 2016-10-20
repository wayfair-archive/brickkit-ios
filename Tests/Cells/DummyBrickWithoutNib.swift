//
//  DummyBrickWithoutNib.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class DummyBrickWithNoNib: Brick {
}

class DummyBrickWithoutNib: Brick {

    class override var cellClass: UICollectionViewCell.Type? {
        return DummyBrickWithoutNibCell.self
    }

}

class DummyBrickWithoutNibCell: BrickCell {
    override func heightForBrickView(withWidth width: CGFloat) -> CGFloat {
        return 50
    }
}

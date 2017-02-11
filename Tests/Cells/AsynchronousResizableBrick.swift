//
//  DummyAsynchronousResizableCell.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class AsynchronousResizableBrick: Brick {

    var didChangeSizeCallBack: (() -> Void)?
    var newHeight: CGFloat = 200

}

class AsynchronousResizableBrickCell: BrickCell, Bricklike, AsynchronousResizableCell {
    typealias BrickType = AsynchronousResizableBrick

    var sizeChangedHandler: CellSizeChangedHandler?

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var timer: Timer?

    override func updateContent() {
        super.updateContent()

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AsynchronousResizableBrickCell.fireTimer), userInfo: nil, repeats: false)
    }

    func fireTimer() {
        self.heightConstraint.constant = brick.newHeight
        sizeChangedHandler?(cell: self)
        brick.didChangeSizeCallBack?()
    }

}

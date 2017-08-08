//
//  DummyResizableBrick.swift
//  BrickKit
//
//  Created by Peter Cheung on 7/28/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import Foundation
import BrickKit

class DummyResizableBrick: Brick {
    var didChangeSizeCallBack: (() -> Void)?
    let newHeight: CGFloat
    
    public init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, setHeight: CGFloat) {
        self.newHeight = setHeight
        super.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView)
    }
}

class DummyResizableBrickCell: BrickCell, Bricklike  {
    typealias BrickType = DummyResizableBrick
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    override func updateContent() {
        self.heightConstraint.constant = brick.newHeight
        super.updateContent()
    }
    
    func changeHeight(newHeight: CGFloat) {
        self.heightConstraint.constant = newHeight
    }
}


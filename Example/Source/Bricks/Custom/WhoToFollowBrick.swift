//
//  WhoToFollow.swift
//  BrickKit
//
//  Created by Yusheng Yang on 9/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation
import BrickKit

class WhoToFollowBrick: Brick {
    weak var dataSource: WhoToFollowBrickDataSource?
    
    init(_ identifier: String, width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, dataSource: WhoToFollowBrickDataSource) {
        self.dataSource = dataSource
        super.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView)
    }
}

protocol WhoToFollowBrickDataSource: class {
    func whoToFollowImage(cell: WhoToFollowBrickCell) -> UIImage
    func whoToFollowTitle(cell: WhoToFollowBrickCell) -> String
    func whoToFollowDescription(cell: WhoToFollowBrickCell) -> String
    func whoToFollowAtTag(cell: WhoToFollowBrickCell) -> String
}

class WhoToFollowBrickCell: BrickCell, Bricklike {
    typealias BrickType = WhoToFollowBrick
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var atTag: UILabel!
    
    override func updateContent() {
        super.updateContent()
        
        followButton.layer.cornerRadius = 5.0
        followButton.layer.borderWidth = 1.0
        followButton.layer.borderColor = self.tintColor.CGColor
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        
        imageView.image = brick.dataSource?.whoToFollowImage(self)
        titleLabel.text = brick.dataSource?.whoToFollowTitle(self)
        descriptionLabel.text = brick.dataSource?.whoToFollowDescription(self)
        atTag.text = brick.dataSource?.whoToFollowAtTag(self)
        
    }
}

//
//  ProfileHeaderBrick.swift
//  BrickKit
//
//  Created by Yusheng Yang on 9/22/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class ProfileHeaderBrick: Brick {
    let model: ProfileHeaderModel

    init(_ identifier: String, width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 100)), backgroundColor: UIColor = UIColor.white, backgroundView: UIView? = nil, model: ProfileHeaderModel) {
        self.model = model
        super.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView)
    }
}

class ProfileHeaderModel {
    var name: String
    var handle: String
    var description: String
    var numberOfFollowing: Int
    var numberOfFollowers: Int

    init(name: String, handle: String, description: String, numberOfFollowing: Int, numberOfFollowers: Int) {
        self.name = name
        self.handle = handle
        self.description = description
        self.numberOfFollowing = numberOfFollowing
        self.numberOfFollowers = numberOfFollowers
    }
}

class ProfileHeaderBrickCell: BrickCell, Bricklike {
    typealias BrickType = ProfileHeaderBrick
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    
    override func updateContent() {
        super.updateContent()

        let model = brick.model

        self.nameLabel.text = model.name
        self.handleLabel.text = model.handle
        self.descriptionLabel.text = model.description
        self.followingLabel.text = "\(model.numberOfFollowing) FOLLOWING"
        self.followersLabel.text = "\(model.numberOfFollowers) FOLLOWER\(model.numberOfFollowers == 1 ? "" : "S")"
    }
}

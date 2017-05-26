//
//  File.swift
//  BrickKit
//
//  Created by Yusheng Yang on 9/23/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation
import BrickKit

class ProfileImageBrickModel {
    var image: UIImage

    init(image: UIImage) {
        self.image = image
    }

}

class ProfileImageBrick: Brick {
    var model: ProfileImageBrickModel
    
    init(_ identifier: String, width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .fixed(size: 60), backgroundColor: UIColor = UIColor.white, backgroundView: UIView? = nil, model: ProfileImageBrickModel) {
        self.model = model
        super.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView)
    }
}

class ProfileImageBrickCell: BrickCell, Bricklike {
    typealias BrickType = ProfileImageBrick
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    
    override func updateContent() {
        super.updateContent()
        
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.image = brick.model.image
        
        followButton.layer.cornerRadius = 4
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = self.tintColor.cgColor
        
    }
}

protocol ProfileImageBrickDataSource {
    
}

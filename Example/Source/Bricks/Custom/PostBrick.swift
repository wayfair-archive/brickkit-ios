//
//  PostBrick.swift
//  BrickKit
//
//  Created by Yusheng Yang on 9/19/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

protocol PostBrickCellDataSource {
    func textImageBrickProfile(cell: PostBrickCell) -> UIImage
    func textImageBrickName(cell: PostBrickCell) -> String
    func textImageBrickText(cell: PostBrickCell) -> String
    func textImageBrickImage(cell: PostBrickCell) -> UIImage
    func textImageBrickAtTag(cell: PostBrickCell) ->String
}

class PostBrick: Brick {
    let dataSource: PostBrickCellDataSource
    
    init(_ identifier: String, width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 300)), backgroundColor: UIColor = UIColor.whiteColor(), backgroundView: UIView? = nil, dataSource: PostBrickCellDataSource) {
        self.dataSource = dataSource
        super.init(identifier, width: width, height: height, backgroundColor: backgroundColor, backgroundView: backgroundView)
    }

}

class PostBrickCell: BrickCell, Bricklike {
    typealias BrickType = PostBrick
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var atTagLabel: UILabel!
    
    
    override func updateContent() {
        super.updateContent()
        
        postImage.layer.cornerRadius = 6
        postImage.clipsToBounds = true
        
        profileImage.layer.cornerRadius = 4
        profileImage.clipsToBounds = true
        
        
        self.profileImage.image = brick.dataSource.textImageBrickProfile(self)
        self.profileNameLabel.text = brick.dataSource.textImageBrickName(self)
        self.postImage.image = brick.dataSource.textImageBrickImage(self)
        self.postLabel.text = brick.dataSource.textImageBrickText(self)
        self.atTagLabel.text = brick.dataSource.textImageBrickAtTag(self)
    }
}


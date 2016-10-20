//
//  ImageDownloaderBrick.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class ImageDownloaderBrick: Brick {
    
}

class ImageDownloaderBrickCell: BrickCell, Bricklike, ImageDownloaderCell {
    typealias BrickType = ImageDownloaderBrick

    var imageDownloader: ImageDownloader?
}

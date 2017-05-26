//
//  ImageDownloaderCellTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class ImageDownloaderCellTests: XCTestCase {
    
    func testImageDownloaderCell() {

        let brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        brickView.registerBrickClass(ImageDownloaderBrick.self)

        let section = BrickSection(bricks: [
            ImageDownloaderBrick(height: .fixed(size: 100))
            ])

        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageDownloaderCell
        XCTAssertNotNil(cell?.imageDownloader)
    }
}

//
//  ImageBrickTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/4/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class FixedUIImageBrickDataSource: ImageBrickDataSource {
    var images: [String: UIImage]

    init(images: [String: UIImage]) {
        self.images = images
    }

    func imageForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIImage? {
        return images[imageBrickCell.brick.identifier]
    }
    
}

class FixedURLImageBrickDataSource: ImageBrickDataSource {
    var imageURLs: [Int: NSURL]

    init(imageURLs: [Int: NSURL]) {
        self.imageURLs = imageURLs
    }


    func imageURLForImageBrickCell(imageBrickCell: ImageBrickCell) -> NSURL? {
        return imageURLs[imageBrickCell.index]
    }

}

class ImageBrickTests: XCTestCase {
    var brickView: BrickCollectionView!
    var image: UIImage!
    var imageURL: NSURL!
    var imageRatio: CGFloat!

    override func setUp() {
        super.setUp()

        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        image = UIImage(named: "image0", inBundle: NSBundle(forClass: self.classForCoder), compatibleWithTraitCollection: nil)!
        imageRatio = image.size.width / image.size.height
        imageURL = NSURL(fileURLWithPath: NSBundle(forClass: self.classForCoder).pathForResource("image0", ofType: "png")!)
    }

    // Mark: - UIImage

    func testUIImageScaleAspectFill() {
        brickView.registerBrickClass(ImageBrick.self)

        let section = BrickSection(bricks: [
            ImageBrick(dataSource: ImageBrickModel(image: image, contentMode: .ScaleAspectFill)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? ImageBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertEqualWithAccuracy(cell1!.frame.height, 320 / imageRatio, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(cell1!.imageView.frame.height, 320 / imageRatio, accuracy: 0.5)

    }

    func testUIImageScaleAspectFit() {
        brickView.registerBrickClass(ImageBrick.self)


        let section = BrickSection(bricks: [
            ImageBrick(dataSource: ImageBrickModel(image: image, contentMode: .ScaleAspectFit)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? ImageBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertEqualWithAccuracy(cell1!.frame.height, 320 / imageRatio, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(cell1!.imageView.frame.height, 320 / imageRatio, accuracy: 0.5)
    }

    func testUIImageScaleToFill() {
        brickView.registerBrickClass(ImageBrick.self)


        let section = BrickSection(bricks: [
            ImageBrick(dataSource: ImageBrickModel(image: image, contentMode: .ScaleToFill)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? ImageBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertEqualWithAccuracy(cell1!.frame.height, 320 / imageRatio, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(cell1!.imageView.frame.height, 320 / imageRatio, accuracy: 0.5)

    }

    func testUIImageFixedSize() {
        brickView.registerBrickClass(ImageBrick.self)


        let section = BrickSection(bricks: [
            ImageBrick(width: .Ratio(ratio: 1/4), height: .Ratio(ratio: 1), dataSource: ImageBrickModel(image: image, contentMode: .ScaleAspectFill)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 80, height: 80))
    }

    func testShouldBeNilIfDataSourceReturnsNil() {
        brickView.registerBrickClass(ImageBrick.self)

        let section = BrickSection(bricks: [
            ImageBrick("Brick1", height: .Fixed(size: 480), dataSource: FixedUIImageBrickDataSource(images: ["Brick1": image])),
            ImageBrick("Brick2", height: .Fixed(size: 480), dataSource: FixedUIImageBrickDataSource(images: [:])),
            ])
        section.repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 5])
        brickView.setSection(section)
        brickView.layoutSubviews()

        for i in 0..<5 {
            brickView.contentOffset = CGPoint(x: 0, y: (i + 1) * 480)
            brickView.layoutSubviews()
        }

        let cell = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 5, inSection: 1)) as? ImageBrickCell
        cell?.layoutIfNeeded()
        XCTAssertNil(cell?.imageView.image)
    }

    // Mark: - UIImage

    func testURLImageScaleAspectFill() {
        let expectation = expectationWithDescription("Wait for image to download")
        let defaultImageDownloader = BrickCollectionView.imageDownloader
        let fixedImageDownloader = FixedNSURLSessionImageDownloader { (success) in
            expectation.fulfill()
        }
        
        defer {
            fixedImageDownloader.callback = nil
            BrickCollectionView.imageDownloader = defaultImageDownloader
        }
        BrickCollectionView.imageDownloader = fixedImageDownloader

        brickView.registerBrickClass(ImageBrick.self)

        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURL, contentMode: .ScaleAspectFill)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? ImageBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 50))
        XCTAssertEqual(cell1?.imageView.frame, CGRect(x: 0, y: 0, width: 320, height: 50))

        waitForExpectationsWithTimeout(500, handler: nil)
        brickView.layoutIfNeeded()
        brickView.invalidateBricks()
        
        let ratio:CGFloat = 378 / 659
        XCTAssertEqualWithAccuracy(cell1!.frame.height, 320 * ratio, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(cell1!.imageView.frame.height, 320 * ratio, accuracy: 0.5)
    }
    
    func testURLImageScaleResetSection() {
        var downloadExpectation = expectationWithDescription("Wait for image to download for the first time")
        let defaultImageDownloader = BrickCollectionView.imageDownloader
        
        var fixedImageDownloader = FixedNSURLSessionImageDownloader { (success) in
            downloadExpectation.fulfill()
        }
        
        defer {
            BrickCollectionView.imageDownloader = defaultImageDownloader
        }
        
        BrickCollectionView.imageDownloader = fixedImageDownloader
        
        let delegate = FixedDelegate()
        brickView.layout.delegate = delegate
        
        brickView.registerBrickClass(ImageBrick.self)
        
        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURL, contentMode: .ScaleAspectFill)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()
        
        let cell1 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? ImageBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 50))
        XCTAssertEqual(cell1?.imageView.frame, CGRect(x: 0, y: 0, width: 320, height: 50))
        
        waitForExpectationsWithTimeout(10, handler: nil)
        
        fixedImageDownloader.callback = nil
        
        let invalidateExpectation = expectationWithDescription("Wait for layout to update")
        
        brickView.setSection(section)
        brickView.layoutIfNeeded()
        delegate.didUpdateHandler = {
            invalidateExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
        
        let cell2 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? ImageBrickCell
        cell2?.layoutIfNeeded()
        let ratio:CGFloat = 378 / 659
        XCTAssertTrue(delegate.didUpdateCalled)
        XCTAssertEqualWithAccuracy(cell2!.frame.height, 320 * ratio, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(cell2!.imageView.frame.height, 320 * ratio, accuracy: 0.5)
        
    }
}

class FixedNSURLSessionImageDownloader: NSURLSessionImageDownloader {
    var callback: ((success: Bool) -> Void)?
    init(callback: (success: Bool) -> Void) {
        self.callback = callback
    }

    override func downloadImage(with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage, url: NSURL) -> Void)) {
        super.downloadImage(with: imageURL) { (image, url) in
            completionHandler(image: image, url: url)
            dispatch_async(dispatch_get_main_queue()) {
                self.callback?(success: false)
            }
        }
    }
}


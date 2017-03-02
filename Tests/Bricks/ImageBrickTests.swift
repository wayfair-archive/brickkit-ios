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

class SimpleActionImageBrickDelegate: ImageBrickDelegate {
    var imageSet = false
    
    func didSetImage(brickCell: ImageBrickCell) {
        imageSet = true
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

    override func tearDown() {
        super.tearDown()
        BrickCollectionView.imageDownloader = NSURLSessionImageDownloader() // Reset the image downloader back to the default one (if a test had overwritten this)
    }

    // Mark: - UIImage
    
    func testImageBrickDelegate() {
        brickView.registerBrickClass(ImageBrick.self)
        
        let brick = ImageBrick(dataSource: ImageBrickModel(image: image, contentMode: .ScaleAspectFill))
        let brickDelegate = SimpleActionImageBrickDelegate()
        brick.delegate = brickDelegate
        
        let section = BrickSection(bricks: [brick])
            
        brickView.setSection(section)
        brickView.layoutSubviews()
        
        let cell1 = brickView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? ImageBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertTrue(brickDelegate.imageSet)
    }

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
        var expectation: XCTestExpectation? = expectationWithDescription("testURLImageScaleAspectFill - Wait for image to download")
        BrickCollectionView.imageDownloader = FixedNSURLSessionImageDownloader { (success) in
            dispatch_async(dispatch_get_main_queue()) {
                expectation?.fulfill()
                expectation = nil
            }
        }

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

        waitForExpectationsWithTimeout(2, handler: nil)
        brickView.layoutIfNeeded()
        brickView.invalidateBricks()

        let ratio:CGFloat = 378 / 659
        XCTAssertEqualWithAccuracy(cell1!.frame.height, 320 * ratio, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(cell1!.imageView.frame.height, 320 * ratio, accuracy: 0.5)
    }

    func testURLSetOnMainQueue() {
        var expectation: XCTestExpectation? = expectationWithDescription("testURLSetOnMainQueue - Wait for image to download")
        let fixedImageDownloader = FixedNSURLSessionImageDownloader { (success) in
            XCTAssertEqual(NSOperationQueue.mainQueue().operationCount, 1)
            dispatch_async(dispatch_get_main_queue()) {
                expectation?.fulfill()
                expectation = nil
            }
        }

        BrickCollectionView.imageDownloader = fixedImageDownloader

        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURL, contentMode: .ScaleAspectFill)),
            ])
        brickView.setupSectionAndLayout(section)

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testURLSetOnOtherQueue() {
        var expectation: XCTestExpectation? = expectationWithDescription("testURLSetOnOtherQueue - Wait for image to download")
        let fixedImageDownloader = FixedNSURLSessionImageDownloaderWithCustomSetter { (success) in
            XCTAssertEqual(NSOperationQueue.mainQueue().operationCount, 0)
            dispatch_async(dispatch_get_main_queue()) {
                expectation?.fulfill()
                expectation = nil
            }
        }

        BrickCollectionView.imageDownloader = fixedImageDownloader

        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURL, contentMode: .ScaleAspectFill)),
            ])
        brickView.setupSectionAndLayout(section)

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testURLImageScaleResetSection() {
        var expectation: XCTestExpectation? = expectationWithDescription("testURLImageScaleResetSection - Wait for image to download for the first time")

        let fixedImageDownloader = FixedNSURLSessionImageDownloader { (success) in
            dispatch_async(dispatch_get_main_queue()) {
                expectation?.fulfill()
                expectation = nil
            }
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
        
        waitForExpectationsWithTimeout(2, handler: nil)
        
        fixedImageDownloader.callback = nil
        
        let invalidateExpectation = expectationWithDescription("Wait for layout to update")
        
        brickView.setSection(section)
        brickView.layoutIfNeeded()
        delegate.didUpdateHandler = {
            invalidateExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
        
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
            self.callback?(success: false)
        }
    }
}

class FixedNSURLSessionImageDownloaderWithCustomSetter: NSURLSessionImageDownloader {
    var callback: ((success: Bool) -> Void)?
    init(callback: (success: Bool) -> Void) {
        self.callback = callback
    }

    override func downloadImageAndSet(on imageView: UIImageView, with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage, url: NSURL) -> Void)) {
        self.downloadImage(with: imageURL) { (image, url) in
            guard imageURL == url else {
                return
            }

            imageView.image = image
            completionHandler(image: image, url: url)
            self.callback?(success: false)
        }
    }
}


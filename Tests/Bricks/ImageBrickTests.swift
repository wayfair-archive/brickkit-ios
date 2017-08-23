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

    func imageForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> UIImage? {
        return images[imageBrickCell.brick.identifier]
    }
    
}

class FixedURLImageBrickDataSource: ImageBrickDataSource {
    var imageURLs: [Int: URL]

    init(imageURLs: [Int: URL]) {
        self.imageURLs = imageURLs
    }


    func imageURLForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> URL? {
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
    var imageURL: URL!
    var imageRatio: CGFloat!

    override func setUp() {
        super.setUp()

        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        image = UIImage(named: "image0", in: Bundle(for: self.classForCoder), compatibleWith: nil)!
        imageRatio = image.size.width / image.size.height
        imageURL = URL(fileURLWithPath: Bundle(for: self.classForCoder).path(forResource: "image0", ofType: "png")!)
    }

    override func tearDown() {
        super.tearDown()
        BrickCollectionView.imageDownloader = NSURLSessionImageDownloader() // Reset the image downloader back to the default one (if a test had overwritten this)
    }

    // Mark: - UIImage
    func testImageBrickDelegate() {
        brickView.registerBrickClass(ImageBrick.self)

        let brick = ImageBrick(dataSource: ImageBrickModel(image: image, contentMode: .scaleAspectFill))
        let brickDelegate = SimpleActionImageBrickDelegate()
        brick.delegate = brickDelegate

        let section = BrickSection(bricks: [brick])

        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertTrue(brickDelegate.imageSet)
    }

    func testUIImageScaleAspectFill() {
        brickView.registerBrickClass(ImageBrick.self)

        let section = BrickSection(bricks: [
            ImageBrick(dataSource: ImageBrickModel(image: image, contentMode: .scaleAspectFill)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertEqualWithAccuracy(cell1!.frame.height, 320 / imageRatio, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(cell1!.imageView.frame.height, 320 / imageRatio, accuracy: 0.5)

    }

    func testUIImageScaleAspectFit() {
        brickView.registerBrickClass(ImageBrick.self)


        let section = BrickSection(bricks: [
            ImageBrick(dataSource: ImageBrickModel(image: image, contentMode: .scaleAspectFit)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertEqualWithAccuracy(cell1!.frame.height, 320 / imageRatio, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(cell1!.imageView.frame.height, 320 / imageRatio, accuracy: 0.5)
    }

    func testUIImageScaleToFill() {
        brickView.registerBrickClass(ImageBrick.self)


        let section = BrickSection(bricks: [
            ImageBrick(dataSource: ImageBrickModel(image: image, contentMode: .scaleToFill)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertEqualWithAccuracy(cell1!.frame.height, 320 / imageRatio, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(cell1!.imageView.frame.height, 320 / imageRatio, accuracy: 0.5)

    }

    func testUIImageFixedSize() {
        brickView.registerBrickClass(ImageBrick.self)


        let section = BrickSection(bricks: [
            ImageBrick(width: .ratio(ratio: 1/4), height: .ratio(ratio: 1), dataSource: ImageBrickModel(image: image, contentMode: .scaleAspectFill)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 80, height: 80))
    }

    func testShouldBeNilIfDataSourceReturnsNil() {
        brickView.registerBrickClass(ImageBrick.self)

        let section = BrickSection(bricks: [
            ImageBrick("Brick1", height: .fixed(size: 480), dataSource: FixedUIImageBrickDataSource(images: ["Brick1": image])),
            ImageBrick("Brick2", height: .fixed(size: 480), dataSource: FixedUIImageBrickDataSource(images: [:])),
            ])
        section.repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 5])
        brickView.setSection(section)
        brickView.layoutSubviews()

        for i in 0..<5 {
            brickView.contentOffset = CGPoint(x: 0, y: (i + 1) * 480)
            brickView.layoutSubviews()
        }

        let cell = brickView.cellForItem(at: IndexPath(item: 5, section: 1)) as? ImageBrickCell
        cell?.layoutIfNeeded()
        XCTAssertNil(cell?.imageView.image)
    }

    // Mark: - UIImage

    func testURLImageScaleAspectFill() {
        var expectation: XCTestExpectation? = self.expectation(description: "testURLImageScaleAspectFill - Wait for image to download")
        BrickCollectionView.imageDownloader = FixedNSURLSessionImageDownloader { (success) in
            DispatchQueue.main.async {
                expectation?.fulfill()
                expectation = nil
            }
        }

        brickView.registerBrickClass(ImageBrick.self)

        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURL, contentMode: .scaleAspectFill)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 50))
        XCTAssertEqual(cell1?.imageView.frame, CGRect(x: 0, y: 0, width: 320, height: 50))

        waitForExpectations(timeout: 2, handler: nil)
        brickView.layoutIfNeeded()
        brickView.invalidateBricks()

        let ratio:CGFloat = 378 / 659
        XCTAssertEqualWithAccuracy(cell1!.frame.height, 320 * ratio, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(cell1!.imageView.frame.height, 320 * ratio, accuracy: 0.5)
    }

    func testURLSetOnMainQueue() {
        var expectation: XCTestExpectation? = self.expectation(description: "testURLSetOnMainQueue - Wait for image to download")
        let fixedImageDownloader = FixedNSURLSessionImageDownloader { (success) in
            XCTAssertFalse(Thread.isMainThread)
            expectation?.fulfill()
            expectation = nil
        }

        BrickCollectionView.imageDownloader = fixedImageDownloader

        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURL, contentMode: .scaleAspectFill)),
        ])
        brickView.setupSectionAndLayout(section)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testURLSetOnOtherQueue() {
        var expectation: XCTestExpectation? = self.expectation(description: "testURLSetOnOtherQueue - Wait for image to download")
        let fixedImageDownloader = FixedNSURLSessionImageDownloaderWithCustomSetter { (success) in
            XCTAssertEqual(OperationQueue.main.operationCount, 0)
            DispatchQueue.main.async {
                expectation?.fulfill()
                expectation = nil
            }
        }

        BrickCollectionView.imageDownloader = fixedImageDownloader

        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURL, contentMode: .scaleAspectFill)),
            ])
        brickView.setupSectionAndLayout(section)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testURLImageScaleResetSection() {
        var expectation: XCTestExpectation? = self.expectation(description: "testURLImageScaleResetSection - Wait for image to download for the first time")

        let fixedImageDownloader = FixedNSURLSessionImageDownloader { (success) in
            DispatchQueue.main.async {
                expectation?.fulfill()
                expectation = nil
            }
        }

        BrickCollectionView.imageDownloader = fixedImageDownloader
        
        let delegate = FixedDelegate()
        brickView.layout.delegate = delegate
        
        brickView.registerBrickClass(ImageBrick.self)
        
        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURL, contentMode: .scaleAspectFill)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()
        
        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell
        cell1?.layoutIfNeeded()
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 320, height: 50))
        XCTAssertEqual(cell1?.imageView.frame, CGRect(x: 0, y: 0, width: 320, height: 50))
        
        waitForExpectations(timeout: 2, handler: nil)
        
        fixedImageDownloader.callback = nil
        
        let invalidateExpectation = self.expectation(description: "Wait for layout to update")
        
        brickView.setSection(section)
        brickView.layoutIfNeeded()
        delegate.didUpdateHandler = {
            invalidateExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
        let cell2 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell
        cell2?.layoutIfNeeded()
        let ratio:CGFloat = 378.0 / 659.0
        XCTAssertTrue(delegate.didUpdateCalled)
        XCTAssertEqualWithAccuracy(cell2!.frame.height, 320 * ratio, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(cell2!.imageView.frame.height, 320 * ratio, accuracy: 0.5)
    }
    
    func testImageResetsBeforeReusing() {
        var expectation: XCTestExpectation? = self.expectation(description: "testImageResetsBeforeReusing - Wait for image to download")
        
        let fixedImageDownloader = FixedNSURLSessionImageDownloader { (success) in
            DispatchQueue.main.async {
                expectation?.fulfill()
                expectation = nil
            }
        }
        
        BrickCollectionView.imageDownloader = fixedImageDownloader
        
        brickView.registerBrickClass(ImageBrick.self)
        
        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURL, contentMode: .scaleAspectFill)),
            ])
        
        brickView.setSection(section)
        brickView.layoutSubviews()
        
        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell
        cell1?.imageView.image = self.image
        cell1?.layoutIfNeeded()
        
        waitForExpectations(timeout: 10, handler: nil)

        
        XCTAssertFalse(cell1?.imageView.image == nil)
        cell1?.prepareForReuse()
        XCTAssertTrue(cell1?.imageView.image == nil)
        
    }
}

class FixedNSURLSessionImageDownloader: NSURLSessionImageDownloader {
    var callback: ((_ success: Bool) -> Void)?

    init(callback: @escaping (_ success: Bool) -> Void) {
        self.callback = callback
    }

    override func downloadImage(with imageURL: URL, onCompletion completionHandler: @escaping ((_ image: UIImage, _ url: URL) -> Void)) {
        super.downloadImage(with: imageURL) { (image, url) in
            completionHandler(image, url)
            self.callback?(false)
        }
    }
}

class FixedNSURLSessionImageDownloaderWithCustomSetter: NSURLSessionImageDownloader {
    var callback: ((_ success: Bool) -> Void)?
    init(callback: @escaping (_ success: Bool) -> Void) {
        self.callback = callback
    }

    override func downloadImageAndSet(on imageView: UIImageView, with imageURL: URL, onCompletion completionHandler: @escaping ((_ image: UIImage, _ url: URL) -> Void)) {
        self.downloadImage(with: imageURL) { (image, url) in
            guard imageURL == url else {
                return
            }
            DispatchQueue.main.async {
                imageView.image = image
                completionHandler(image, url)
                self.callback?(false)
            }
        }
    }
}


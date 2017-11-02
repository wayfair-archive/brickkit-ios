//
//  ImageBrickTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/4/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class FixedImageBrickDataSource: ImageBrickDataSource {
    var imageURLs: [URL]?
    var images: [String : UIImage]?

    init(imageURLs: [URL]?, images: [String: UIImage]?) {
        self.imageURLs = imageURLs
        self.images = images
    }

    func imageForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> UIImage? {
        return images?[imageBrickCell.brick.identifier]
    }

    func imageURLForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> URL? {
        return imageURLs?[imageBrickCell.index]
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
    var dataSource: FixedImageBrickDataSource?
    var image: UIImage!
    var imageURLs: [URL]!

    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: self.classForCoder)
        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        image = UIImage(named: "image0", in: bundle, compatibleWith: nil)!
        imageURLs = [
            URL(fileURLWithPath: bundle.path(forResource: "image0", ofType: "png")!),
            URL(fileURLWithPath: bundle.path(forResource: "banner0", ofType: "jpg")!),
            URL(fileURLWithPath: bundle.path(forResource: "square0", ofType: "jpg")!),
            URL(fileURLWithPath: bundle.path(forResource: "square1", ofType: "jpg")!),
            URL(fileURLWithPath: bundle.path(forResource: "banner1", ofType: "jpg")!),
            URL(fileURLWithPath: bundle.path(forResource: "square1", ofType: "jpg")!),
            URL(fileURLWithPath: bundle.path(forResource: "image0", ofType: "png")!),
            URL(fileURLWithPath: bundle.path(forResource: "banner0", ofType: "jpg")!),
            URL(fileURLWithPath: bundle.path(forResource: "banner1", ofType: "jpg")!),
            URL(fileURLWithPath: bundle.path(forResource: "banner1", ofType: "jpg")!),
            URL(fileURLWithPath: bundle.path(forResource: "square1", ofType: "jpg")!)
        ]
    }

    override func tearDown() {
        super.tearDown()
        BrickCollectionView.imageDownloader = NSURLSessionImageDownloader() // Reset the image downloader back to the default one (if a test had overwritten this)
        brickView = nil
    }

    // Mark: - UIImage
    func testImageBrickDelegate() {

        let expect = expectation(description: "Expect ")
        brickView.registerBrickClass(ImageBrick.self)

        let brick = ImageBrick(dataSource: ImageBrickModel(image: image, contentMode: .scaleAspectFill))
        let brickDelegate = SimpleActionImageBrickDelegate()
        brick.delegate = brickDelegate

        let section = BrickSection(bricks: [brick])

        brickView.setSection(section)
        brickView.layoutSubviews()

        guard let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell else {
            XCTAssert(false, "Expected an ImageBrickCell")
            return
        }
        cell1.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(brickDelegate.imageSet)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUIImageScaleAspectFill() {
        let expect = expectation(description: "UIImageView should be .aspectFill")

        let section = BrickSection(bricks: [
            ImageBrick(dataSource: ImageBrickModel(image: image, contentMode: .scaleAspectFill)),
            ])

        brickView.setSection(section)
        brickView.layoutSubviews()

        guard let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell else {
            XCTAssert(false, "Expected an ImageBrickCell")
            return
        }
        cell1.layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(cell1.frame.height, cell1.expectedCellHeight, accuracy: 0.5)
            XCTAssertEqual(cell1.imageView.contentMode, .scaleAspectFill)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUIImageScaleAspectFit() {
        let expect = expectation(description: "UIImageView should be .aspectFit")

        let section = BrickSection(bricks: [
            ImageBrick(dataSource: ImageBrickModel(image: image, contentMode: .scaleAspectFit)),
            ])

        brickView.setSection(section)
        brickView.layoutSubviews()

        guard let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell else {
            XCTAssert(false, "Expected an ImageBrickCell")
            return
        }
        cell1.layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(cell1.frame.height, cell1.expectedCellHeight, accuracy: 0.5)
            XCTAssertEqual(cell1.imageView.contentMode, .scaleAspectFit)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUIImageScaleToFill() {
        let expect = expectation(description: "setting model sets .scaleAspectFill")

        let section = BrickSection(bricks: [
            ImageBrick(dataSource: ImageBrickModel(image: image, contentMode: .scaleToFill)),
            ])

        brickView.setSection(section)
        brickView.layoutSubviews()

        guard let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell else {
            XCTAssert(false, "Expected an ImageBrickCell")
            return
        }
        cell1.layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(cell1.frame.height, cell1.expectedCellHeight, accuracy: 0.5)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUIImageFixedSize() {

        let section = BrickSection(bricks: [
            ImageBrick(width: .ratio(ratio: 1/4), height: .ratio(ratio: 1), dataSource: ImageBrickModel(image: image, contentMode: .scaleAspectFill)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1?.frame, CGRect(x: 0, y: 0, width: 80, height: 80))
    }

    func testShouldBeNilIfDataSourceReturnsNil() {
        let section = BrickSection(bricks: [
            ImageBrick("Brick1", height: .fixed(size: 480), dataSource: FixedImageBrickDataSource(imageURLs: nil, images: ["Brick1": image])),
            ImageBrick("Brick2", height: .fixed(size: 480), dataSource: FixedImageBrickDataSource(imageURLs: nil, images: [:])),
            ])
        section.repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 5])
        brickView.setSection(section)
        brickView.layoutSubviews()

        guard let cell = self.brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell else {
            XCTAssert(false, "Expected an ImageBrickCell")
            return
        }

        cell.layoutIfNeeded()
        XCTAssertNil(cell.imageView.image)
    }

    func testShouldNotBeNilIfDataSourceSetWithImage() {
        let expect = expectation(description: "Should not be nil if DataSource set with image")
        self.dataSource = FixedImageBrickDataSource(imageURLs: nil, images: ["Brick1": image])
        brickView.registerBrickClass(ImageBrick.self)

        let brick = ImageBrick("Brick1", height: .fixed(size: 200), dataSource: self.dataSource!)
        let brickDelegate = SimpleActionImageBrickDelegate()
        brick.delegate = brickDelegate

        let section = BrickSection(bricks: [brick])
        section.repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 5])
        brickView.setSection(section)
        brickView.layoutSubviews()

        guard let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell else {
            XCTAssert(false, "Expected an ImageBrickCell")
            return
        }
        cell.layoutIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertNotNil(cell.imageView.image)
            XCTAssertTrue(brickDelegate.imageSet)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testShouldNotBeNilIfDataSourceSetWithURL() {
        let expectation: XCTestExpectation = self.expectation(description: "testURLSetOnOtherQueue - Wait for image to download")

        self.dataSource = FixedImageBrickDataSource(imageURLs: imageURLs, images: nil)
        brickView.registerBrickClass(ImageBrick.self)

        let brick = ImageBrick("Brick1", height: .fixed(size: 200), dataSource: self.dataSource!)
        let brickDelegate = SimpleActionImageBrickDelegate()
        brick.delegate = brickDelegate

        var cell: ImageBrickCell?

        BrickCollectionView.imageDownloader = FixedNSURLSessionImageDownloader { (success) in
            DispatchQueue.main.async {
                XCTAssertNotNil(cell?.imageView.image)
                expectation.fulfill()
            }
        }

        let section = BrickSection(bricks: [brick])
        section.repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 5])
        brickView.setSection(section)
        brickView.layoutSubviews()

        cell = self.brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell
        XCTAssertNotNil(cell)
        cell!.layoutIfNeeded()

        XCTAssertNil(cell?.imageView.image)
        XCTAssertFalse(brickDelegate.imageSet)

        self.waitForExpectations(timeout: 2, handler: nil)
    }

    // Mark: - UIImage

    func testURLImageScaleAspectFill() {
        let expectation: XCTestExpectation = self.expectation(description: "testURLImageScaleAspectFill - Wait for image to download")
        BrickCollectionView.imageDownloader = FixedNSURLSessionImageDownloader { (success) in
            XCTAssertFalse(Thread.isMainThread)
        }

        brickView.registerBrickClass(ImageBrick.self)

        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURLs[0], contentMode: .scaleAspectFill)),
            ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        guard let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell else {
            XCTAssertTrue(false, "Expected cell1 to not be nil")
            return
        }

        XCTAssertEqual(cell1.frame, CGRect(x: 0, y: 0, width: 320, height: 50))
        XCTAssertEqual(cell1.imageView.frame, CGRect(x: 0, y: 0, width: 320, height: 50))

        self.brickView.layoutIfNeeded()
        // Allows a layout pass to fetch the image
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(cell1.frame.height, cell1.expectedCellHeight, accuracy: 0.5)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
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
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURLs[0], contentMode: .scaleAspectFill)),
        ])
        brickView.setSection(section)
        brickView.layoutSubviews()

        var expectationInvalidate: XCTestExpectation? = self.expectation(description: "testURLSetOnOtherQueue - Wait for invalidateBricks")
        brickView.invalidateBricks(true) { (completed: Bool) in
            expectationInvalidate?.fulfill()
            expectationInvalidate = nil
        }

        wait(for: [expectation!, expectationInvalidate!], timeout: 2.0)
    }

    func testURLSetOnOtherQueue() {
        var expectation: XCTestExpectation? = self.expectation(description: "testURLSetOnOtherQueue - Wait for image to download")
        let fixedImageDownloader = FixedNSURLSessionImageDownloaderWithCustomSetter { (success) in
            XCTAssertEqual(OperationQueue.main.operationCount, 0)
            expectation?.fulfill()
            expectation = nil
        }

        BrickCollectionView.imageDownloader = fixedImageDownloader

        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURLs[0], contentMode: .scaleAspectFill)),
            ])
        brickView.setupSectionAndLayout(section)
        let expectationInvalidate: XCTestExpectation = self.expectation(description: "testURLSetOnOtherQueue - Wait InvalidateBricks to complete")
        brickView.invalidateBricks(true) { (completed: Bool) in
            expectationInvalidate.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testURLImageScaleResetSection() {
        var expectation: XCTestExpectation? = self.expectation(description: "testURLImageScaleResetSection - Wait for image to download for the first time")

        let fixedImageDownloader = FixedNSURLSessionImageDownloader { (success) in
            expectation?.fulfill()
            expectation = nil

        }

        BrickCollectionView.imageDownloader = fixedImageDownloader

        let delegate = FixedDelegate()
        brickView.layout.delegate = delegate

        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURLs[0], contentMode: .scaleAspectFill)),
            ])
        brickView.setSection(section)
        brickView.layoutIfNeeded()

        guard let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell else {
            XCTAssertTrue(false, "Expected a cell at indexPath [1, 0]")
            return
        }

        XCTAssertEqual(cell1.frame, CGRect(x: 0, y: 0, width: 320, height: 50))
        XCTAssertEqual(cell1.imageView.frame, CGRect(x: 0, y: 0, width: 320, height: 50))

        brickView.setSection(section)
        brickView.layoutIfNeeded()

        guard let cell2 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell else {
            XCTAssertTrue(false, "Expected a cell at indexPath [1, 0]")
            return
        }

        var expectationDidUpdate: XCTestExpectation? = self.expectation(description: "testURLSetOnOtherQueue - Wait for image to download")
        delegate.didUpdateHandler = {
            XCTAssertTrue(delegate.didUpdateCalled)

            XCTAssertEqual(cell1.frame, CGRect(x: 0, y: 0, width: 320, height: 50.0))
            XCTAssertEqual(cell1.imageView.frame, CGRect(x: 0, y: 0, width: 320, height: 50.0))

            self.brickView.layoutIfNeeded()
            // Allows a layout pass to fetch the image
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                XCTAssertEqual(cell2.frame.height, cell2.expectedCellHeight, accuracy: 0.5)
                expectationDidUpdate?.fulfill()
                expectationDidUpdate = nil
            }
        }

        wait(for: [expectation!, expectationDidUpdate!], timeout: 2)
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

        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: ImageURLBrickModel(url: imageURLs![0], contentMode: .scaleAspectFill)),
            ])

        brickView.setSection(section)
        brickView.layoutSubviews()

        guard let cell1 = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell else {
            XCTAssert(false, "Expected an ImageBrickCell")
            return
        }
        cell1.imageView.image = self.image
        cell1.layoutIfNeeded()

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertFalse(cell1.imageView.image == nil)
        cell1.prepareForReuse()
        XCTAssertTrue(cell1.imageView.image == nil)
    }

    func testThatSetsImageNilWhenDataSourceReturnsNil() {
        let dataSource = FixedImageBrickDataSource(imageURLs: nil, images: nil)
        let section = BrickSection(bricks: [
            ImageBrick("imageBrick", dataSource: dataSource)
        ])

        brickView.setSection(section)
        brickView.layoutSubviews()

        guard let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell else {
            XCTAssert(false, "Expected an ImageBrickCell")
            return
        }

        cell.framesDidLayout()
        XCTAssertNil(cell.imageView.image)
    }

    func testThatFrameDidLayoutCallsResizeIfImageHasntChanged() {
        let expect: XCTestExpectation = self.expectation(description: "testThatFrameDidLayoutCallsResizeIfSameImage - Wait for frameDidLayout to be called")

        let dataSource: FixedImageBrickDataSource = FixedImageBrickDataSource(imageURLs: self.imageURLs, images: nil)
        let repeatCount = FixedRepeatCountDataSource(repeatCountHash: ["imageBrick" : self.imageURLs.count])
        let section = BrickSection(bricks: [ImageBrick("imageBrick", dataSource: dataSource)])
        section.repeatCountDataSource = repeatCount

        brickView.setSection(section)
        brickView.layoutIfNeeded()

        guard let cell = brickView.cellForItem(at: IndexPath(item: 0, section: 1)) as? ImageBrickCell else {
            XCTAssert(false, "Expected an ImageBrickCell")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotNil(cell.imageView.image)
            let image = cell.imageView.image
            cell.updateContent()
            cell.layoutIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                XCTAssertEqual(image, cell.imageView.image)
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func setupFixedRepeatCountDataSource() -> (() -> Void)? {
        return {
            let dataSource: FixedImageBrickDataSource = FixedImageBrickDataSource(imageURLs: self.imageURLs, images: nil)
            let repeatCount = FixedRepeatCountDataSource(repeatCountHash: ["imageBrick" : self.imageURLs.count])
            let brickSection = BrickSection(bricks: [ImageBrick("imageBrick", dataSource: dataSource)])
            brickSection.repeatCountDataSource = repeatCount
            self.brickView.setSection(brickSection)
            self.brickView.layoutIfNeeded()
        }
    }

    func assertCellHeightCorrect(cells: [ImageBrickCell]) {
        for cell: ImageBrickCell in cells {
            XCTAssertEqual(cell.bounds.size.height, cell.expectedCellHeight, accuracy:  0.5, "Cell wasn't resized correctly")
        }
    }
}

extension ImageBrickCell {

    fileprivate var expectedCellHeight: CGFloat {
        guard let image = self.imageView.image else {
            return 0.0
        }
        return (image.size.height / max(image.size.width, 0.01)) * self.bounds.size.width
    }
}

class FixedNSURLSessionImageDownloader: NSURLSessionImageDownloader {
    var callback: ((_ success: Bool) -> Void)?
    var downloadDelay: Double = 0.1

    init(callback: @escaping (_ success: Bool) -> Void) {
        self.callback = callback
    }

    override func downloadImage(with imageURL: URL, onCompletion completionHandler: @escaping ((_ image: UIImage, _ url: URL) -> Void)) {
        super.downloadImage(with: imageURL) { (image: UIImage, url: URL) in
            DispatchQueue.global().asyncAfter(deadline: .now() + self.downloadDelay) {
                completionHandler(image, url)
                self.callback?(false)
            }
        }
    }
}

class FixedNSURLSessionImageDownloaderWithCustomSetter: NSURLSessionImageDownloader {
    var callback: ((_ success: Bool) -> Void)?
    var downloadDelay: Double = 0.1

    init(callback: @escaping (_ success: Bool) -> Void) {
        self.callback = callback
    }

    override func downloadImage(with imageURL: URL, onCompletion completionHandler: @escaping ((UIImage, URL) -> Void)) {
        super.downloadImage(with: imageURL) { (image: UIImage, url: URL) in
            DispatchQueue.main.asyncAfter(deadline: .now() + self.downloadDelay) {
                completionHandler(image, url)
                self.callback?(false)
            }
        }
    }

    override func downloadImageAndSet(on imageView: UIImageView, with imageURL: URL, onCompletion completionHandler: @escaping ((_ image: UIImage, _ url: URL) -> Void)) {
        self.downloadImage(with: imageURL) { (image, url) in
            guard imageURL == url else {
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + self.downloadDelay) {
                imageView.image = image
                completionHandler(image, url)
                self.callback?(false)
            }
        }
    }
}


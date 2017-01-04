//
//  VideoBrickTests.swift
//  BrickKit
//
//  Created by Will Spurgeon on 10/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class VideoBrickTests: XCTestCase {

    private let VideoBrickIdentifier = "videoBrickIdentifier"

    var brickCollectionView: BrickCollectionView!
    var videoBrick: VideoBrick!

    override func setUp() {
        super.setUp()

        brickCollectionView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    func setupSection(videoBrick: VideoBrick) -> VideoBrickCell? {
        brickCollectionView.registerBrickClass(VideoBrick.self)
        self.videoBrick = videoBrick
        let section = BrickSection(bricks: [
            videoBrick
            ])
        brickCollectionView.setSection(section)
        brickCollectionView.layoutSubviews()

        return videoCell
    }

    var videoCell: VideoBrickCell? {
        let cell = brickCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? VideoBrickCell
        cell?.layoutIfNeeded()
        return cell
    }

    func setupVideoBrick(configureButtonBlock: ConfigureButtonBlock? = nil) -> VideoBrickCell? {
        return setupSection(VideoBrick(VideoBrickIdentifier, dataSource: VideoBrickCellModel(videoURL: NSURL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!)))
    }

    func testVideoBrickInit() {
        let model = videoBrick.dataSource as! VideoBrickCellModel

        XCTAssertEqual(videoBrick.identifier, VideoBrickIdentifier)

        XCTAssertEqual(model.videoViewURL, NSURL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!)
        XCTAssertEqual(model.fallbackImageURL, nil)
        XCTAssertEqual(model.placeholderImageURL, nil)
        XCTAssertEqual(model.redirectURL, nil)
        XCTAssertEqual(model.shouldAutoplay, true)
        XCTAssertEqual(model.isBackgroundVideo, false)
        XCTAssertEqual(model.shouldLoop, false)
        XCTAssertEqual(model.shouldDisplayControls, false)
    }
}




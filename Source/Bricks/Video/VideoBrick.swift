//
//  VideoBrick.swift
//  WayfairApp
//
//  Created by Victor Wu on 8/2/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

public typealias ConfigureVideoBlock = ((cell: VideoBrickCell) -> Void)

public class VideoBrick: Brick {
    let dataSource: VideoBrickCellDataSource
    let delegate: VideoBrickCellDelegate?

    public init(_ identifier: String, width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = UIColor.whiteColor(), backgroundView: UIView? = nil, dataSource: VideoBrickCellDataSource, delegate: VideoBrickCellDelegate? = nil) {
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(identifier, width: width, height: height, backgroundColor:backgroundColor, backgroundView:backgroundView)
    }
}

public protocol VideoBrickCellDelegate {
    func routeTo(URL: NSURL, eventData: [String: String])
    func videoDidAutoplay(eventData: [String: String])
    func videoDidPlay(eventData: [String: String])
    func videoDidPause(eventData: [String: String])
    func videoDidFullscreen(eventData: [String: String])
    func videoDidFailLoad(eventData: [String: String])
}

public extension VideoBrickCellDelegate {
    func routeTo(URL: NSURL, eventData: [String: String]) {}
    func videoDidAutoplay(eventData: [String: String]) {}
    func videoDidPlay(eventData: [String: String]) {}
    func videoDidPause(eventData: [String: String]) {}
    func videoDidFullscreen(eventData: [String: String]) {}
    func videoDidFailLoad(eventData: [String: String]) {}
}

public protocol VideoBrickCellDataSource {
    func configureVideoBrick(cell: VideoBrickCell)
}

public class VideoBrickCellModel: VideoBrickCellDataSource, VideoBrickCellDelegate {
    public var videoViewURL: NSURL
    public var placeholderImageURL: NSURL?
    public var fallbackImageURL: NSURL?
    public var redirectURL: NSURL?
    public var isBackgroundVideo: Bool
    public var isMuted: Bool
    public var shouldLoop: Bool
    public var shouldAutoplay: Bool
    public var shouldDisplayControls: Bool

    public typealias VideoBrickCellDelegateBlock = ((eventData: [String: String]) -> Void)

    public var routeTo: ((URL: NSURL, eventData: [String: String]) -> Void)?
    public var videoDidAutoplay: VideoBrickCellDelegateBlock?
    public var videoDidPlay: VideoBrickCellDelegateBlock?
    public var videoDidPause: VideoBrickCellDelegateBlock?
    public var videoDidFullscreen: VideoBrickCellDelegateBlock?
    public var videoDidFailLoad: VideoBrickCellDelegateBlock?

    public var configureVideoBlock: ConfigureVideoBlock?

    public init(videoURL: NSURL, placeholderImageURL: NSURL? = nil, fallbackImageURL: NSURL? = nil, redirectURL: NSURL? = nil, isBackgroundVideo: Bool = false, isMuted: Bool = true, shouldLoop: Bool = false, shouldAutoplay: Bool = false, shouldDisplayControls: Bool = false, configureVideoBlock: ConfigureVideoBlock? = nil, routeToHandler: ((URL: NSURL, eventData: [String: String]) -> Void)? = nil, didAutoplayHandler: VideoBrickCellDelegateBlock? = nil, didPlayHandler: VideoBrickCellDelegateBlock? = nil, didPauseHandler: VideoBrickCellDelegateBlock? = nil, didFullscreenHandler: VideoBrickCellDelegateBlock? = nil, didFailLoadHandler: VideoBrickCellDelegateBlock? = nil) {
        self.videoViewURL = videoURL
        self.placeholderImageURL = placeholderImageURL
        self.fallbackImageURL = fallbackImageURL
        self.redirectURL = redirectURL
        self.isBackgroundVideo = isBackgroundVideo
        self.isMuted = isMuted
        self.shouldLoop = shouldLoop
        self.shouldAutoplay = shouldAutoplay
        self.shouldDisplayControls = shouldDisplayControls

        self.routeTo = routeToHandler
        self.videoDidAutoplay = didAutoplayHandler
        self.videoDidPlay = didPlayHandler
        self.videoDidPause = didPauseHandler
        self.videoDidFullscreen = didFullscreenHandler
        self.videoDidFailLoad = didFailLoadHandler
    }

    public func configureVideoBrick(cell: VideoBrickCell) {
        cell.videoView.backgroundColor = cell.backgroundColor

        cell.videoView.placeholderImageURL = placeholderImageURL
        cell.videoView.fallbackImageURL = fallbackImageURL
        cell.videoView.redirectURL = redirectURL
        cell.videoView.isBackgroundVideo = isBackgroundVideo
        cell.videoView.isMuted = isMuted
        cell.videoView.shouldLoop = shouldLoop
        cell.videoView.shouldAutoplay = shouldAutoplay
        cell.videoView.shouldDisplayControls = shouldDisplayControls

        cell.videoView.videoURL = videoViewURL
        configureVideoBlock?(cell: cell)
    }

    public func routeTo(URL: NSURL, eventData: [String : String]) {
        self.routeTo?(URL: URL, eventData: eventData)
    }

    public func videoDidAutoplay(eventData: [String : String]) {
        self.videoDidAutoplay?(eventData: eventData)
    }

    public func videoDidPlay(eventData: [String : String]) {
        self.videoDidPlay?(eventData: eventData)
    }

    public func videoDidPause(eventData: [String : String]) {
        self.videoDidPause?(eventData: eventData)
    }

    public func videoDidFullscreen(eventData: [String : String]) {
        self.videoDidFullscreen?(eventData: eventData)
    }

    public func videoDidFailLoad(eventData: [String : String]) {
        self.videoDidFailLoad?(eventData: eventData)
    }

}

public class VideoBrickCell: BrickCell, Bricklike {
    public typealias BrickType = VideoBrick
    @IBOutlet weak var videoView: VideoView!

    override public func updateContent() {
        super.updateContent()

        videoView.delegate = brick.delegate
        brick.dataSource.configureVideoBrick(self)
    }
}

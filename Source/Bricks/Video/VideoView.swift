//
//  VideoView.swift
//  VideoApp
//
//  Created by Victor Wu on 8/03/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//
//  Unable to simultaneously satisfy constraints warnings. It seems like the issue is with the autolayout of playback controls within AVPlayerViewController.
//  This is a Swift bug.
//
//  It is important to set the videoURL last.

import UIKit
import AVFoundation
import AVKit

public enum VideoViewGravity {
    case Resize
    case ResizeAspectFill
    case ResizeAspect

    public var videoGravityString: String {
        switch self {
        case .Resize: return AVLayerVideoGravityResize
        case .ResizeAspectFill: return AVLayerVideoGravityResizeAspectFill
        case .ResizeAspect: return AVLayerVideoGravityResizeAspect
        }
    }
}

public class AVPlayerWithTracking: AVPlayerViewController {
    var redirectURL: NSURL?
    var videoDelegate: VideoBrickCellDelegate?
    var trackingData: [String: String] = [:]

    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //For players with navigation controls, route them if there is a redirectURL.
        if let redirectURL = redirectURL {
            videoDelegate?.routeTo(redirectURL, eventData: trackingData)
        }

        super.touchesBegan(touches, withEvent: event)
    }
}

public class VideoView: UIView {
    var avPlayerItem: AVPlayerItem?
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var avPlayerWithNavigation: AVPlayerWithTracking?
    var placeholderImageView: UIImageView?
    var fallbackImageView: UIImageView?
    public var playButtonView: UIView?

    public var delegate: VideoBrickCellDelegate?

    var playOrPauseTapGesture: UITapGestureRecognizer?
    var redirectTapGesture: UITapGestureRecognizer?

    public var videoGravity: VideoViewGravity = .ResizeAspectFill {
        didSet {
            avPlayerLayer?.videoGravity = videoGravity.videoGravityString
        }
    }

    public var videoURL: NSURL? {
        didSet {
            //Don't reload cells when scrolling off screen.
            if (oldValue == videoURL) {
                return
            }

            updateVideoView()
        }
    }

    public var placeholderImageURL: NSURL? {
        didSet {
            if (oldValue == placeholderImageURL) {
                return
            }

            addPlaceholderImage()
        }
    }

    public var redirectURL: NSURL?
    public var fallbackImageURL: NSURL?

    //Not sure if we can support isBackgroundVideo in iOS with how cells are drawn.  Supposed to allow for playing audio when cell is not on screen.
    public var isBackgroundVideo: Bool = false
    public var isMuted: Bool = true
    public var shouldAutoplay: Bool = false
    public var shouldLoop: Bool = false
    public var shouldDisplayControls: Bool = false

    //Current video state
    public var trackingData: [String: String] = [:]
    public var currentTime: CMTime = kCMTimeZero
    public var isPlaying: Bool = false
    public var isFullscreen: Bool = false
    public var isInitialPlay: Bool = true

    func addPlaceholderImage() {
        self.placeholderImageView?.removeFromSuperview()

        self.placeholderImageView = UIImageView(frame: CGRectZero)
        self.placeholderImageView?.contentMode = UIViewContentMode.ScaleAspectFill

        self.addSubview(placeholderImageView!)
        self.playButtonView?.hidden = false
    }

    func addFallbackImage() {
        guard let fallbackImageURL = fallbackImageURL else {
            return
        }

        self.fallbackImageView?.removeFromSuperview()

        self.fallbackImageView = UIImageView(frame: CGRectZero)
        self.fallbackImageView?.contentMode = UIViewContentMode.ScaleAspectFill

        self.addSubview(fallbackImageView!)
    }

    //This is necessary to prevent old data from showing up when dequeuing reuseable cells.
    func resetView() {
        self.removeObservers()
        self.avPlayerWithNavigation?.view.removeFromSuperview()
        self.avPlayerLayer?.removeFromSuperlayer()
        self.avPlayerItem = nil
        self.avPlayer = nil
        self.avPlayerLayer = nil
        self.avPlayerWithNavigation = nil
        self.redirectTapGesture = nil
        self.playOrPauseTapGesture = nil
        self.isPlaying = false
        self.isFullscreen = false
        self.isInitialPlay = true
    }

    public func updateVideoView() {
        self.resetView()

        guard let videoURL = videoURL else {
            return
        }

        let videoUrlString: String = videoURL.absoluteString ?? ""
        let redirectUrlString: String = redirectURL?.absoluteString ?? ""
        let shouldAutoplayString: String = NSNumber(bool: shouldAutoplay).stringValue
        let isMutedString: String = NSNumber(bool: isMuted).stringValue
        let shouldLoopString: String = NSNumber(bool: shouldLoop).stringValue
        let shouldDisplayControlsString: String = NSNumber(bool: shouldDisplayControls).stringValue
        let isBackgroundVideoString: String = NSNumber(bool: isBackgroundVideo).stringValue

        trackingData = ["videoURL": videoUrlString,
                        "redirectURL": redirectUrlString,
                        "autoplay" : shouldAutoplayString,
                        "muted" : isMutedString,
                        "loop" : shouldLoopString,
                        "displayControls": shouldDisplayControlsString,
                        "backgroundVideo": isBackgroundVideoString]

        let checkRequest: NSURLRequest = NSURLRequest(URL: videoURL)
        let isValidURL: Bool = NSURLConnection.canHandleRequest(checkRequest)

        //A fallback image is an image that shows up if the video can not be loaded.
        if (!isValidURL) {
            self.addFallbackImage()
            self.delegate?.videoDidFailLoad(trackingData)
            return
        }

        self.avPlayerItem = AVPlayerItem(URL: videoURL)
        self.avPlayer = AVPlayer(playerItem: avPlayerItem!)

        //shouldDisplayControls = video, !shouldDisplayControls = gif
        if (shouldDisplayControls) {
            createVideoWithNavigation()
        } else {
            createVideoWithoutNavigation()
        }

        //If it has a placeholder image, then the initial click will be to show the video.
        self.createPlayOrPauseTapGesture()

        self.avPlayer?.seekToTime(kCMTimeZero)
        self.avPlayer?.actionAtItemEnd = .None

        self.avPlayer?.volume = 1.0
        self.avPlayer?.muted = isMuted

        if (shouldAutoplay) {
            self.isPlaying = true
            self.replacePlaceholderImageWithVideo()
            self.avPlayer?.play()
            self.delegate?.videoDidAutoplay(trackingData)
        }

        self.avPlayer?.addPeriodicTimeObserverForInterval(CMTime(seconds: 1, preferredTimescale: 1000), queue: nil, usingBlock: { [weak self] (time) in
            self?.updateCurrentTime(time)
            })

        self.addObserversForTracking()
    }

    func addObserversForTracking() {
        self.avPlayer?.addObserver(self, forKeyPath: "rate", options: .New, context: nil)
        self.avPlayerWithNavigation?.contentOverlayView?.addObserver(self, forKeyPath: "bounds", options: .New, context: nil)
    }

    //Make sure to remove the observers whenever you deallocate the player.
    func removeObservers() {
        self.avPlayer?.removeObserver(self, forKeyPath: "rate")
        self.avPlayerWithNavigation?.contentOverlayView?.removeObserver(self, forKeyPath: "bounds")
    }

    deinit {
        removeObservers()
    }

    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let keyPath = keyPath else {
            return
        }

        //These checks are necessary to prevent multiple tracking calls when going from full screen to regular and vice versa.
        switch keyPath {
        case "rate":
            guard let newRate: NSValue = change?[NSKeyValueChangeNewKey] as? Float else {
                return
            }
            if newRate == 0.0 && isPlaying {
                self.delegate?.videoDidPause(trackingData)
                self.isPlaying = false
            } else if newRate == 1.0 && !isPlaying {
                self.delegate?.videoDidPlay(trackingData)
                self.isPlaying = true
            }
        case "bounds":
            if let newBounds: NSValue = change?[NSKeyValueChangeNewKey] as? NSValue, let avPlayerRect: CGRect = newBounds.CGRectValue() {
                if avPlayerRect.size == UIScreen.mainScreen().bounds.size {
                    if !isFullscreen {
                        self.delegate?.videoDidFullscreen(trackingData)
                        isFullscreen = true
                    }
                } else {
                    isFullscreen = false
                }
            }
        default:
            return
        }
    }

    //Warning: we are not adding this controller to the view controller hierarchy.
    func createVideoWithNavigation() {
        avPlayerWithNavigation = AVPlayerWithTracking()
        avPlayerWithNavigation?.player = self.avPlayer

        if (self.traitCollection.userInterfaceIdiom == .Pad) {
            avPlayerWithNavigation?.videoGravity = VideoViewGravity.ResizeAspect.videoGravityString
        } else {
            avPlayerWithNavigation?.videoGravity = self.videoGravity.videoGravityString
        }

        avPlayerWithNavigation?.view.frame = self.bounds
        avPlayerWithNavigation?.redirectURL = self.redirectURL
        avPlayerWithNavigation?.videoDelegate = self.delegate
        avPlayerWithNavigation?.trackingData = self.trackingData

        //If there is no placeholder image, just go directly to video.
        if let avPlayerWithNavigationView = avPlayerWithNavigation?.view where placeholderImageURL == nil {
            self.addSubview(avPlayerWithNavigationView)
        }
    }

    func createVideoWithoutNavigation() {
        self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)

        if (self.traitCollection.userInterfaceIdiom == .Pad) {
            self.avPlayerLayer?.videoGravity = VideoViewGravity.ResizeAspect.videoGravityString
        } else {
            self.avPlayerLayer?.videoGravity = self.videoGravity.videoGravityString
        }

        self.avPlayerLayer?.frame = self.bounds

        //If there is no placeholder image, just go directly to video.
        if let avPlayerLayer = avPlayerLayer where placeholderImageURL == nil {
            layer.addSublayer(avPlayerLayer)
        }
    }

    func createPlayOrPauseTapGesture() {
        if (playOrPauseTapGesture == nil) {
            playOrPauseTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.playOrPause))
            playOrPauseTapGesture?.numberOfTapsRequired = 1

            self.addGestureRecognizer(playOrPauseTapGesture!)
        }
    }

    func createURLRoutingTapGestureFor(view: UIView?) -> Bool {
        //Returns true if a tap gesture was made/is in existence, returns false if not.
        guard let view = view else {
            return false
        }

        if redirectURL != nil && redirectTapGesture == nil {
            redirectTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.routeURL))
            redirectTapGesture?.numberOfTapsRequired = 1
            view.addGestureRecognizer(redirectTapGesture!)

            return true
        }

        if (redirectTapGesture != nil) {
            return true
        }

        return false
    }

    func routeURL() {
        guard let delegate = delegate, let redirectURL = redirectURL else {
            return
        }
        
        delegate.routeTo(redirectURL, eventData: trackingData)
    }

    func replacePlaceholderImageWithVideo() -> Bool {
        //Returns true if successfully replaced placeholder image, returns false if not.
        guard let playOrPauseTapGesture = playOrPauseTapGesture else {
            return false
        }

        if (isInitialPlay && placeholderImageURL != nil) {
            if let avPlayerLayer = self.avPlayerLayer {
                layer.addSublayer(avPlayerLayer)
            } else if let avPlayerWithNavigationView = avPlayerWithNavigation?.view {
                self.addSubview(avPlayerWithNavigationView)
                //A player with navigation controls does not need this tap gesture.
                self.removeGestureRecognizer(playOrPauseTapGesture)
            }

            //This flag states that the video has been played once is loaded.
            isInitialPlay = false
            self.playButtonView?.hidden = true
            return true
        }

        return false
    }

    func playOrPause() {
        guard let playOrPauseTapGesture = playOrPauseTapGesture else {
            return
        }

        var isPlaying: Bool = ((self.avPlayer?.rate != 0) && (self.avPlayer?.error == nil))

        //If there is a placeholder, this will do the appropriate logic to show the video or gif.
        if !replacePlaceholderImageWithVideo() {
            if avPlayerWithNavigation != nil {
                self.removeGestureRecognizer(playOrPauseTapGesture)
                return
            } else if avPlayerLayer != nil && self.createURLRoutingTapGestureFor(self) {
                //If this is a gif with a redirect URL, route them to that URL instead of pausing/playing.
                self.removeGestureRecognizer(playOrPauseTapGesture)
                return
            }
        }

        //If a video, without controls, without looping, reaches the end, allow them to play it from the start.
        let playerItemDuration = avPlayerItem?.duration.convertScale(1, method: .Default)
        if playerItemDuration <= self.currentTime {
            avPlayerItem?.seekToTime(kCMTimeZero)
            isPlaying = false
        }

        if(isPlaying) {
            self.avPlayer?.pause()
        } else {
            self.avPlayer?.play()
        }
    }

    //Keep track of the current time and loop if needed.
    func updateCurrentTime(time: CMTime) {
        guard let playerItem = avPlayerItem else {
            return
        }

        let playerItemDuration = playerItem.duration.convertScale(1, method: .Default)
        self.currentTime = time.convertScale(1, method: .Default)
        if playerItemDuration <= self.currentTime && shouldLoop {
            playerItem.seekToTime(kCMTimeZero)
        }
    }
    
    //Ensures that all image views and player views are the size of video view.
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        self.avPlayerLayer?.frame = self.bounds
        self.avPlayerWithNavigation?.view.frame = self.bounds
        self.fallbackImageView?.frame = self.bounds
        self.placeholderImageView?.frame = self.bounds
    }
}

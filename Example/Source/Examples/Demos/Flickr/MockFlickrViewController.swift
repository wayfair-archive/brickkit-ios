//
//  MockFlickerViewController.swift
//  BrickKit-Example
//
//  Created by Justin Anderson on 10/13/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

private let StickySection = "StickySection"

class MockFlickrViewController: BrickApp.BaseBrickController {

    override class var title: String {
        return "Flickr"
    }
    
    override class var subTitle: String {
        return "Instagram Style Flickr Scoller"
    }


    var recentImages: FlickrRecentImagesResponse?

    var defaultImageDownloader: ImageDownloader?
    
    deinit {
        BrickCollectionView.imageDownloader = defaultImageDownloader!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.defaultImageDownloader = BrickCollectionView.imageDownloader
        BrickCollectionView.imageDownloader = CachingImageDownloader()
        
        let communicationBase = CommunicationBase(serviceEndPoint: NSURL(string: "https://api.flickr.com/")!)
        
        let request = FlickrRecentImagesRequest()
        request.useURLPrams = true
        
        communicationBase.jsonRequest(request: request, responseType: FlickrRecentImagesResponse.self, successHandler: { [weak self] (response) in
            self?.recentImages = response
            self?.setupBricks()
            }) { (error) in
                print(error!)
        }
    }
}

extension MockFlickrViewController: BrickRegistrationDataSource {
    
    func registerBricks() {
         self.brickCollectionView.registerBrickClass(LabelBrick.self)
         self.brickCollectionView.registerBrickClass(ImageBrick.self)
         self.brickCollectionView.registerBrickClass(CollectionBrick.self)
    }
    
    func setupBricks() {
        let configureCell: (_ cell: LabelBrickCell) -> Void = { cell in
            cell.configure()
        }
        var sections = [BrickSection]()
        recentImages?.photos.enumerated().forEach {
            
            let section = BrickSection(bricks: [
                BrickSection(StickySection, backgroundColor: .brickGray5, bricks: [
                    LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray2, text: $0.element.title, configureCellBlock: configureCell)
                    ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)),
                ImageBrick("\($0.offset)", width: .auto(estimate: .ratio(ratio: 1)), height: .auto(estimate: .fixed(size: 200)), backgroundColor: UIColor.white, backgroundView: nil, dataSource: self)
                ])
            sections.append(section)
        }
        
        let section = BrickSection(bricks: sections)
        
        self.brickCollectionView.layout.behaviors.insert(StickyLayoutBehavior(dataSource: self))
        self.brickCollectionView.setSection(section)
    }
}

extension MockFlickrViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(_ stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        #if os(tvOS)
        return false
            #else
        return identifier == StickySection
        #endif
    }
}

extension MockFlickrViewController: ImageBrickDataSource {
    func imageURLForImageBrickCell(imageBrickCell: ImageBrickCell) -> NSURL? {
        let index = Int(imageBrickCell.brick.identifier) ?? 0
        guard let photo = recentImages?.photos[index] else {
            return nil
        }
        
        return NSURL(string: photo.imageUrl) ?? nil
    }
}


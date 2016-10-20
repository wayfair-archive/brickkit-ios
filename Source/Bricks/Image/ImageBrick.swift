//
//  ImageBrick.swift
//  BrickKit
//
//  Created by Justin Shiiba on 6/3/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

// MARK: - Brick

public class ImageBrick: Brick {
    public let dataSource: ImageBrickDataSource

    public init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, dataSource: ImageBrickDataSource) {
        self.dataSource = dataSource
        super.init(identifier, width: width, height: height, backgroundColor:backgroundColor, backgroundView:backgroundView)
    }
}

// MARK: - DataSource

/// An object that adopts the `ImageBrickDataSource` protocol is responsible for providing the data required by a `ImageBrick`.
public protocol ImageBrickDataSource {
    func imageURLForImageBrickCell(imageBrickCell: ImageBrickCell) -> NSURL?
    func imageForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIImage?
    func contentModeForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIViewContentMode
}

extension ImageBrickDataSource {

    public func imageURLForImageBrickCell(imageBrickCell: ImageBrickCell) -> NSURL? {
        return nil
    }

    public func imageForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIImage? {
        return nil
    }

    public func contentModeForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return .ScaleToFill
    }
    
}

//MARK: - Models

public class ImageBrickModel: ImageBrickDataSource {
    var image: UIImage?
    var contentMode: UIViewContentMode

    public init(image: UIImage, contentMode: UIViewContentMode) {
        self.image = image
        self.contentMode = contentMode
    }

    public func imageForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIImage? {
        return image
    }

    public func contentModeForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return contentMode
    }
}

public class ImageURLBrickModel: ImageBrickDataSource {
    var imageURL: NSURL?
    var contentMode: UIViewContentMode

    public init(url: NSURL, contentMode: UIViewContentMode) {
        self.contentMode = contentMode
        self.imageURL = url
    }

    public func imageURLForImageBrickCell(imageBrickCell: ImageBrickCell) -> NSURL? {
        return imageURL
    }

    public func contentModeForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return contentMode
    }
}

// MARK: - Cell

public class ImageBrickCell: BrickCell, Bricklike, AsynchronousResizableCell, ImageDownloaderCell {
    public typealias BrickType = ImageBrick

    public var sizeChangedHandler: CellSizeChangedHandler?

    public var imageDownloader: ImageDownloader?

    private var imageLoaded = false

    @IBOutlet weak var imageView: UIImageView!
    var heightRatioConstraint: NSLayoutConstraint?

    public override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        if !imageLoaded {
            return layoutAttributes
        }
        return super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
    }

    override public func updateContent() {
        super.updateContent()

        imageLoaded = false
        imageView.contentMode = brick.dataSource.contentModeForImageBrickCell(self)
        imageView.image = nil

        if let image = brick.dataSource.imageForImageBrickCell(self) {
            imageView.image = image
            if self.brick.height.isEstimate(in: self) {
                setRatioConstraint(for: image)
            }
            imageLoaded = true
        } else if let imageURL = brick.dataSource.imageURLForImageBrickCell(self) {
            self.imageDownloader?.downloadImage(with: imageURL, onCompletion: { (image) in
                self.imageLoaded = true
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    if self.brick.height.isEstimate(in: self) {
                        self.setRatioConstraint(for: image)
                        self.sizeChangedHandler?(cell: self)
                    }
                    self.imageView.image = image
                })
            })
        }
    }

    /// Set the ratio constraint based on a given image
    ///
    /// - parameter image: Image to use to constraint the ratio
    private func setRatioConstraint(for image: UIImage) {
        if let constraint = self.heightRatioConstraint {
            self.imageView.removeConstraint(constraint)
        }

        let aspectRatio = image.size.width / image.size.height
        let ratioConstraint = NSLayoutConstraint(item:self.imageView, attribute:.Height, relatedBy:.Equal, toItem:self.imageView, attribute:.Width, multiplier: 1.0 / aspectRatio, constant:0)

        self.heightRatioConstraint = ratioConstraint
        self.imageView.addConstraint(ratioConstraint)
        self.setNeedsUpdateConstraints()
        self.imageView.setNeedsUpdateConstraints()
    }
}

//
//  ImageBrick.swift
//  BrickKit
//
//  Created by Justin Shiiba on 6/3/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

// MARK: - Custom ImageView that gives us the flexibility to call a delegate when the is set

public typealias ImageSet = () -> Void

public class ImageBrickImageView: UIImageView {
    public var didSetImage: ImageSet?
    
    public override var image: UIImage? {
        didSet {
            if let didSetCompletion = self.didSetImage where image != nil {
                didSetCompletion()
            }
        }
    }
}

// MARK: - Brick

public class ImageBrick: GenericBrick<UIImageView> {
    public weak var dataSource: ImageBrickDataSource?
    public weak var delegate: ImageBrickDelegate?
    
    private var model: ImageBrickDataSource?

    public override class var internalIdentifier: String {
        return self.nibName
    }

    public override class var cellClass: UICollectionViewCell.Type? {
        return ImageBrickCell.self
    }

    public override class var bundle: NSBundle {
        return NSBundle(forClass: Brick.self)
    }

    public convenience init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, dataSource: ImageBrickDataSource) {
        self.init(identifier, size: BrickSize(width: width, height: height), backgroundColor:backgroundColor, backgroundView:backgroundView, dataSource: dataSource)
    }
    
    public convenience init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, image: UIImage, contentMode: UIViewContentMode) {
        let model = ImageBrickModel(image: image, contentMode: contentMode)
        self.init(identifier, width: width, height: height, backgroundColor:backgroundColor, backgroundView:backgroundView, dataSource: model)
    }
    
    public convenience init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, imageUrl: NSURL, contentMode: UIViewContentMode) {
        let model = ImageURLBrickModel(url: imageUrl, contentMode: contentMode)
        self.init(identifier, width: width, height: height, backgroundColor:backgroundColor, backgroundView:backgroundView, dataSource: model)
    }
    
    
    public init(_ identifier: String = "", size: BrickSize, backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, dataSource: ImageBrickDataSource) {
        
        self.dataSource = dataSource
        super.init(identifier, size: size, backgroundColor:backgroundColor, backgroundView:backgroundView, configureView: { imageView, cell in
            imageView.contentMode = .ScaleToFill
            imageView.clipsToBounds = true
        })
        
        if dataSource is ImageBrickModel || dataSource is ImageURLBrickModel {
            self.model = dataSource
        }
    }
    
    public convenience init(_ identifier: String = "", size: BrickSize, backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, image: UIImage, contentMode: UIViewContentMode) {
        let model = ImageBrickModel(image: image, contentMode: contentMode)
        self.init(identifier, size: size, backgroundColor:backgroundColor, backgroundView:backgroundView, dataSource: model)
    }
    
    public convenience init(_ identifier: String = "", size: BrickSize, backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, imageUrl: NSURL, contentMode: UIViewContentMode) {
        let model = ImageURLBrickModel(url: imageUrl, contentMode: contentMode)
        self.init(identifier, size: size, backgroundColor:backgroundColor, backgroundView:backgroundView, dataSource: model)
    }

    
}

// MARK: - DataSource

/// An object that adopts the `ImageBrickDataSource` protocol is responsible for providing the data required by a `ImageBrick`.
public protocol ImageBrickDataSource: class {
    func imageURLForImageBrickCell(imageBrickCell: ImageBrickCell) -> NSURL?
    func imageForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIImage?
    func contentModeForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIViewContentMode
}

public protocol ImageBrickDelegate: class {
    func didSetImage()
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
    var imageURL: NSURL
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

public class ImageBrickCell: GenericBrickCell, Bricklike, AsynchronousResizableCell, ImageDownloaderCell {
    public typealias BrickType = ImageBrick

    public var sizeChangedHandler: CellSizeChangedHandler?

    public weak var imageDownloader: ImageDownloader?

    private var imageLoaded = false
    private var currentImageURL: NSURL? = nil

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

        if !fromNib {
            self.imageView = self.genericContentView as! UIImageView
        }

        guard let dataSource = brick.dataSource else {
            return
        }

        imageLoaded = false
        imageView.contentMode = dataSource.contentModeForImageBrickCell(self)

        if let image = dataSource.imageForImageBrickCell(self) {
            self.resize(image: image)
            self.set(image)
            imageLoaded = true
        } else if let imageURL = dataSource.imageURLForImageBrickCell(self) {
            guard currentImageURL != imageURL else {
                if let image = self.imageView.image {
                    self.resize(image: image)
                }
                return
            }
            
            imageView.image = nil
            currentImageURL = imageURL


            self.imageDownloader?.downloadImageAndSet(on: self.imageView, with: imageURL, onCompletion: { (image, url) in
                self.imageLoaded = true
                self.resize(image: image)
                
                // Check if the image on the imageView was called in the callback
                if let _ = self.imageView.image, delegate = self.brick.delegate {
                    delegate.didSetImage()
                }
            })
            
        } else {
            imageView.image = nil
        }
    }

    private func set(image: UIImage) {
        self.imageView.image = image
        
        guard let delegate = brick.delegate else {
            return
        }
        
        delegate.didSetImage()
    }

    private func resize(image image: UIImage) {
        if self.brick.size.height.isEstimate(in: self) {
            self.setRatioConstraint(for: image)
            self.sizeChangedHandler?(cell: self)
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

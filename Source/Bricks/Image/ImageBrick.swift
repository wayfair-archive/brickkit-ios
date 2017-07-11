//
//  ImageBrick.swift
//  BrickKit
//
//  Created by Justin Shiiba on 6/3/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

// MARK: - Brick

open class ImageBrick: GenericBrick<UIImageView> {
    open weak var dataSource: ImageBrickDataSource?
    open weak var delegate: ImageBrickDelegate?

    fileprivate var model: ImageBrickDataSource?

    open override class var internalIdentifier: String {
        return self.nibName
    }

    open override class var cellClass: UICollectionViewCell.Type? {
        return ImageBrickCell.self
    }

    open override class var bundle: Bundle {
        return Bundle(for: Brick.self)
    }

    public convenience init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, dataSource: ImageBrickDataSource) {
        self.init(identifier, size: BrickSize(width: width, height: height), backgroundColor:backgroundColor, backgroundView:backgroundView, dataSource: dataSource)
    }
    
    public convenience init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, image: UIImage, contentMode: UIViewContentMode) {
        let model = ImageBrickModel(image: image, contentMode: contentMode)
        self.init(identifier, width: width, height: height, backgroundColor:backgroundColor, backgroundView:backgroundView, dataSource: model)
    }
    
    public convenience init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, imageUrl: URL, contentMode: UIViewContentMode) {
        let model = ImageURLBrickModel(url: imageUrl, contentMode: contentMode)
        self.init(identifier, width: width, height: height, backgroundColor:backgroundColor, backgroundView:backgroundView, dataSource: model)
    }
    
    
    public init(_ identifier: String = "", size: BrickSize, backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, dataSource: ImageBrickDataSource) {
        
        self.dataSource = dataSource
        super.init(identifier, size: size, backgroundColor:backgroundColor, backgroundView:backgroundView, configureView: { imageView, cell in
            imageView.contentMode = .scaleToFill
            imageView.clipsToBounds = true
        })
        
        if dataSource is ImageBrickModel || dataSource is ImageURLBrickModel {
            self.model = dataSource
        }
    }
    
    public convenience init(_ identifier: String = "", size: BrickSize, backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, image: UIImage, contentMode: UIViewContentMode) {
        let model = ImageBrickModel(image: image, contentMode: contentMode)
        self.init(identifier, size: size, backgroundColor:backgroundColor, backgroundView:backgroundView, dataSource: model)
    }
    
    public convenience init(_ identifier: String = "", size: BrickSize, backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, imageUrl: URL, contentMode: UIViewContentMode) {
        let model = ImageURLBrickModel(url: imageUrl, contentMode: contentMode)
        self.init(identifier, size: size, backgroundColor:backgroundColor, backgroundView:backgroundView, dataSource: model)
    }

    
}

// MARK: - DataSource

/// An object that adopts the `ImageBrickDataSource` protocol is responsible for providing the data required by a `ImageBrick`.
public protocol ImageBrickDataSource: class {
    func imageURLForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> URL?
    func imageForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> UIImage?
    func contentModeForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> UIViewContentMode
}

extension ImageBrickDataSource {

    public func imageURLForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> URL? {
        return nil
    }

    public func imageForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> UIImage? {
        return nil
    }

    public func contentModeForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return .scaleToFill
    }
    
}

// MARK: - Delegate

public protocol ImageBrickDelegate: class {
    func didSetImage(brickCell: ImageBrickCell)
}

//MARK: - Models

open class ImageBrickModel: ImageBrickDataSource {
    var image: UIImage?
    var contentMode: UIViewContentMode

    public init(image: UIImage, contentMode: UIViewContentMode) {
        self.image = image
        self.contentMode = contentMode
    }

    open func imageForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> UIImage? {
        return image
    }

    open func contentModeForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return contentMode
    }
}

open class ImageURLBrickModel: ImageBrickDataSource {
    var imageURL: URL
    var contentMode: UIViewContentMode
    
    public init(url: URL, contentMode: UIViewContentMode) {
        self.contentMode = contentMode
        self.imageURL = url
    }
    
    open func imageURLForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> URL? {
        return imageURL
    }
    
    open func contentModeForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return contentMode
    }
}


// MARK: - Cell

open class ImageBrickCell: GenericBrickCell, Bricklike, AsynchronousResizableCell, ImageDownloaderCell {
    public typealias BrickType = ImageBrick

    public weak var resizeDelegate: AsynchronousResizableDelegate?

    open weak var imageDownloader: ImageDownloader?

    fileprivate var imageLoaded = false
    fileprivate var currentImageURL: URL? = nil

    @IBOutlet weak var imageView: UIImageView!
    var heightRatioConstraint: NSLayoutConstraint?

    open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        if !imageLoaded {
            return layoutAttributes
        }
        return super.preferredLayoutAttributesFitting(layoutAttributes)
    }

    override open func updateContent() {
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
            if self.brick.size.height.isEstimate(withValue: nil) {
                self.setRatioConstraint(for: image)
            }
            imageView.image = image
            
            if let delegate = brick.delegate {
                delegate.didSetImage(brickCell: self)
            }
            
            imageLoaded = true
        }
    }

    override open func willDisplay() {
        super.willDisplay()

        guard let dataSource = brick.dataSource, imageLoaded == false else {
            return
        }

        if let imageURL = dataSource.imageURLForImageBrickCell(self) {
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
                
                if let delegate = self.brick.delegate, let _ = self.imageView.image {
                    delegate.didSetImage(brickCell: self)
                }
            })
        } else {
            imageView.image = nil
        }
    }


    fileprivate func resize(image: UIImage) {
        if self.brick.size.height.isEstimate(withValue: nil) {
            self.setRatioConstraint(for: image)
            self.resizeDelegate?.performResize(cell: self, completion: nil)
        }
    }

    /// Set the ratio constraint based on a given image
    ///
    /// - parameter image: Image to use to constraint the ratio
    fileprivate func setRatioConstraint(for image: UIImage) {
        if let constraint = self.heightRatioConstraint {
            self.imageView.removeConstraint(constraint)
        }

        let aspectRatio = image.size.width / image.size.height
        let ratioConstraint = NSLayoutConstraint(item:self.imageView, attribute:.height, relatedBy:.equal, toItem:self.imageView, attribute:.width, multiplier: 1.0 / aspectRatio, constant:0)

        self.heightRatioConstraint = ratioConstraint
        self.imageView.addConstraint(ratioConstraint)
        self.setNeedsUpdateConstraints()
        self.imageView.setNeedsUpdateConstraints()
    }
}

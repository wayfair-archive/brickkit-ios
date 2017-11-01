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

    @IBOutlet public weak var imageView: UIImageView!
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
            self.setImage(image)
        } else if let _ = dataSource.imageURLForImageBrickCell(self) {
            self.setNeedsLayout() // calls layoutSubviews on UI pass, which calls framesDidLayout()
        }
    }

    override open func framesDidLayout() {
        super.framesDidLayout()

        guard let dataSource = brick.dataSource, !imageLoaded else {
            return
        }

        guard let imageURL = dataSource.imageURLForImageBrickCell(self) else {
            imageView.image = nil
            return
        }

        // If the requested url is the same as the existing, and the image is already set, then just resize
        if let image = self.imageView.image, self.currentImageURL == imageURL {
            self.setImage(image)
            return
        }

        self.currentImageURL = imageURL
        self.imageDownloader?.downloadImage(with: imageURL, onCompletion: { [weak self] (image: UIImage, url: URL) in
            // check again that the url we fetched is the same
            if self?.currentImageURL == url {
                DispatchQueue.main.async {
                    self?.setImage(image)
                }
            }
        })
    }

    fileprivate func setImage(_ image: UIImage) {
        assert(Thread.isMainThread)
        self.imageLoaded = true
        self.resize(image: image, onCompletion: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.imageView.image = image
            strongSelf.brick.delegate?.didSetImage(brickCell: strongSelf)
        })
    }

    override open func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        currentImageURL = nil
        imageLoaded = false
        if let constraint = self.heightRatioConstraint {
            self.imageView.removeConstraint(constraint)
        }
    }

    fileprivate func resize(image: UIImage, onCompletion: @escaping (() -> Void)) {
        if self.brick.size.height.isEstimate(withValue: nil) {
            self.setRatioConstraint(for: image)
            guard let resizeDelegate = self.resizeDelegate else {
                onCompletion()
                return
            }
            resizeDelegate.performResize(cell: self, completion: onCompletion)
        } else {
            onCompletion()
        }
    }

    /// Set the ratio constraint based on a given image
    ///
    /// - parameter image: Image to use to constraint the ratio
    fileprivate func setRatioConstraint(for image: UIImage) {
        assert(Thread.isMainThread)
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

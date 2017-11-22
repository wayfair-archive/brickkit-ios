//
//  BrickCollectionCell.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/26/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit

public typealias ConfigureCollectionBrickBlock = ((_ cell: CollectionBrickCell) -> Void)
public typealias RegisterBricksCollectionBrickBlock = ((_ cell: CollectionBrickCell) -> Void)

// MARK: - Brick

open class CollectionBrick: Brick {
    weak var dataSource: CollectionBrickCellDataSource?
    let scrollDirection: UICollectionViewScrollDirection
    var shouldCalculateFullHeight: Bool = true // This flag indicates that the collection brick is small enough to calculate its whole height directly
    var brickTypes: [Brick.Type]
    
    fileprivate var model: CollectionBrickCellModel?
    
    public convenience init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, scrollDirection: UICollectionViewScrollDirection = .vertical, dataSource: CollectionBrickCellDataSource, brickTypes: [Brick.Type] = []) {
        self.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView, scrollDirection: scrollDirection, dataSource: dataSource, brickTypes: brickTypes)
    }
    
    public init(_ identifier: String, size: BrickSize, backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, scrollDirection: UICollectionViewScrollDirection = .vertical, dataSource: CollectionBrickCellDataSource, brickTypes: [Brick.Type] = []) {
        self.dataSource = dataSource
        self.scrollDirection = scrollDirection
        
        self.brickTypes = brickTypes
        super.init(identifier, size: size, backgroundColor: backgroundColor, backgroundView: backgroundView)
        
        if dataSource is CollectionBrickCellModel {
            self.model = dataSource as? CollectionBrickCellModel
        }
    }
}

// MARK: - DataSource

/// An object that adopts the `CollectionBrickCellDataSource` protocol is responsible for providing the data required by a `CollectionBrick`.
public protocol CollectionBrickCellDataSource: class {
   
    func configure(for cell: CollectionBrickCell)
    
    func registerBricks(for cell: CollectionBrickCell)
    func dataSourceForCollectionBrickCell(_ cell: CollectionBrickCell) -> BrickCollectionViewDataSource 
    func sectionForCollectionBrickCell(_ cell: CollectionBrickCell) -> BrickSection
    func currentPageForCollectionBrickCell(_ cell: CollectionBrickCell) -> Int?
}

public extension CollectionBrickCellDataSource {

    func dataSourceForCollectionBrickCell(_ cell: CollectionBrickCell) -> BrickCollectionViewDataSource {
        return BrickCollectionViewDataSource()
    }

    func sectionForCollectionBrickCell(_ cell: CollectionBrickCell) -> BrickSection {
        return dataSourceForCollectionBrickCell(cell).section
    }

    func currentPageForCollectionBrickCell(_ brickCollectionCell: CollectionBrickCell) -> Int? {
        return nil
    }
    
    func configure(for cell: CollectionBrickCell) {}
    
    func registerBricks(for cell: CollectionBrickCell) {}
}

// MARK: - Models

open class CollectionBrickCellModel: CollectionBrickCellDataSource {
    open var section: BrickSection {
        didSet {
            dataSource.setSection(section)
        }
    }
    
    open var configureHandler: ConfigureCollectionBrickBlock?
    open var registerBricksHandler: RegisterBricksCollectionBrickBlock?
    open var dataSource: BrickCollectionViewDataSource

    public init(section: BrickSection, configureHandler: ConfigureCollectionBrickBlock? = nil, registerBricksHandler: RegisterBricksCollectionBrickBlock? = nil) {
        self.section = section
        self.configureHandler = configureHandler
        self.registerBricksHandler = registerBricksHandler
        dataSource = BrickCollectionViewDataSource()
        dataSource.setSection(section)
    }

    open func dataSourceForCollectionBrickCell(_ brickCollectionCell: CollectionBrickCell) -> BrickCollectionViewDataSource {
        return dataSource
    }
    
    open func configure(for cell: CollectionBrickCell) {
        configureHandler?(cell)
    }

    open func registerBricks(for cell: CollectionBrickCell) {
        registerBricksHandler?(cell)
    }
}

// MARK: - Cell

open class CollectionBrickCell: BrickCell, Bricklike, AsynchronousResizableCell {
    public typealias BrickType = CollectionBrick

    public weak var resizeDelegate: AsynchronousResizableDelegate?

    /// Flag that indicates if the CollectionBrick is calculating its height
    // This is introduced because otherwise the sizeChangedHandler might get called while calculating.
    // The sizeChangedHandler should only be used for Asynchronous size changes
    // https://github.com/wayfair/brickkit-ios/issues/28
    fileprivate var isCalculatingHeight = false

    @IBOutlet open weak var brickCollectionView: BrickCollectionView!

    @IBOutlet open weak var chevronImage: UIImageView? {
        didSet {
            chevronImage?.image = UIImage(named: "chevron", in: CollectionBrick.bundle, compatibleWith: nil)
        }
    }

    open var currentPage: Int? {
        didSet {
            guard let currentPage = currentPage else {
                return
            }

            var contentOffsetX: CGFloat

            contentOffsetX = brickCollectionView.frame.width * CGFloat(currentPage)

            let contentOffset = CGPoint(x: contentOffsetX, y: 0.0);
            brickCollectionView.setContentOffset(contentOffset, animated:true)
        }
    }

    open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let dataSource = brick.dataSource else {
            return super.preferredLayoutAttributesFitting(layoutAttributes)
        }
        
        guard self._brick.size.height.isEstimate(withValue: nil) else {
            return layoutAttributes
        }
        
        guard self._brick.height.isEstimate(withValue: nil) else {
            layoutAttributes.frame.size.height = self._brick.height.value(for: layoutAttributes.frame.width, startingAt: 0)
            return layoutAttributes
        }
        
        isCalculatingHeight = true

        brickCollectionView.frame = layoutAttributes.bounds

        currentPage = dataSource.currentPageForCollectionBrickCell(self)
        brickCollectionView.layoutSubviews()

        if brick.shouldCalculateFullHeight && brickCollectionView.frame.height > 0 {
            var y = brickCollectionView.frame.height
            while y < brickCollectionView.contentSize.height {
                brickCollectionView.contentOffset.y += brickCollectionView.frame.height
                brickCollectionView.layoutSubviews()
                y += brickCollectionView.frame.height
            }
            brickCollectionView.contentOffset.y = 0
        }

        isCalculatingHeight = false

        return super.preferredLayoutAttributesFitting(layoutAttributes)
    }

    open override func heightForBrickView(withWidth width: CGFloat) -> CGFloat {
        return brickCollectionView.layout.collectionViewContentSize.height
    }

    open override func updateContent() {
        super.updateContent()

        brickCollectionView.resetRegisteredBricks()
        brickCollectionView.layout.delegate = self

        brickCollectionView.beginConfiguration {
            self.brick.dataSource?.configure(for: self)
        }
        
        brick.brickTypes.forEach {
            self.brickCollectionView.registerBrickClass($0)
        }
        
        brick.dataSource?.registerBricks(for: self)
        
        brickCollectionView.collectionInfo = CollectionInfo(index: self.index, identifier: self.brick.identifier)
        brickCollectionView.layout.scrollDirection = brick.scrollDirection
        
        if let section = brick.dataSource?.sectionForCollectionBrickCell(self) {
            brickCollectionView.setSection(section)
        }
    }
}

extension CollectionBrickCell: BrickLayoutDelegate {

    public func brickLayout(_ layout: BrickLayout, didUpdateHeightForItemAtIndexPath indexPath: IndexPath) {
        guard !isCalculatingHeight else {
            return
        }

        self.resizeDelegate?.performResize(cell: self, completion: { [weak self] in
            self?.brickCollectionView.layoutSubviews()
        })
    }

}

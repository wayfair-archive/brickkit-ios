//
//  BrickCollectionCell.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/26/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit

public typealias ConfigureCollectionBrickBlock = ((cell: CollectionBrickCell) -> Void)
public typealias RegisterBricksCollectionBrickBlock = ((cell: CollectionBrickCell) -> Void)

// MARK: - Brick

public class CollectionBrick: Brick {
    let dataSource: CollectionBrickCellDataSource
    let scrollDirection: UICollectionViewScrollDirection
    var shouldCalculateFullHeight: Bool = true // This flag indicates that the collection brick is small enough to calculate its whole height directly
    var brickTypes: [Brick.Type]
    
    public init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, scrollDirection: UICollectionViewScrollDirection = .Vertical, dataSource: CollectionBrickCellDataSource, brickTypes: [Brick.Type] = []) {
        self.dataSource = dataSource
        self.scrollDirection = scrollDirection
        
        self.brickTypes = brickTypes
        
        super.init(identifier, width: width, height: height, backgroundColor: backgroundColor, backgroundView: backgroundView)
    }
}

// MARK: - DataSource

/// An object that adopts the `CollectionBrickCellDataSource` protocol is responsible for providing the data required by a `CollectionBrick`.
public protocol CollectionBrickCellDataSource {
   
    func configure(for cell: CollectionBrickCell)
    
    func registerBricks(for cell: CollectionBrickCell)
    func dataSourceForCollectionBrickCell(cell: CollectionBrickCell) -> BrickCollectionViewDataSource 
    func sectionForCollectionBrickCell(cell: CollectionBrickCell) -> BrickSection
    func currentPageForCollectionBrickCell(cell: CollectionBrickCell) -> Int?
}

public extension CollectionBrickCellDataSource {

    func dataSourceForCollectionBrickCell(cell: CollectionBrickCell) -> BrickCollectionViewDataSource {
        return BrickCollectionViewDataSource()
    }

    func sectionForCollectionBrickCell(cell: CollectionBrickCell) -> BrickSection {
        return dataSourceForCollectionBrickCell(cell).section
    }

    func currentPageForCollectionBrickCell(brickCollectionCell: CollectionBrickCell) -> Int? {
        return nil
    }
    
    func configure(for cell: CollectionBrickCell) {}
    
    func registerBricks(for cell: CollectionBrickCell) {}
}

// MARK: - Models

public class CollectionBrickCellModel: CollectionBrickCellDataSource {
    public var section: BrickSection {
        didSet {
            dataSource.setSection(section)
        }
    }
    
    public var configureHandler: ConfigureCollectionBrickBlock?
    public var registerBricksHandler: RegisterBricksCollectionBrickBlock?
    public var dataSource: BrickCollectionViewDataSource

    public init(section: BrickSection, configureHandler: ConfigureCollectionBrickBlock? = nil, registerBricksHandler: RegisterBricksCollectionBrickBlock? = nil) {
        self.section = section
        self.configureHandler = configureHandler
        self.registerBricksHandler = registerBricksHandler
        dataSource = BrickCollectionViewDataSource()
        dataSource.setSection(section)
    }

    public func dataSourceForCollectionBrickCell(brickCollectionCell: CollectionBrickCell) -> BrickCollectionViewDataSource {
        return dataSource
    }
    
    public func configure(for cell: CollectionBrickCell) {
        configureHandler?(cell: cell)
    }

    public func registerBricks(for cell: CollectionBrickCell) {
        registerBricksHandler?(cell: cell)
    }
}

// MARK: - Cell

public class CollectionBrickCell: BrickCell, Bricklike, AsynchronousResizableCell {
    public typealias BrickType = CollectionBrick

    public var sizeChangedHandler: CellSizeChangedHandler?

    /// Flag that indicates if the CollectionBrick is calculating its height
    // This is introduced because otherwise the sizeChangedHandler might get called while calculating.
    // The sizeChangedHandler should only be used for Asynchronous size changes
    // https://github.com/wayfair/brickkit-ios/issues/28
    private var isCalculatingHeight = false

    @IBOutlet public weak var brickCollectionView: BrickCollectionView! {
        didSet {
            self.layout = brickCollectionView.layout as? BrickFlowLayout
        }
    }
    @IBOutlet public weak var chevronImage: UIImageView? {
        didSet {
            chevronImage?.image = UIImage(named: "chevron", inBundle: CollectionBrick.bundle, compatibleWithTraitCollection: nil)
        }
    }

    public var layout: BrickFlowLayout?

    public var currentPage: Int? {
        didSet {
            guard let currentPage = currentPage else {
                return
            }

            var contentOffsetX: CGFloat

            contentOffsetX = brickCollectionView.frame.width * CGFloat(currentPage)

            let contentOffset = CGPointMake(contentOffsetX, 0.0);
            brickCollectionView.setContentOffset(contentOffset, animated:true)
        }
    }

    public override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        isCalculatingHeight = true

        brickCollectionView.frame = layoutAttributes.bounds
        self.currentPage = brick.dataSource.currentPageForCollectionBrickCell(self)
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

        return super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
    }

    public override func heightForBrickView(withWidth width: CGFloat) -> CGFloat {
        return brickCollectionView.collectionViewLayout.collectionViewContentSize().height
    }

    public override func updateContent() {
        super.updateContent()

        brickCollectionView.resetRegisteredBricks()
        brickCollectionView.layout.delegate = self

        brickCollectionView.beginConfiguration {
            self.brick.dataSource.configure(for: self)
        }
        
        brick.brickTypes.forEach {
            self.brickCollectionView.registerBrickClass($0)
        }
        
        brick.dataSource.registerBricks(for: self)
        
        brickCollectionView.collectionInfo = CollectionInfo(index: self.index, identifier: self.brick.identifier)
        
        let section = brick.dataSource.sectionForCollectionBrickCell(self)
        brickCollectionView.setSection(section)

        layout?.scrollDirection = brick.scrollDirection
        layout?.dataSource = brickCollectionView
    }
}

extension CollectionBrickCell: BrickLayoutDelegate {

    public func brickLayout(layout: BrickLayout, didUpdateHeightForItemAtIndexPath indexPath: NSIndexPath) {
        guard !isCalculatingHeight else {
            return
        }

        sizeChangedHandler?(cell: self)
        brickCollectionView.layoutSubviews()
    }

}

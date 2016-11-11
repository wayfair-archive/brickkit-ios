//
//  BrickCollectionView.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/26/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit

/// Tuple describing the brick, its index and the index/identifier of the collectionbrick
public typealias BrickInfo = (brick: Brick, index: Int, collectionIndex: Int, collectionIdentifier: String)

/// Prefix used for custom registerd nibs, to avoid name collission
private let CustomNibPrefix = "CustomNib."

/// The BrickCollectionView class manages the views of bricks that a BrickSection represents
public class BrickCollectionView: UICollectionView {

    // MARK: - Public Properties

    /// Static reference to initialize all images that need to be downloaded
    public static var imageDownloader: ImageDownloader = NSURLSessionImageDownloader()

    /// The brick layout
    public var layout: BrickLayout {
        return collectionViewLayout as! BrickLayout
    }

    /// Override to check if the layout is a BrickLayout
    public override var collectionViewLayout: UICollectionViewLayout {
        willSet {
            if !(newValue is BrickLayout) {
                fatalError("BrickCollectionView: the layout needs to be of type `BrickLayout`")
            }
        }
    }

    // MARK: - Private Properties

    /// Index of the CollectionBrick that this BrickCollectionView is in
    internal var collectionInfo: CollectionInfo = CollectionInfo(index: 0, identifier: "") {
        didSet {
            section.invalidateCounts(in: collectionInfo)
        }
    }

    /// Section model. Starts with an empty brick section
    public private(set) var section: BrickSection = BrickSection(bricks: []) {
        didSet {
            section.invalidateCounts(in: collectionInfo)
            self.reloadData()
        }
    }

    /// Dictionary to keep track of what identifier to load for a certain brick
    internal private(set) var registeredBricks: [String:String] = [:]

    internal private(set) var isConfiguringCollectionBrick: Bool = false

    // MARK: - Overrides

    public override var frame: CGRect {
        didSet {
            // Current workaround: If the layout has behaviors, `shouldInvalidateLayoutForBoundsChange` is not called
            if frame != oldValue {
                self.invalidateOnBoundsChange()
            }
        }
    }

    // MARK: - Initializers

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeComponents()
    }

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initializeComponents()
    }

    public init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: BrickFlowLayout())
        initializeComponents()
    }

    private func initializeComponents() {
        autoreleasepool { // Setting the dataSource will result in not releasing the BrickCollectionView even when its being set to nil
            self.dataSource = self
        }
        layout.dataSource = self
        registerClass(BrickSectionCell.self, forCellWithReuseIdentifier: BrickSection.nibName)
    }

}

// MARK: - Setting up the models
extension BrickCollectionView {

    /// Sets the section for the BrickCollectionView
    ///
    /// - parameter section: Section to set
    public func setSection(section: BrickSection) {
        self.section = section
    }

    public func brick(at indexPath: NSIndexPath) -> Brick {
        self.section.invalidateIfNeeded(in: collectionInfo)
        guard let brick = section.brick(at: indexPath, in: collectionInfo) else {
            fatalError("Brick not found at indexPath: SECTION - \(indexPath.section) - ITEM: \(indexPath.item). This should never happen")
        }
        return brick
    }

    public func indexPathsForBricksWithIdentifier(identifier: String, index: Int? = nil) -> [NSIndexPath] {
        return self.section.indexPathsForBricksWithIdentifier(identifier, index: index, in: collectionInfo)
    }

    /// Register a brick class.
    /// If there is a class (`cellClass`) registered to this Brick, this will be registered to the UICollectionView.
    /// If there is no class, the nib (`nibName`) will be used to register
    ///
    /// - parameter brickClass: The brick class to register
    public func registerBrickClass(brickClass: Brick.Type) {
        let nibName = brickClass.nibName
        let cellIdentifier: String

        if let cellClass = brickClass.cellClass {
            cellIdentifier = nibName
            self.registerClass(cellClass, forCellWithReuseIdentifier: cellIdentifier)
        } else if let _ = brickClass.bundle.pathForResource(nibName, ofType: "nib") {
            let nib = UINib(nibName: nibName, bundle: brickClass.bundle)
            cellIdentifier = String(nib.hashValue)
            self.registerNib(nib, forCellWithReuseIdentifier: cellIdentifier)
        } else {
            fatalError("Nib or cell class not found")
        }
        
        if isConfiguringCollectionBrick {
            print("calling `registerBrickClass` in `configure(for cell: CollectionBrickCell)` is deprecated. Use `registerBricks(for cell: CollectionBrickCell)` or `CollectionBrickCell(brickTypes: [Brick.Type])`. This will be a fatalError in a future release")
        }
        
        registeredBricks[nibName] = cellIdentifier
    }

    /// Register a brick class.
    /// If there is a class (`cellClass`) registered to this Brick, this will be registered to the UICollectionView.
    /// If there is no class, the nib (`nibName`) will be used to register
    ///
    /// - parameter brickClass: The brick class to register
    public func registerNib(nib: UINib, forBrickWithIdentifier identifier: String) {
        let cellIdentifier = String(nib.hashValue)
        self.registerNib(nib, forCellWithReuseIdentifier: cellIdentifier)
        
        if isConfiguringCollectionBrick {
            print("calling `registerNib` in `configure(for cell: CollectionBrickCell)` is deprecated. Use `registerBricks(for cell: CollectionBrickCell)`. This will be a fatalError in a future release")
        }
        
        registeredBricks[CustomNibPrefix + identifier] = cellIdentifier
    }

    /// Get the brick, index and collection index of a certain indexPath
    ///
    /// - parameter indexPath: IndexPath
    ///
    /// - returns: BrickInfo
    public func brickInfo(at indexPath: NSIndexPath) -> BrickInfo {
        guard let brickAndIndex = section.brickAndIndex(at: indexPath, in: collectionInfo) else {
            fatalError("Brick and index not found at indexPath: SECTION - \(indexPath.section) - ITEM: \(indexPath.item). This should never happen")
        }
        return (brickAndIndex.0, brickAndIndex.1, collectionInfo.index, collectionInfo.identifier)
    }

    // MARK: - Internal methods

    internal func resetRegisteredBricks() {
        registeredBricks = [:]
    }

    internal func identifierForBrick(brick: Brick, collectionView: UICollectionView) -> String {
        let identifier: String
        if brick is BrickSection {
            //Safeguard to never load the wrong nib for a BrickSection,
            //eventhough the identifier is actually in the registeredNibs
            identifier = BrickSection.nibName
        } else if let brickIdentifier = registeredBricks[CustomNibPrefix + brick.identifier] {
            identifier = brickIdentifier
        } else if let brickIdentifier = registeredBricks[brick.nibName] {
            identifier = brickIdentifier
        } else {
            fatalError("No Nib Found for \(brick)")
        }
        return identifier
    }

}

// MARK: - Invalidation
extension BrickCollectionView {

    /// Invalidate the layout properties and recalculate sizes
    ///
    /// - parameter completion: A completion handler block to execute when all of the operations are finished. This block takes a single Boolean parameter that contains the value true if all of the related animations completed successfully or false if they were interrupted. This parameter may be nil.
    public func invalidateBricks(completion: ((Bool) -> Void)? = nil) {
        self.invalidateRepeatCountsWithoutPerformBatchUpdates(false)
        self.performBatchUpdates({
            self.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.numberOfSections())))
            self.collectionViewLayout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .Invalidate))
            }, completion: { completed in
                completion?(completed)
        })
    }

    /// Invalidate the visibility
    ///
    /// - parameter completion: A completion handler block to execute when all of the operations are finished. This block takes a single Boolean parameter that contains the value true if all of the related animations completed successfully or false if they were interrupted. This parameter may be nil.
    public func invalidateVisibility(completion: ((Bool) -> Void)? = nil) {
        self.performBatchUpdates({
            self.collectionViewLayout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .UpdateVisibility))
            }, completion: completion)
    }

    // MARK: - Private methods

    /// Invalidate the layout for bounds change
    private func invalidateOnBoundsChange() {
        if collectionViewLayout.shouldInvalidateLayoutForBoundsChange(bounds) {
            self.collectionViewLayout.invalidateLayoutWithContext(self.collectionViewLayout.invalidationContextForBoundsChange(self.bounds))
        }
    }
    
}

// MARK: - Reloading
extension BrickCollectionView {

    /// Reload bricks in a collectionbrick
    ///
    /// - parameter identifiers:               Identifiers
    /// - parameter collectionBrickIdentifier: CollectionBrick identifier
    /// - parameter index:                     CollectionBrick Index
    public func reloadBricksWithIdentifiers(identifiers: [String], inCollectionBrickWithIdentifier collectionBrickIdentifier: String, andIndex index: Int? = nil) {
        let indexPaths = section.indexPathsForBricksWithIdentifier(collectionBrickIdentifier, index: index, in: collectionInfo)

        for indexPath in indexPaths {
            //Reload the brick cell itself
            guard let brickCell = cellForItemAtIndexPath(indexPath) as? CollectionBrickCell else {
                return
            }

            brickCell.brickCollectionView.reloadBricksWithIdentifiers(identifiers)
        }
    }

    /// Reload one brick at a certain index
    ///
    /// - parameter invalidate: Flag that indicates if the function should also invalidate the layout
    /// Default to true, but could be set to false if it's part of a bigger invalidation
    public func reloadBrickWithIdentifier(identifier: String, andIndex index: Int, invalidate: Bool = true) {
        let indexPaths = section.indexPathsForBricksWithIdentifier(identifier, index: index, in: collectionInfo)
        self.reloadItemsAtIndexPaths(indexPaths)

        if invalidate {
            let context = UICollectionViewLayoutInvalidationContext()
            context.invalidateItemsAtIndexPaths(indexPaths)
            self.collectionViewLayout.invalidateLayoutWithContext(context)
        }
    }

    /// Invalidate a height for a brick
    ///
    /// - parameter identifier: Identifier of the brick
    /// - parameter newHeight:  Optional height. If set, the height is fixed. If not, the height will be recalculated
    @available(*, deprecated, message="use AsynchronousResizableCell")
    public func invalidateHeightForBrickWithIdentifier(identifier: String, newHeight: CGFloat?) {
        let indexPaths = section.indexPathsForBricksWithIdentifier(identifier, in: collectionInfo)
        for indexPath in indexPaths {
            if let newHeight = newHeight {
                self.brick(at: indexPath).height = .Fixed(size: newHeight)
                self.collectionViewLayout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .UpdateHeight(indexPath: indexPath, newHeight: newHeight)))
            } else {
                self.collectionViewLayout.invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .InvalidateHeight(indexPath: indexPath)))
                self.reloadBricksWithIdentifiers([identifier], shouldReloadCell: true)
            }
        }
    }

    /// Invalidate all the repeat counts of the given
    ///
    /// - parameter completion: Completion Block
    public func invalidateRepeatCounts(reloadAllSections: Bool = false, completion: ((completed: Bool, insertedIndexPaths: [NSIndexPath], deletedIndexPaths: [NSIndexPath]) -> Void)? = nil) {
        var insertedIndexPaths: [NSIndexPath]!
        var deletedIndexPaths: [NSIndexPath]!

        self.performBatchUpdates({
            let result = self.invalidateRepeatCountsWithoutPerformBatchUpdates(reloadAllSections)
            insertedIndexPaths = result.insertedIndexPaths
            deletedIndexPaths = result.deletedIndexPaths
            }) { (completed) in
                completion?(completed: completed, insertedIndexPaths: insertedIndexPaths, deletedIndexPaths: deletedIndexPaths)
        }
    }

    private func invalidateRepeatCountsWithoutPerformBatchUpdates(reloadAllSections: Bool) -> (insertedIndexPaths: [NSIndexPath], deletedIndexPaths: [NSIndexPath]) {

        let brickSection = self.section

        var insertedIndexPaths = [NSIndexPath]()
        var deletedIndexPaths = [NSIndexPath]()
        var reloadIndexPaths = [NSIndexPath]()
        let sectionsToReload = NSMutableIndexSet()

        let oldCounts = brickSection.currentSectionCounts(in: self.collectionInfo)
        brickSection.invalidateCounts(in: self.collectionInfo)
        let newCounts = brickSection.currentSectionCounts(in: self.collectionInfo)

        for (section, oldCount) in oldCounts {
            let newCount = newCounts[section]! //We can unwrap safely, because the indexes should always be the same

            let sameCount = newCount == oldCount
            if !sameCount || reloadAllSections {
                sectionsToReload.addIndex(section)
            }

            if sameCount {
                continue
            }

            let countDiff = newCount - oldCount

            let removed = countDiff < 0
            var indexPaths: [NSIndexPath] = []

            var currentCount = newCount
            if removed {
                currentCount += abs(countDiff)
            }

            for i in 0..<abs(countDiff) {
                indexPaths.append(NSIndexPath(forItem: (currentCount - i - 1), inSection: section))
            }

            if removed {
                deletedIndexPaths.appendContentsOf(indexPaths)
            } else {
                insertedIndexPaths.appendContentsOf(indexPaths)
            }

            if let sectionIndexPath = brickSection.indexPathForSection(section, in: self.collectionInfo) {
                reloadIndexPaths.append(sectionIndexPath)
            }
        }

        if !insertedIndexPaths.isEmpty {
            self.insertItemsAtIndexPaths(insertedIndexPaths)
        }

        if !deletedIndexPaths.isEmpty {
            self.deleteItemsAtIndexPaths(deletedIndexPaths)
        }

        if !reloadIndexPaths.isEmpty {
            self.reloadItemsAtIndexPaths(reloadIndexPaths)
        }

        if sectionsToReload.count > 0 {
            self.reloadSections(sectionsToReload)
        }

        return (insertedIndexPaths, deletedIndexPaths)
    }

    /// Reload the bricks that have the given identifiers
    ///
    /// - parameter identifiers:      Brick Identifiers
    /// - parameter shouldReloadCell: If true, the `reloadItemAtIndexPath` will be called. If false, just the `reloadContent` of the brick will be called
    /// - parameter completion:       A completion handler block to execute when all of the operations are finished. This block takes a single Boolean parameter that contains the value true if all of the related animations completed successfully or false if they were interrupted. This parameter may be nil.
    public func reloadBricksWithIdentifiers(identifiers: [String], shouldReloadCell: Bool = false, completion: ((Bool) -> Void)? = nil) {
        if shouldReloadCell {
            self.performBatchUpdates({
                self._reloadBricksWithIdentifiers(identifiers, shouldReloadCell: shouldReloadCell)
                }, completion: completion)
        } else {
            self._reloadBricksWithIdentifiers(identifiers, shouldReloadCell: shouldReloadCell)
            completion?(true)
        }
    }

    private func _reloadBricksWithIdentifiers(identifiers: [String], shouldReloadCell: Bool) {
        var insertedIndexPaths = [NSIndexPath]()
        var removedIndexPaths = [NSIndexPath]()
        var reloadIndexPaths = [NSIndexPath]()
        let sectionsToReload = NSMutableIndexSet()

        for identifier in identifiers {
            let indexPaths = self.section.indexPathsForBricksWithIdentifier(identifier, in: collectionInfo)
            for indexPath in indexPaths {
                let brick = self.section.brick(at:indexPath, in: collectionInfo)!

                if let brickSection = brick as? BrickSection {
                    self.reloadBrickSection(brickSection, insertedIndexPaths: &insertedIndexPaths, removedIndexPaths: &removedIndexPaths, sectionsToReload: sectionsToReload)
                }

                //Reload the brick cell itself
                if shouldReloadCell {
                    reloadIndexPaths.append(indexPath)
                } else if let brickCell = self.cellForItemAtIndexPath(indexPath) as? BrickCell {
                    brickCell.reloadContent()
                }
            }
        }

        if !shouldReloadCell {
            return
        }

        if !insertedIndexPaths.isEmpty {
            self.insertItemsAtIndexPaths(insertedIndexPaths)
        }

        if !removedIndexPaths.isEmpty {
            self.deleteItemsAtIndexPaths(removedIndexPaths)
        }

        if !reloadIndexPaths.isEmpty {
            self.reloadItemsAtIndexPaths(reloadIndexPaths)
        }

        if sectionsToReload.count > 0 {
            self.reloadSections(sectionsToReload)
        }
    }

    private func reloadBrickSection(brickSection: BrickSection, inout insertedIndexPaths: [NSIndexPath], inout removedIndexPaths: [NSIndexPath], sectionsToReload: NSMutableIndexSet) {
        let updatedSections = reloadSectionWithIdentifier(brickSection.identifier)

        for (section, count) in updatedSections {
            let removed = count < 0
            var indexPaths:[NSIndexPath] = []

            var currentCount = self.collectionView(self, numberOfItemsInSection: section)
            if removed {
                currentCount += abs(count)
            }

            for i in 0..<abs(count) {
                indexPaths.append(NSIndexPath(forItem: (currentCount - i - 1), inSection: section))
            }

            if removed {
                removedIndexPaths.appendContentsOf(indexPaths)
            } else {
                insertedIndexPaths.appendContentsOf(indexPaths)
            }
            sectionsToReload.addIndex(section)
        }
    }

    /// Reload sections with identifiers
    ///
    /// - parameter identifier: identifier
    ///
    /// - returns: A dictionary with the section as the key and the value is the change count
    private func reloadSectionWithIdentifier(identifier: String) -> [Int: Int] {
        let oldCounts = self.section.currentSectionCounts(in: collectionInfo)
        self.section.invalidateCounts(in: collectionInfo)
        let newCounts = self.section.currentSectionCounts(in: collectionInfo)

        var changedSections: [Int: Int] = [:]
        for (section, oldCount) in oldCounts {
            let newCount = newCounts[section]! //We can unwrap safely, because the indexes should always be the same
            if oldCount != newCount {
                changedSections[section] = newCount - oldCount
            }

        }

        return changedSections
    }

    internal func beginConfiguration(action: (() -> Void)) {
        isConfiguringCollectionBrick = true
        action()
        isConfiguringCollectionBrick = false
    }
}

// MARK: - UICollectionViewDataSource
extension BrickCollectionView: UICollectionViewDataSource {

    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.section.numberOfSections(in: collectionInfo)
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.section.numberOfItems(in: section, in: collectionInfo)
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let brickCollectionView = collectionView as? BrickCollectionView else {
            fatalError("Only BrickCollectionViews are supported")
        }

        let info = brickCollectionView.brickInfo(at: indexPath)
        let brick = info.brick
        let identifier = brickCollectionView.identifierForBrick(brick, collectionView: collectionView)

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! BaseBrickCell

        if let brickCell = cell as? BrickCell {
            if var resizable = brickCell as? AsynchronousResizableCell {
                resizable.sizeChangedHandler = { [weak collectionView] cell in
                    let height = cell.heightForBrickView(withWidth: brickCell.frame.width)
                    if let brickCollectionView = collectionView as? BrickCollectionView, let flow = brickCollectionView.layout as? BrickFlowLayout {
                        brickCollectionView.performBatchUpdates({ 
                            flow.updateHeight(indexPath, newHeight: height)
                            }, completion: nil)
                    }
                }
            }

            if var downloadable = brickCell as? ImageDownloaderCell {
                downloadable.imageDownloader = BrickCollectionView.imageDownloader
            }

            brickCell.setContent(brick, index: info.index, collectionIndex: info.collectionIndex, collectionIdentifier: info.collectionIdentifier)
        }

        cell.contentView.backgroundColor = brick.backgroundColor

        //  http://stackoverflow.com/questions/23059811/is-uicollectionview-backgroundview-broken
        cell.brickBackgroundView = brick.backgroundView
        
        return cell
    }
}

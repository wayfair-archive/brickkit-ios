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
open class BrickCollectionView: UICollectionView {

    // MARK: - Public Properties

    /// Static reference to initialize all images that need to be downloaded
    open static var imageDownloader: ImageDownloader = NSURLSessionImageDownloader()

    /// Keep track of index paths that we may need to prefetch attributes for
    open var prefetchAttributeIndexPaths: [Int : [IndexPath]] = [:]

    /// The brick layout
    open var layout: BrickFlowLayout {
        guard let flowlayout = collectionViewLayout as? BrickFlowLayout else {
            fatalError("collectionViewLayout is not BrickFlowLayout, is \(type(of: collectionViewLayout))")
        }
        return flowlayout
    }

    /// Override to check if the layout is a BrickLayout
    open override var collectionViewLayout: UICollectionViewLayout {
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
    open fileprivate(set) var section: BrickSection = BrickSection(bricks: []) {
        didSet {
            self.registerBricks(for: section, nibIdentifiers: section.nibIdentifiers)
            self.registerBricks(for: section, classIdentifiers: section.classIdentifiers)
            section.invalidateCounts(in: collectionInfo)
            self.reloadData()
        }
    }

    /// Dictionary to keep track of what identifier to load for a certain brick
    internal fileprivate(set) var registeredBricks: [String:String] = [:]

    internal fileprivate(set) var isConfiguringCollectionBrick: Bool = false

    internal fileprivate(set) var sectionsWithInsertion: [Int] = []

    // MARK: - Overrides

    open override var frame: CGRect {
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

    fileprivate func initializeComponents() {
        autoreleasepool { // Setting the dataSource will result in not releasing the BrickCollectionView even when its being set to nil
            self.dataSource = self
        }
        layout.dataSource = self
        register(BrickSectionCell.self, forCellWithReuseIdentifier: BrickSection.nibName)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if layout.isDirty {
            self.layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .updateDirtyBricks))
        }
    }
    
    // MARK: - Setting up the models

    /// Sets the section for the BrickCollectionView
    ///
    /// - parameter section: Section to set
    open func setSection(_ section: BrickSection, offset: CGPoint = .zero) {
        self.contentOffset = offset
        self.section = section
    }

    open func brick(at indexPath: IndexPath) -> Brick {
        _ = self.section.invalidateIfNeeded(in: collectionInfo)
        guard let brick = section.brick(at: indexPath, in: collectionInfo) else {
            fatalError("Brick not found at indexPath: SECTION - \(indexPath.section) - ITEM: \(indexPath.item). This should never happen")
        }
        return brick
    }

    open func indexPathsForVisibleBricksWithIdentifier(_ identifier: String, index: Int? = nil) -> [IndexPath] {
        let cells = self.visibleCells.filter { (cell) -> Bool in
            let brickCell = cell as! BaseBrickCell // It's ok to force unwrap because BrickKit only uses BaseBrickCell
            if brickCell._brick.identifier == identifier {
                if let index = index {
                    return brickCell.index == index
                }
                return true
            } else {
                return false
            }
        }
        return cells.flatMap({ (cell) -> IndexPath? in
            return self.indexPath(for: cell)
        })
    }

    open func indexPathsForBricksWithIdentifier(_ identifier: String, index: Int? = nil) -> [IndexPath] {
        var attributes = indexPathsForVisibleBricksWithIdentifier(identifier, index: index)
        if attributes.isEmpty {
            attributes = self.section.indexPathsForBricksWithIdentifier(identifier, index: index, in: collectionInfo)
        }
        return attributes
    }

    /// Register a brick class.
    /// If there is a class (`cellClass`) registered to this Brick, this will be registered to the UICollectionView.
    /// If there is no class, the nib (`nibName`) will be used to register
    ///
    /// - parameter brickClass: The brick class to register
    /// - parameter nib: The nib to register. This only needs to be set if the nib is different then the default
    open func registerBrickClass(_ brickClass: Brick.Type, nib: UINib? = nil) {
        let identifier = brickClass.internalIdentifier
        let cellIdentifier: String

        if let nib = nib {
            cellIdentifier = String(nib.hashValue)
            self.register(nib, forCellWithReuseIdentifier: cellIdentifier)
        } else if let cellClass = brickClass.cellClass {
            cellIdentifier = identifier
            self.register(cellClass, forCellWithReuseIdentifier: cellIdentifier)
        } else if brickClass.bundle.path(forResource: brickClass.nibName, ofType: "nib") != nil {
            let brickNib: UINib = UINib(nibName: brickClass.nibName, bundle: brickClass.bundle)
            cellIdentifier = String(brickNib.hashValue)
            self.register(brickNib, forCellWithReuseIdentifier: cellIdentifier)
        } else {
            fatalError("Nib or cell class not found")
        }

        if isConfiguringCollectionBrick {
            BrickLogger.logWarning("calling `registerBrickClass` in `configure(for cell: CollectionBrickCell)` is deprecated. Use `registerBricks(for cell: CollectionBrickCell)` or `CollectionBrickCell(brickTypes: [Brick.Type])`. This will be a fatalError in a future release")
        }

        registeredBricks[identifier] = cellIdentifier
    }

    /// Register a nib for a brick.
    /// - parameter nib: The nib to use
    /// - parameter identifier: The identifier of the brick
    open func registerNib(_ nib: UINib, forBrickWithIdentifier identifier: String) {
        let cellIdentifier = String(nib.hashValue)
        self.register(nib, forCellWithReuseIdentifier: cellIdentifier)

        if isConfiguringCollectionBrick {
            BrickLogger.logWarning("calling `registerNib` in `configure(for cell: CollectionBrickCell)` is deprecated. Use `registerBricks(for cell: CollectionBrickCell)`. This will be a fatalError in a future release")
        }

        registeredBricks[CustomNibPrefix + identifier] = cellIdentifier
    }

    /// Get the brick, index and collection index of a certain indexPath
    ///
    /// - parameter indexPath: IndexPath
    ///
    /// - returns: BrickInfo
    open func brickInfo(at indexPath: IndexPath) -> BrickInfo {
        guard let brickAndIndex = section.brickAndIndex(atIndexPath: indexPath, in: collectionInfo) else {
            fatalError("Brick and index not found at indexPath: SECTION - \(indexPath.section) - ITEM: \(indexPath.item). This should never happen")
        }
        return (brickAndIndex.0, brickAndIndex.1, collectionInfo.index, collectionInfo.identifier)
    }

    // MARK: - Internal methods

    internal func resetRegisteredBricks() {
        registeredBricks = [:]
    }

    internal func identifier(for brick: Brick) -> String? {
        let identifier: String

        if let brickIdentifier = registeredBricks[brick.identifier] {
            return brickIdentifier
        }

        if brick is BrickSection {
            //Safeguard to never load the wrong nib for a BrickSection,
            //eventhough the identifier is actually in the registeredNibs
            identifier = BrickSection.nibName
        } else if let brickIdentifier = registeredBricks[CustomNibPrefix + brick.identifier] {
            identifier = brickIdentifier
        } else if let brickIdentifier = registeredBricks[type(of: brick).internalIdentifier] {
            identifier = brickIdentifier
        } else {
            return nil
        }
        return identifier
    }

    // MARK: - Invalidation

    /// Invalidate the layout properties and recalculate sizes
    ///
    /// - paramter reloadSections: A flag that indicates if the sections need to be reloaded
    /// - parameter completion: A completion handler block to execute when all of the operations are finished. This block takes a single Boolean parameter that contains the value true if all of the related animations completed successfully or false if they were interrupted. This parameter may be nil.
    open func invalidateBricks(_ reloadSections: Bool = true, completion: ((Bool) -> Void)? = nil) {
        _ = self.invalidateRepeatCountsWithoutPerformBatchUpdates(reloadSections)
        self.performBatchUpdates({
            if reloadSections {
                self.reloadSections(IndexSet(integersIn: 0..<self.numberOfSections))
            }
        }, completion: completion)
    }

    /// Invalidate the visibility
    ///
    /// - parameter completion: A completion handler block to execute when all of the operations are finished. This block takes a single Boolean parameter that contains the value true if all of the related animations completed successfully or false if they were interrupted. This parameter may be nil.
    open func invalidateVisibility(_ completion: ((Bool) -> Void)? = nil) {
        self.performBatchUpdates({
            self.collectionViewLayout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .updateVisibility))
        }, completion: completion)
    }

    open override func reloadData() {
        BrickLogger.logVerbose("Reloading all data.")
        super.reloadData()
    }

    open override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        BrickLogger.logVerbose("Will perform batch updates.")
        super.performBatchUpdates(updates, completion: { completed in
            BrickLogger.logVerbose("Did finish perform batch updates.")
            completion?(completed)
        })
    }

    // MARK: - Private methods

    /// Invalidate the layout for bounds change
    fileprivate func invalidateOnBoundsChange() {
        if collectionViewLayout.shouldInvalidateLayout(forBoundsChange: bounds) {
            self.collectionViewLayout.invalidateLayout(with: self.collectionViewLayout.invalidationContext(forBoundsChange: self.bounds))
        }
    }

    // MARK: - Reloading

    /// Reload bricks in a collectionbrick
    ///
    /// - parameter identifiers:               Identifiers
    /// - parameter collectionBrickIdentifier: CollectionBrick identifier
    /// - parameter index:                     CollectionBrick Index
    open func reloadBricksWithIdentifiers(_ identifiers: [String], inCollectionBrickWithIdentifier collectionBrickIdentifier: String, andIndex index: Int? = nil) {
        let indexPaths = section.indexPathsForBricksWithIdentifier(collectionBrickIdentifier, index: index, in: collectionInfo)

        for indexPath in indexPaths {
            //Reload the brick cell itself
            guard let brickCell = cellForItem(at: indexPath) as? CollectionBrickCell else {
                return
            }

            brickCell.brickCollectionView.reloadBricksWithIdentifiers(identifiers)
        }
    }

    /// Reload one brick at a certain index
    ///
    /// - parameter invalidate: Flag that indicates if the function should also invalidate the layout
    /// Default to true, but could be set to false if it's part of a bigger invalidation
    open func reloadBrickWithIdentifier(_ identifier: String, andIndex index: Int, invalidate: Bool = true) {
        BrickLogger.logVerbose("Reload brick with identifier: \(identifier)")
        let indexPaths = section.indexPathsForBricksWithIdentifier(identifier, index: index, in: collectionInfo)
        self.reloadItems(at: indexPaths)

        if invalidate {
            let context = UICollectionViewLayoutInvalidationContext()
            context.invalidateItems(at: indexPaths)
            self.collectionViewLayout.invalidateLayout(with: context)
        }
    }

    fileprivate func updateIndiciesForVisibleBrickCellsWithIdentifier(identifier: String) {
        let visibleIndexPaths = self.indexPathsForVisibleBricksWithIdentifier(identifier)

        for indexPath in visibleIndexPaths {
            let brickIndex = self.brickInfo(at: indexPath).index

            if let brickCell = self.cellForItem(at: indexPath) as? BaseBrickCell {
                brickCell.setIndex(index: brickIndex)
            }
        }
    }

    fileprivate func updateItems(at index: Int, for identifier: String, itemCount: Int, updateAction: @escaping (_ indexPaths: [IndexPath]) -> Void, completion: ((_ completed: Bool, _ indexPaths: [IndexPath]) -> Void)? = nil) {
        BrickLogger.logVerbose("Update items for identifier: \(identifier)")
        guard let originIndexPath = indexPathsForBricksWithIdentifier(identifier, index: index).first else {
            invalidateRepeatCounts()
            return
        }

        var indexPaths: [IndexPath] = []
        for i in 0..<itemCount {
            indexPaths.append(IndexPath(item: originIndexPath.item + i, section: originIndexPath.section))
        }

        self.performBatchUpdates({
            self.section.invalidateCounts(in: self.collectionInfo)

            updateAction(indexPaths)
        }) { [weak self] (completed) in

            self?.updateIndiciesForVisibleBrickCellsWithIdentifier(identifier: identifier)
            completion?(completed, indexPaths)
        }
    }

    /// Insert items at a given index for a brick identifier
    ///
    /// - parameter index: Index where items will be inserted
    /// - parameter identifier: Brick identifier where items will be inserted
    /// - parameter itemCount: Amount of items being inserted
    /// - parameter completion: Completion Block
    open func insertItems(at index: Int, for identifier: String, itemCount: Int, completion: ((_ completed: Bool, _ insertedIndexPaths: [IndexPath]) -> Void)? = nil) {
        updateItems(at: index, for: identifier, itemCount: itemCount, updateAction: { [weak self] insertedIndexPaths in
            guard let lastIndexPath = insertedIndexPaths.last else {
                return
            }

            // Update any index paths that are offset by the insertion action
            // `insertItemsAtIndexPaths`. We check to make sure we aren't calculating
            // downstream attributes for index paths that otherwise wouldn't exist
            // by checking the number of items in section
            let lastItem = lastIndexPath.item
            let section = lastIndexPath.section

            self?.sectionsWithInsertion.append(section)

            var offsetIndexPaths: [IndexPath] = []

            for offset in 1...insertedIndexPaths.count {
                let offsetIndexPath = IndexPath(item: lastItem + offset, section: section)
                offsetIndexPaths.append(offsetIndexPath)
            }

            var extraIndexPaths: [IndexPath] = []

            if let lastOffsetIndexPath = offsetIndexPaths.last {
                extraIndexPaths = self?.calculateRemainingIndicies(for: lastIndexPath, and: lastOffsetIndexPath, itemCount: itemCount) ?? []
            }

            self?.prefetchAttributeIndexPaths[section] = insertedIndexPaths + offsetIndexPaths + extraIndexPaths

            if !insertedIndexPaths.isEmpty {
                self?.insertItems(at: insertedIndexPaths)
            }
        }, completion: completion)
    }

    /// Calculate how many extra index paths we would need to prefetch attributes for
    /// This mainly pertains to iPad where we need to calculate the last items in the row
    /// When there could be many items in the row. We want to use the item number in the
    /// last index path
    fileprivate func calculateRemainingIndicies(for lastIndexPath: IndexPath, and lastOffsetIndexPath: IndexPath, itemCount: Int) -> [IndexPath] {
        let brick = self.brick(at: lastIndexPath)
        let section = lastIndexPath.section

        if brick.width.isRatio() {
            // Determine how many items are in each row
            let numberOfItemsInRow = 1 / BrickDimension._rawValue(for: 1, startingAt: 0, with: brick.width.dimension())

            // Check how many rows then use that number to determine number of items
            // there will be with complete rows. Once we have this number we can just
            // subtract the item number from this number giving us how many extra indicies
            // need to be calculated to complete the row
            let row = ceil(CGFloat(lastOffsetIndexPath.item + 1) / numberOfItemsInRow)
            let numberOfExtraIndiciesNeeded = (Int(row * numberOfItemsInRow) - 1) - lastOffsetIndexPath.item

            guard numberOfExtraIndiciesNeeded > 0 else {
                return []
            }

            var offsetIndexPaths: [IndexPath] = []
            let numberOfItemsInSection = self.numberOfItems(inSection: section) + itemCount

            for offset in 1...numberOfExtraIndiciesNeeded where offset + lastOffsetIndexPath.item < numberOfItemsInSection {
                let offsetIndexPath = IndexPath(item: lastOffsetIndexPath.item + offset, section: lastOffsetIndexPath.section)
                offsetIndexPaths.append(offsetIndexPath)
            }
            
            return offsetIndexPaths
        }
        return []
    }

    /// Delete items at a given index for a brick identifier
    ///
    /// - parameter index: Index where items will be deleted
    /// - parameter identifier: Brick identifier where items will be deleted
    /// - parameter itemCount: Amount of items being deleted
    /// - parameter completion: Completion Block
    open func deleteItems(at index: Int, for identifier: String, itemCount: Int, completion: ((_ completed: Bool, _ deletedIndexPaths: [IndexPath]) -> Void)? = nil) {
        updateItems(at: index, for: identifier, itemCount: itemCount, updateAction: { deletedIndexPaths in
            if !deletedIndexPaths.isEmpty {
                self.deleteItems(at: deletedIndexPaths)
            }
        }, completion: completion)
    }

    /// Invalidate all the repeat counts of the given
    ///
    /// - parameter completion: Completion Block
    open func invalidateRepeatCounts(reloadAllSections: Bool = false, completion: ((_ completed: Bool, _ insertedIndexPaths: [IndexPath], _ deletedIndexPaths: [IndexPath]) -> Void)? = nil) {
        BrickLogger.logVerbose("Invalidate repeat counts.\(reloadAllSections ? " Reloading all sections." : ""))")
        var insertedIndexPaths: [IndexPath]!
        var deletedIndexPaths: [IndexPath]!

        self.performBatchUpdates({
            let result = self.invalidateRepeatCountsWithoutPerformBatchUpdates(reloadAllSections)
            insertedIndexPaths = result.insertedIndexPaths
            deletedIndexPaths = result.deletedIndexPaths
            }) { (completed) in
                completion?(completed, insertedIndexPaths, deletedIndexPaths)
        }
    }

    fileprivate func clearPrefetchAttributes() {
        for section in sectionsWithInsertion {
            self.prefetchAttributeIndexPaths[section]?.removeAll()
        }
    }

    fileprivate func invalidateRepeatCountsWithoutPerformBatchUpdates(_ reloadAllSections: Bool) -> (insertedIndexPaths: [IndexPath], deletedIndexPaths: [IndexPath]) {

        let brickSection = self.section

        clearPrefetchAttributes()

        var insertedIndexPaths = [IndexPath]()
        var deletedIndexPaths = [IndexPath]()
        var reloadIndexPaths = [IndexPath]()
        let sectionsToReload = NSMutableIndexSet()

        let oldCounts = brickSection.currentSectionCounts(in: self.collectionInfo)
        brickSection.invalidateCounts(in: self.collectionInfo)
        let newCounts = brickSection.currentSectionCounts(in: self.collectionInfo)

        for (section, oldCount) in oldCounts {
            let newCount = newCounts[section]! //We can unwrap safely, because the indexes should always be the same

            let sameCount = newCount == oldCount
            if reloadAllSections {
                sectionsToReload.add(section)
            }

            if sameCount {
                continue
            }

            let countDiff = newCount - oldCount

            let removed = countDiff < 0
            var indexPaths: [IndexPath] = []

            var currentCount = newCount
            if removed {
                currentCount += abs(countDiff)
            }

            for i in 0..<abs(countDiff) {
                let indexPath = IndexPath(item: (currentCount - i - 1), section: section)
                indexPaths.append(indexPath)
            }

            if removed {
                deletedIndexPaths.append(contentsOf: indexPaths)
            } else {
                insertedIndexPaths.append(contentsOf: indexPaths)
            }

            if let sectionIndexPath = brickSection.indexPathFor(section, in: self.collectionInfo) {
                reloadIndexPaths.append(sectionIndexPath)
            }
        }

        if !insertedIndexPaths.isEmpty {
            self.insertItems(at: insertedIndexPaths)
        }

        if !deletedIndexPaths.isEmpty {
            self.deleteItems(at: deletedIndexPaths)
        }

        if !reloadIndexPaths.isEmpty {
            self.reloadItems(at: reloadIndexPaths)
        }

        if sectionsToReload.count > 0 {
            self.reloadSections(sectionsToReload as IndexSet)
        }

        return (insertedIndexPaths, deletedIndexPaths)
    }

    /// Reload the bricks that have the given identifiers
    ///
    /// - parameter identifiers:      Brick Identifiers
    /// - parameter shouldReloadCell: If true, the `reloadItemAtIndexPath` will be called. If false, just the `reloadContent` of the brick will be called
    /// - parameter completion:       A completion handler block to execute when all of the operations are finished. This block takes a single Boolean parameter that contains the value true if all of the related animations completed successfully or false if they were interrupted. This parameter may be nil.
    open func reloadBricksWithIdentifiers(_ identifiers: [String], shouldReloadCell: Bool = false, completion: ((Bool) -> Void)? = nil) {
        if shouldReloadCell {
            self.performBatchUpdates({
                self._reloadBricksWithIdentifiers(identifiers, shouldReloadCell: shouldReloadCell)
            }, completion: completion)
        } else {
            self._reloadBricksWithIdentifiers(identifiers, shouldReloadCell: shouldReloadCell)
            completion?(true)
        }
    }

    fileprivate func _reloadBricksWithIdentifiers(_ identifiers: [String], shouldReloadCell: Bool) {
        var insertedIndexPaths = [IndexPath]()
        var removedIndexPaths = [IndexPath]()
        var reloadIndexPaths = [IndexPath]()
        let sectionsToReload = NSMutableIndexSet()
        BrickLogger.logVerbose("Reload Bricks with identifiers: \(identifiers).")
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
                } else if let brickCell = self.cellForItem(at: indexPath) as? BrickCell {
                    brickCell.reloadContent()
                }
            }
        }

        if !insertedIndexPaths.isEmpty {
            self.insertItems(at: insertedIndexPaths)
        }

        if !removedIndexPaths.isEmpty {
            self.deleteItems(at: removedIndexPaths)
        }

        if !reloadIndexPaths.isEmpty {
            self.reloadItems(at: reloadIndexPaths)
        }

        if sectionsToReload.count > 0 {
            self.reloadSections(sectionsToReload as IndexSet)
        }
    }

    fileprivate func reloadBrickSection(_ brickSection: BrickSection, insertedIndexPaths: inout [IndexPath], removedIndexPaths: inout [IndexPath], sectionsToReload: NSMutableIndexSet) {
        BrickLogger.logVerbose("Reload brick section: \(brickSection.identifier)")
        let updatedSections = reloadSectionWithIdentifier(brickSection.identifier)

        for (section, count) in updatedSections {
            let removed = count < 0
            var indexPaths:[IndexPath] = []

            var currentCount = self.collectionView(self, numberOfItemsInSection: section)
            if removed {
                currentCount += abs(count)
            }

            for i in 0..<abs(count) {
                indexPaths.append(IndexPath(item: (currentCount - i - 1), section: section))
            }

            if removed {
                removedIndexPaths.append(contentsOf: indexPaths)
            } else {
                insertedIndexPaths.append(contentsOf: indexPaths)
            }
            sectionsToReload.add(section)
        }
    }

    /// Reload sections with identifiers
    ///
    /// - parameter identifier: identifier
    ///
    /// - returns: A dictionary with the section as the key and the value is the change count
    fileprivate func reloadSectionWithIdentifier(_ identifier: String) -> [Int: Int] {
        let oldCounts = self.section.currentSectionCounts(in: collectionInfo)
        
        if let matchingIndex = self.indexPathsForBricksWithIdentifier(identifier).first,
            let brickSectionCell = cellForItem(at: matchingIndex) as? BrickSectionCell,
            let brickSection = brickSectionCell._brick as? BrickSection {
                
            brickSection.invalidateCounts(in: collectionInfo)
        }

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

    internal func beginConfiguration(_ action: (() -> Void)) {
        isConfiguringCollectionBrick = true
        action()
        isConfiguringCollectionBrick = false
    }

    /// Register the bricks in a section
    private func registerBricks(for section: BrickSection, nibIdentifiers: [String: UINib]?) {
        section.brickCollectionView = self
        for brick in section.bricks {
            if let brickSection = brick as? BrickSection {
                registerBricks(for: brickSection, nibIdentifiers: brickSection.nibIdentifiers ?? nibIdentifiers)
            } else if !isBrickRegistered(brick: brick) {
                if let nib = nibIdentifiers?[brick.identifier] {
                    self.registerNib(nib, forBrickWithIdentifier: brick.identifier)
                } else  {
                    self.registerBrickClass(type(of: brick))
                }
            }
        }
    }

    private func registerBricks(for section: BrickSection, classIdentifiers: [String: AnyClass]?) {
        section.brickCollectionView = self
        for brick in section.bricks {
            if let brickSection = brick as? BrickSection {
                registerBricks(for: brickSection, classIdentifiers: brickSection.classIdentifiers ?? classIdentifiers)
            } else {
                if let cellClass = classIdentifiers?[brick.identifier] {
                    self.register(cellClass, forCellWithReuseIdentifier: brick.identifier)
                    registeredBricks[brick.identifier] = brick.identifier
                }
            }
        }
    }

    private func isBrickRegistered(brick: Brick) -> Bool {
        return identifier(for: brick) != nil
    }

    open override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        super.setContentOffset(contentOffset, animated: animated)
        self.layoutIfNeeded()
    }
}

extension BrickCollectionView: AsynchronousResizableDelegate {

    public func performResize(cell: BrickCell, completion: (() -> Void)?) {
        assert(Thread.isMainThread)
        guard let indexPath = self.indexPath(for: cell) else {
            // If the cell is offscreen, we can force the height by setting the frame
            let height = cell.heightForBrickView(withWidth: cell.frame.width)
            if height != cell.frame.height {
                cell.frame = CGRect(origin: cell.frame.origin, size: CGSize(width: cell.frame.size.width, height: height))
                self.collectionViewLayout.invalidateLayout()
            }
            completion?()
            return
        }
        let newHeight = cell.heightForBrickView(withWidth: cell.frame.width)
        weak var weakLayout = self.layout
        self.performBatchUpdates({
            weakLayout?.updateHeight(indexPath, newHeight: newHeight)
        }, completion: { completed in
            // we create a strong reference to self here so that self is not accidentally deallocated while an update is in flight
            let _ = self
            completion?()
        })
    }
}


// MARK: - UICollectionViewDataSource
extension BrickCollectionView: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.section.numberOfSections(in: collectionInfo)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.section.numberOfItems(in: section, in: collectionInfo)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        assert(collectionView == self, "This UICollectionViewDataSource must use it's own BrickCollectionView instance")
        guard let brickCollectionView = collectionView as? BrickCollectionView else {
            fatalError("Only BrickCollectionViews are supported")
        }

        let info = brickCollectionView.brickInfo(at: indexPath)
        let brick = info.brick
        guard let identifier = brickCollectionView.identifier(for: brick) else {
            fatalError("No Nib Found for \(brick)")
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! BaseBrickCell

        if let brickCell = cell as? BrickCell {
            if let resizable = brickCell as? AsynchronousResizableCell {
                resizable.resizeDelegate = self
            }

            if var downloadable = brickCell as? ImageDownloaderCell {
                downloadable.imageDownloader = BrickCollectionView.imageDownloader
            }
        }

        cell.setContent(brick, index: info.index, collectionIndex: info.collectionIndex, collectionIdentifier: info.collectionIdentifier)
        cell.contentView.backgroundColor = brick.backgroundColor

        //  http://stackoverflow.com/questions/23059811/is-uicollectionview-backgroundview-broken
        cell.brickBackgroundView = brick.backgroundView
        
        return cell
    }
}

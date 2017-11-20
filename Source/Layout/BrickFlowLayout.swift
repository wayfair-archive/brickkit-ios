//
//  BrickFlowLayout.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 8/29/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}



/// BrickFlowLayoutiis a UICollectionViewLayout that    can handle behaviors
open class BrickFlowLayout: UICollectionViewLayout, BrickLayout {

    var isDirty: Bool {
        get {
            return !dirtyMap.isEmpty
        }
        set {
            if !newValue {
                dirtyMap.removeAll()
                dirtyIndexPaths.removeAll()
            }
        }
    }
    var dirtyMap: [Int: Int] = [:]
    var dirtyIndexPaths: [IndexPath] = []

    // Mark: - Public members

    open override var description: String {
        return super.description + " CollectionBrick: \(isInCollectionBrick)"
    }

    internal var isInCollectionBrick: Bool {
        return collectionView?.superview?.superview is CollectionBrickCell
    }

    open var behaviors: Set<BrickLayoutBehavior> = [] {
        didSet {
            for behavior in behaviors {
                behavior.brickFlowLayout = self
            }
        }
    }

    /// DataSource used to calculate the layout
    open weak var dataSource: BrickLayoutDataSource?

    /// Delegate that is informed when events happen
    open weak var delegate: BrickLayoutDelegate?

    /// Scroll Direction
    open var scrollDirection: UICollectionViewScrollDirection = .vertical

    /// ZIndexBehavior
    open var zIndexBehavior: BrickLayoutZIndexBehavior = .topDown

    /// Hide Behavior
    open weak var hideBehaviorDataSource: HideBehaviorDataSource?

    /// Appear Behavior
    open var appearBehavior: BrickAppearBehavior?

    /// Width Ratio
    open var widthRatio: CGFloat = 1

    // Mark: - Private members

    /// Content width that was used to calculate the layout
    fileprivate var contentWidth: CGFloat?

    /// Last contentOffset used for invalidation
    fileprivate var contentOffset: CGPoint = .zero

    /// Content Size for the collectionView
    open fileprivate(set) var contentSize = CGSize() // Content size of the layout.

    /// Maximum ZIndex
    open var maxZIndex: Int {
        return zIndexer.maxZIndex
    }

    /// Unwrapped collectionView. This should only be called in a context where the collectionView is set
    fileprivate var _collectionView: UICollectionView {
        guard let unwrappedCollectionView = self.collectionView else {
            fatalError("`collectionView` should be set when calling a function to the layout")
        }
        return unwrappedCollectionView
    }

    /// Unwrapped collectionView. This should only be called in a context where the collectionView is set
    fileprivate var _dataSource: BrickLayoutDataSource {
        guard let unwrappedDataSource = self.dataSource else {
            fatalError("`dataSource` should be set when calling a function to the layout")
        }
        return unwrappedDataSource
    }

    /// Flag that indicates that the
    fileprivate var isCalculating = false

    /// Sections
    internal fileprivate(set) var sections: [Int: BrickLayoutSection]?

    /// IndexPaths being added
    var insertedIndexPaths: [IndexPath] = []

    /// IndexPaths being deleted
    var deletedIndexPaths: [IndexPath] = []

    /// IndexPaths being reloaded
    var reloadIndexPaths: [IndexPath] = []

    /// Frame that is currently of interest for calculating
    var frameOfInterest: CGRect = .zero

    /// Object that is keeps track of the ZIndexes of the layout
    lazy var zIndexer: BrickZIndexer = BrickZIndexer()

    /// Calculate the sections that are needed.
    ///
    /// - Parameter rect: currently visisble rect
    /// - Returns: the sections
    internal func calculateSectionsIfNeeded(_ rect: CGRect) -> [Int: BrickLayoutSection] {
        isCalculating = true

        let oldRect = frameOfInterest
        frameOfInterest = CGRect(x: 0, y: 0, width: rect.maxX, height: rect.maxY)

        if let sections = sections {

            //Only continue calculating if the new frame of interest is further than the old frame
            let shouldContinueCalculating = scrollDirection == .vertical ? oldRect.maxY < frameOfInterest.maxY : oldRect.maxX < frameOfInterest.maxX

            if shouldContinueCalculating {
                let currentSections = sections.values
                let updateAttributes: OnAttributesUpdatedHandler = { attributes, oldFrame in
                }

                var updated = false
                for section in currentSections {
                    // For deletion cases, we don't want to recalculate brick layaout sections for indexes
                    // that no longer exist in the collection view.
                    let sectionCount = _collectionView.numberOfItems(inSection: section.sectionIndex)
                    updateSection(section, updatedAttributes: updateAttributes, action: {
                        if section.numberOfItems <= sectionCount {
                            updated = section.continueCalculatingCells() || updated
                        }
                    })
                }

                if updated { // Invalidate the behaviors
                    _ = BrickLayoutInvalidationContext(type: .scrolling).invalidateWithLayout(self)
                }
            }
        } else {
            _ = BrickLayoutInvalidationContext(type: .creation).invalidateWithLayout(self)
        }

        isCalculating = false
        return sections!
    }

    /// Actually calculate sections
    internal func calculateSections() {
        zIndexer.reset(for: self)
        sections = [:]

        if self.contentWidth == nil {
            self.contentWidth = _collectionView.frame.width
        }

        self.contentSize.width = self.contentWidth!

        self.calculateDownStreamIndexPaths()

        if _collectionView.numberOfSections > 0 {
            calculateSection(for: 0, with: nil, containedInWidth: self.contentSize.width, at: CGPoint.zero)
        }
    }

    /// Array that keeps track of indexPaths that need downstream calculation
    var downStreamBehaviorIndexPaths: [Int: [IndexPath]] = [:]

    internal func calculateDownStreamIndexPaths() {
        downStreamBehaviorIndexPaths = [:]

        let downstreamBehaviors = self.behaviors.filter { $0.needsDownstreamCalculation }
        if !downstreamBehaviors.isEmpty {
            // This is an expensive operation, so only execute when needed
            for section in 0..<_collectionView.numberOfSections {
                var downstreamIndexPaths = [IndexPath]()
                for item in 0..<_collectionView.numberOfItems(inSection: section) {
                    let indexPath = IndexPath(item: item, section: section)
                    let identifier = _dataSource.brickLayout(self, identifierFor: indexPath)
                    for behavior in downstreamBehaviors {
                        if behavior.shouldUseForDownstreamCalculation(for: indexPath, with: identifier, for: self) {
                            downstreamIndexPaths.append(indexPath)
                        }
                    }
                }
                if !downstreamIndexPaths.isEmpty {
                    downStreamBehaviorIndexPaths[section] = downstreamIndexPaths
                }
            }
        }

    }

    internal func calculateSection(for sectionIndex: Int, with sectionAttributes: BrickLayoutAttributes?, containedInWidth width: CGFloat, at origin: CGPoint) {
        guard _collectionView.numberOfSections > sectionIndex else {
            fatalError("The section is not found")
        }
        let section = BrickLayoutSection(sectionIndex: sectionIndex, sectionAttributes: sectionAttributes, numberOfItems: _collectionView.numberOfItems(inSection: sectionIndex), origin: origin, sectionWidth: width, dataSource: self, delegate: self)
        section.invalidateAttributes { (attributes, oldFrame) in
        }
        sections?[sectionIndex] = section
    }

    internal func updateNumberOfItemsInSection(_ section: Int, numberOfItems: Int, updatedAttributes: @escaping OnAttributesUpdatedHandler) {
        guard let brickSection = sections?[section] else {
            return
        }

        if let indexPath = dataSource?.brickLayout(self, indexPathFor: section) {
            brickSection.sectionAttributes = self.layoutAttributesForItem(at: indexPath) as? BrickLayoutAttributes
        }

        let height = brickSection.frame.height

        guard let indexPath = dataSource?.brickLayout(self, indexPathFor: section) else {
            return
        }

        if brickSection.frame.height != height {
            updateHeight(for: indexPath, with: brickSection.frame.height, updatedAttributes: updatedAttributes)
        }
    }

    internal func updateHeight(_ indexPath: IndexPath, newHeight: CGFloat) {
        if _dataSource.brickLayout(self, isEstimatedHeightFor: indexPath) {
            let context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: indexPath, newHeight: newHeight))
            invalidateLayout(with: context)
        }
    }

}

// MARK: - UICollectionViewLayout
extension BrickFlowLayout {

    open override func prepare() {
        contentSize.width = max(contentSize.width, contentWidth ?? _collectionView.frame.width)
        super.prepare()
    }

    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if newBounds.width != contentWidth {
            return true
        } else if contentOffset != newBounds.origin {
            contentOffset = newBounds.origin
            // Don't want to return true if there are behaviors but no attributes assigned
            // to these behaviors, otherwise the collection view will invalidate every index path.
            return behaviors.contains { $0.hasInvalidatableAttributes() }
        }

        return false
    }

    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        if newBounds.width != contentWidth {
            contentWidth = newBounds.width
            frameOfInterest = newBounds
            return BrickLayoutInvalidationContext(type: .invalidate)
        }
        return BrickLayoutInvalidationContext(type: .scrolling)
    }

    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return BrickLayoutInvalidationContext.targetContentOffsetForProposedContentOffset(proposedContentOffset, withScrollingVelocity: velocity, withBehaviors: behaviors, inCollectionViewLayout: self)
    }

    open override var collectionViewContentSize : CGSize {
        return contentSize
    }

    func updateDirtyBricks(updatedAttributes: @escaping OnAttributesUpdatedHandler) {
        for (section, item) in dirtyMap {
            let layoutSection = sections?[section]
            layoutSection?.createOrUpdateCells(from: item, invalidate: false, updatedAttributes: updatedAttributes)
            if let sectionAttributes = layoutSection?.sectionAttributes {
                invalidateHeight(for: sectionAttributes.indexPath, updatedAttributes: updatedAttributes)
            }
        }

        recalculateContentSize()

        let cachedDirtyIndexPaths = self.dirtyIndexPaths

        isDirty = false

        cachedDirtyIndexPaths.forEach { indexPath in
            delegate?.brickLayout(self, didUpdateHeightForItemAtIndexPath: indexPath)
        }
    }

    open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        BrickLogger.logVerbose("Invalidate layout with context \(context)")
        guard sections != nil else { // No need to invalidate if there are no sections
            super.invalidateLayout(with: context)
            return
        }

        if context.invalidateEverything {
            self.removeAllCachedSections()
        } else if let context = context as? BrickLayoutInvalidationContext {
            _ = context.invalidateWithLayout(self)

            switch context.type {
            case .updateHeight(let indexPath, _): delegate?.brickLayout(self, didUpdateHeightForItemAtIndexPath: indexPath)
            default: break
            }
        } else if !context.invalidateDataSourceCounts {
            invalidateLayout(with: BrickLayoutInvalidationContext(type: .invalidate))
        }

        super.invalidateLayout(with: context)
    }

    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if !isCalculating {
            _ = calculateSectionsIfNeeded(rect)
        }

        guard let sections = self.sections else {
            return nil
        }

        var attributes: [UICollectionViewLayoutAttributes] = []
        for (sectionIndex, section) in sections {
            attributes += section.layoutAttributesForElementsInRect(rect, with: zIndexer, maxIndex: _collectionView.numberOfItems(inSection: sectionIndex) - 1)
        }

        return attributes
    }

    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        if let attributes = sections?[indexPath.section]?.attributes[indexPath.item] {
            attributes.setAutoZIndex(zIndexer.zIndex(for: indexPath))
            return attributes
        } else if indexPath.section < _collectionView.numberOfSections && indexPath.item < _collectionView.numberOfItems(inSection: indexPath.section) {

            // The attributes haven't been calculated because it's is not needed to be displayed yet
            // But `insertItemsAtIndexPaths` and `deleteItemsAtIndexPaths` might be called and the animation controller will need to know where these attributes are
            // So just return BrickAttributes with no values

            let attributes = BrickLayoutAttributes(forCellWith: indexPath)
            attributes.isHidden = true
            attributes.frame = .zero
            attributes.originalFrame = .zero
            attributes.identifier = ""

            return attributes
        }

        return nil
    }

    open override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        guard let brickAttribute = originalAttributes as? BrickLayoutAttributes else {
            return false
        }
        let shouldInvalidate = preferredAttributes.frame.height != brickAttribute.originalFrame.height
        brickAttribute.isEstimateSize = false

        if shouldInvalidate {
            let indexPath = preferredAttributes.indexPath
            sections![indexPath.section]?.update(height: preferredAttributes.frame.height, at: indexPath.item, continueCalculation: false, updatedAttributes: nil)
            if let current = dirtyMap[indexPath.section] {
                if indexPath.item < current {
                    dirtyMap[indexPath.section] = indexPath.item
                }
            } else {
                dirtyMap[indexPath.section] = indexPath.item
            }
            dirtyIndexPaths.append(indexPath)
        }
        return false
    }

    open override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        return BrickLayoutInvalidationContext(type: .updateHeight(indexPath: originalAttributes.indexPath, newHeight: preferredAttributes.frame.size.height))
    }

}

extension BrickFlowLayout: BrickLayoutSectionDelegate {

    func brickLayoutSection(_ section: BrickLayoutSection, didCreateAttributes attributes: BrickLayoutAttributes) {
        for behavior in behaviors {
            behavior.registerAttributes(attributes, for: self)
        }
    }

}

// MARK: - BrickLayoutSectionDataSource
extension BrickFlowLayout: BrickLayoutSectionDataSource {

    func edgeInsets(in section: BrickLayoutSection) -> UIEdgeInsets {
        return _dataSource.brickLayout(self, edgeInsetsFor: section.sectionIndex)
    }

    func inset(in section: BrickLayoutSection) -> CGFloat {
        return _dataSource.brickLayout(self, insetFor: section.sectionIndex)
    }

    func isAlignRowHeights(in section: BrickLayoutSection) -> Bool {
        return _dataSource.brickLayout(self, isAlignRowHeightsFor: section.sectionIndex)
    }

    func aligment(in section: BrickLayoutSection) -> BrickAlignment {
        return _dataSource.brickLayout(self, alignmentFor: section.sectionIndex)
    }

    func identifier(for index: Int, in section: BrickLayoutSection) -> String {
        return _dataSource.brickLayout(self, identifierFor: IndexPath(item: index, section: section.sectionIndex))
    }

    func isEstimate(for attributes: BrickLayoutAttributes, in section: BrickLayoutSection) -> Bool {
        return _dataSource.brickLayout(self, isEstimatedHeightFor: attributes.indexPath)
    }

    func width(for index: Int, totalWidth: CGFloat, startingAt origin: CGFloat, in section: BrickLayoutSection) -> CGFloat {
        let indexPath = IndexPath(item: index, section: section.sectionIndex)
        let width = _dataSource.brickLayout(self, widthForItemAt: indexPath, totalWidth: totalWidth, widthRatio: widthRatio, startingAt: origin)

        return width
    }

    func prepareForSizeCalculation(for attributes: BrickLayoutAttributes, containedIn width: CGFloat, origin: CGPoint, invalidate: Bool, in section: BrickLayoutSection, updatedAttributes: OnAttributesUpdatedHandler?) {
        let indexPath = attributes.indexPath

        attributes.isHidden = shouldHideItemAtIndexPath(shouldHideItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier)

        if let sectionAttributes = section.sectionAttributes , sectionAttributes.isHidden {
            attributes.isHidden = true
        }

        let type = _dataSource.brickLayout(self, brickLayoutTypeForItemAt: indexPath)
        switch type {
        case .brick: break
        case .section(let sectionIndex):
            if let brickSection = sections?[sectionIndex] {
                brickSection.sectionAttributes = attributes

                if brickSection.sectionWidth != width {
                    brickSection.setSectionWidth(width, updatedAttributes: updatedAttributes)
                } else if brickSection.origin.x != origin.x {
                    // Check if the x-origin didn't change (BrickAlignment)
                    // Do not check on y-origin, because that could have been changed by a behavior
                    brickSection.setOrigin(CGPoint(x: origin.x, y: brickSection.origin.y), fromBehaviors: false, updatedAttributes: updatedAttributes)
                } else if invalidate  {
                    brickSection.invalidateAttributes(updatedAttributes)
                }
            } else {
                calculateSection(for: sectionIndex, with: attributes, containedInWidth: width, at: origin)
            }
        }
    }

    func size(for attributes: BrickLayoutAttributes, containedIn width: CGFloat, in section: BrickLayoutSection) -> CGSize {
        let indexPath = attributes.indexPath

        let type = _dataSource.brickLayout(self, brickLayoutTypeForItemAt: indexPath)
        var size: CGSize = .zero
        switch type {
        case .brick:
            // Check if the attributes already had a height. If so, use that height
            if attributes.frame.height != 0 && _dataSource.brickLayout(self, isEstimatedHeightFor: indexPath) {
                let height = attributes.frame.size.height
                size = CGSize(width: width, height: height)
            } else {
                let height = _dataSource.brickLayout(self, estimatedHeightForItemAt: indexPath, containedIn: width)
                size = CGSize(width: width, height: height)
            }
        case .section(let section):
            let height = _dataSource.brickLayout(self, estimatedHeightForItemAt: indexPath, containedIn: width)
            if height == 0 {
                size = sections?[section]?.frame.size ?? .zero
            } else {
                size = CGSize(width: width, height: height)
            }
        }

        return size
    }

    func downStreamIndexPaths(in section: BrickLayoutSection) -> [IndexPath] {
        return downStreamBehaviorIndexPaths[section.sectionIndex] ?? []
    }

    func prefetchIndexPaths(in section: BrickLayoutSection) -> [IndexPath] {
        return _dataSource.brickLayout(self, prefetchAttributeIndexPathsFor: section.sectionIndex)
    }
}

extension BrickFlowLayout: BrickLayoutInvalidationProvider {
    
    func invalidateHeight(for indexPath: IndexPath, updatedAttributes: @escaping OnAttributesUpdatedHandler) {
        guard let section = sections?[indexPath.section] else {
            return
        }

        updateSection(section, updatedAttributes: updatedAttributes) {
            section.invalidate(at: indexPath.item, updatedAttributes: { attributes, oldFrame in
                updatedAttributes(attributes, oldFrame)
                self.attributesWereUpdated(attributes, oldFrame: oldFrame, fromBehaviors: false, updatedAttributes: updatedAttributes)
            })
        }
    }

    @discardableResult
    func updateHeight(for indexPath: IndexPath, with height: CGFloat, updatedAttributes: @escaping OnAttributesUpdatedHandler) -> CGPoint {
        guard let section = sections?[indexPath.section], let firstAttributes = layoutAttributesForItem(at: indexPath) else {
            return .zero
        }

        let shouldAdjustContentOffset = _collectionView.contentOffset.y > firstAttributes.frame.origin.y
        let contentOffsetAdjustment = shouldAdjustContentOffset ? height - firstAttributes.frame.height : 0

        updateSection(section, updatedAttributes: updatedAttributes) {
            section.update(height: height, at: indexPath.item, continueCalculation: true, updatedAttributes: { attributes, oldFrame in
                updatedAttributes(attributes, oldFrame)
                self.attributesWereUpdated(attributes, oldFrame: oldFrame, fromBehaviors: false, updatedAttributes: updatedAttributes)
            })
        }
        return CGPoint(x: 0, y: contentOffsetAdjustment)
    }

    fileprivate func updateSection(_ section: BrickLayoutSection, updatedAttributes: @escaping OnAttributesUpdatedHandler, action: (() -> Void)) {

        let currentFrame = section.frame
        action()

        guard let indexPathFor = dataSource?.brickLayout(self, indexPathFor: section.sectionIndex) else {
            return
        }

        if section.frame.size.height != currentFrame.size.height {
            // If the frame is changed, it's should update the frame of the section above
            updateHeight(for: indexPathFor, with: section.frame.height, updatedAttributes: updatedAttributes)
        }
    }

    func registerUpdatedAttributes(_ attributes: BrickLayoutAttributes, oldFrame: CGRect?, fromBehaviors: Bool, updatedAttributes: @escaping OnAttributesUpdatedHandler) {
        self.sections?[attributes.indexPath.section]?.registerUpdatedAttributes(attributes)

        self.attributesWereUpdated(attributes, oldFrame: oldFrame, fromBehaviors: fromBehaviors, updatedAttributes: { attributes, oldFrame in
            updatedAttributes(attributes, oldFrame)
        })
    }

    func removeAllCachedSections() {
        sections = nil
    }

    func invalidateContent(_ updatedAttributes: @escaping OnAttributesUpdatedHandler) {
        guard let contentWidth = contentWidth else {
            return
        }

        self.contentSize.width = contentWidth

        let onAttributesUpdated: OnAttributesUpdatedHandler = { attributes, oldFrame in
            updatedAttributes(attributes, oldFrame)
        }

        if sections?[0]?.sectionWidth != contentWidth {
            sections?[0]?.setSectionWidth(contentWidth, updatedAttributes: onAttributesUpdated)
        } else {
            sections?[0]?.invalidateAttributes(onAttributesUpdated)
        }
    }

    func updateContentSize(_ contentSize: CGSize) {
        self.contentSize = contentSize
    }

    @discardableResult
    func recalculateContentSize() -> CGSize {
        let oldContentSize = self.contentSize
        contentSize = sections?[0]?.frame.size ?? CGSize.zero
        let difference = CGSize(width: contentSize.width - oldContentSize.width, height: contentSize.height - oldContentSize.height)

        return difference
    }

    public func layoutAttributesForSection(_ section: Int) -> BrickLayoutAttributes? {
        if let indexPath = dataSource?.brickLayout(self, indexPathFor: section) {
            return self.layoutAttributesForItem(at: indexPath) as? BrickLayoutAttributes
        }
        return nil
    }

    fileprivate func attributesWereUpdated(_ attributes: BrickLayoutAttributes, oldFrame: CGRect?, fromBehaviors: Bool, updatedAttributes: @escaping OnAttributesUpdatedHandler) {
        let type = _dataSource.brickLayout(self, brickLayoutTypeForItemAt: attributes.indexPath)
        switch type {
        case .section(let section):
            if let brickSection = self.sections?[section] {
                brickSection.setOrigin(attributes.frame.origin, fromBehaviors: fromBehaviors, updatedAttributes: { attributes, oldFrame in
                    updatedAttributes(attributes, oldFrame)
                    self.attributesWereUpdated(attributes, oldFrame: oldFrame, fromBehaviors: fromBehaviors, updatedAttributes: updatedAttributes)
                })

                // Because attributes could have been added, the frame height might have been changed
                attributes.frame = brickSection.frame
                attributes.originalFrame.size = brickSection.frame.size
            }
        default: break
        }
    }

    internal func applyHideBehavior(updatedAttributes: @escaping OnAttributesUpdatedHandler) {
        guard let firstSection = sections?[0] else {
            return
        }

        applyHideBehaviorForSection(for: firstSection, updatedAttributes: updatedAttributes)
    }

    func shouldHideItemAtIndexPath(shouldHideItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String) -> Bool {
        if _dataSource.brickLayout(self, isItemHiddenAt: indexPath) {
            return true
        }

        if let hideBehaviorDataSource = hideBehaviorDataSource {
            return hideBehaviorDataSource.hideBehaviorDataSource(shouldHideItemAtIndexPath: indexPath, withIdentifier: identifier, inCollectionViewLayout: self)
        }
        return false
    }

    func applyHideBehaviorForSection(for section: BrickLayoutSection, updatedAttributes: @escaping OnAttributesUpdatedHandler) {
        let currentFrame = section.frame

        for attributes in section.attributes.values {
            var shouldHide = shouldHideItemAtIndexPath(shouldHideItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier)

            // If the sectionAttributes are hidden, hide this attribute as well
            if let sectionAttributes = section.sectionAttributes , sectionAttributes.isHidden {
                shouldHide = true
            }

            if shouldHide != attributes.isHidden {
                section.changeVisibility(shouldHide, at: attributes.indexPath.item, updatedAttributes: { attributes, oldFrame in
                    updatedAttributes(attributes, oldFrame)
                })
            }

            let type = _dataSource.brickLayout(self, brickLayoutTypeForItemAt: attributes.indexPath)
            switch type {
            case .section(let sectionIndex):
                if let brickSection = sections?[sectionIndex] {
                    applyHideBehaviorForSection(for: brickSection, updatedAttributes: updatedAttributes)
                }
            default: break
            }
        }


        if section.frame != currentFrame {
            // If the frame is changed, it's should update the frame of the section above
            if let indexPathFor = _dataSource.brickLayout(self, indexPathFor: section.sectionIndex) {
                updateHeight(for: indexPathFor, with: section.frame.height, updatedAttributes: updatedAttributes)
            }
        }

    }

}

extension BrickFlowLayout {
    open override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        insertedIndexPaths = []
        deletedIndexPaths = []
        reloadIndexPaths = []

        for item in updateItems {
            if item.updateAction == .insert {
                if let indexPath = item.indexPathAfterUpdate {
                    insertedIndexPaths.append(indexPath)
                }
            } else if item.updateAction == .delete {
                if let indexPath = item.indexPathBeforeUpdate {
                    deletedIndexPaths.append(indexPath)
                }
            } else if item.updateAction == .reload {
                if let indexPath = item.indexPathBeforeUpdate {
                    reloadIndexPaths.append(indexPath)
                }
            }
        }

        if (insertedIndexPaths.count + deletedIndexPaths.count) > 0 {
            zIndexer.reset(for: self)
            for (sectionIndex, section) in sections! { // OK to force unwrap sections. Without them being initialized, there wouldn't be any insert/delete possible
                let inserted = insertedIndexPaths.filter({ (indexPath) -> Bool in
                    return indexPath.section == sectionIndex
                })

                let deleted = deletedIndexPaths.filter({ (indexPath) -> Bool in
                    return indexPath.section == sectionIndex
                })

                section.updateNumberOfItems(inserted: inserted.map({$0.item}), deleted: deleted.map({$0.item}))
            }
        }

        reloadItems(at: reloadIndexPaths)
        invalidateLayout(with: BrickLayoutInvalidationContext(type: .invalidate))
    }

    fileprivate func reloadItems(at indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.item >= collectionView?.numberOfItems(inSection: indexPath.section)  {
                continue
            }

            switch _dataSource.brickLayout(self, brickLayoutTypeForItemAt: indexPath) {
            case .brick:
                BrickLayoutInvalidationContext(type: .invalidateHeight(indexPath: indexPath)).invalidateWithLayout(self)
            default: break
            }
        }
    }

    open override func finalizeCollectionViewUpdates() { // called inside an animation block after the update

        insertedIndexPaths = []
        deletedIndexPaths = []
        reloadIndexPaths = []
    }


    override open func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        var attributes: BrickLayoutAttributes?
        
        if insertedIndexPaths.contains(itemIndexPath) {
            if let copy = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)?.copy() as? BrickLayoutAttributes {
                appearBehavior?.configureAttributesForAppearing(copy, in: _collectionView)
                attributes = copy
            }
        } else if let copy = self.layoutAttributesForItem(at: itemIndexPath)?.copy() as? BrickLayoutAttributes {
            attributes = copy
        }

        attributes?.setAutoZIndex(zIndexer.zIndex(for: itemIndexPath))

        return attributes
    }
    
    override open func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes: BrickLayoutAttributes?

        if deletedIndexPaths.contains(itemIndexPath) {
            if let copy = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)?.copy() as? BrickLayoutAttributes {
                appearBehavior?.configureAttributesForDisappearing(copy, in: _collectionView)
                attributes = copy
            }
        } else if let copy = self.layoutAttributesForItem(at: itemIndexPath)?.copy() as? BrickLayoutAttributes {
            attributes = copy
        } else {
            attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)?.copy() as? BrickLayoutAttributes
        }

        attributes?.setAutoZIndex(zIndexer.zIndex(for: itemIndexPath))

        return attributes
    }
}


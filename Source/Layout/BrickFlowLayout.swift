//
//  BrickFlowLayout.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 8/29/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit


/// BrickFlowLayoutiis a UICollectionViewLayout that    can handle behaviors
public class BrickFlowLayout: UICollectionViewLayout, BrickLayout {

    // Mark: - Public members

    public override var description: String {
        return super.description + " CollectionBrick: \(isInCollectionBrick)"
    }

    internal var isInCollectionBrick: Bool {
        return collectionView?.superview?.superview is CollectionBrickCell
    }

    public var behaviors: Set<BrickLayoutBehavior> = [] {
        didSet {
            for behavior in behaviors {
                behavior.brickFlowLayout = self
            }
        }
    }

    /// DataSource used to calculate the layout
    public weak var dataSource: BrickLayoutDataSource?

    /// Delegate that is informed when events happen
    public weak var delegate: BrickLayoutDelegate?

    /// Scroll Direction
    public var scrollDirection: UICollectionViewScrollDirection = .Vertical

    /// ZIndexBehavior
    public var zIndexBehavior: BrickLayoutZIndexBehavior = .TopDown

    /// Hide Behavior
    public weak var hideBehaviorDataSource: HideBehaviorDataSource?

    /// Appear Behavior
    public var appearBehavior: BrickAppearBehavior?

    /// Width Ratio
    public var widthRatio: CGFloat = 1

    // Mark: - Private members

    /// Content width that was used to calculate the layout
    private var contentWidth: CGFloat?

    /// Last contentOffset used for invalidation
    private var contentOffset: CGPoint = .zero

    /// Content Size for the collectionView
    public private(set) var contentSize = CGSize() // Content size of the layout.

    /// Maximum ZIndex
    public var maxZIndex: Int {
        return zIndexer.maxZIndex
    }

    /// Unwrapped collectionView. This should only be called in a context where the collectionView is set
    private var _collectionView: UICollectionView {
        guard let unwrappedCollectionView = self.collectionView else {
            fatalError("`collectionView` should be set when calling a function to the layout")
        }
        return unwrappedCollectionView
    }

    /// Unwrapped collectionView. This should only be called in a context where the collectionView is set
    private var _dataSource: BrickLayoutDataSource {
        guard let unwrappedDataSource = self.dataSource else {
            fatalError("`dataSource` should be set when calling a function to the layout")
        }
        return unwrappedDataSource
    }

    /// Flag that indicates that the
    private var isCalculating = false

    /// Sections
    internal private(set) var sections: [Int: BrickLayoutSection]?

    /// Flag to indicate that an update cycle is happening
    var isUpdating: Bool = false

    /// IndexPaths being added
    var insertedIndexPaths: [NSIndexPath] = []

    /// IndexPaths being deleted
    var deletedIndexPaths: [NSIndexPath] = []

    /// IndexPaths being reloaded
    var reloadIndexPaths: [NSIndexPath] = []

    /// Frame that is currently of interest for calculating
    var frameOfInterest: CGRect = .zero

    /// Object that is keeps track of the ZIndexes of the layout
    lazy var zIndexer: BrickZIndexer = BrickZIndexer()

    /// Calculate the sections that are needed.
    ///
    /// - Parameter rect: currently visisble rect
    /// - Returns: the sections
    internal func calculateSectionsIfNeeded(rect: CGRect) -> [Int: BrickLayoutSection] {
        isCalculating = true

        let oldRect = frameOfInterest
        frameOfInterest = CGRect(x: 0, y: 0, width: rect.maxX, height: rect.maxY)

        if let sections = sections {

            //Only continue calculating if the new frame of interest is further than the old frame
            let shouldContinueCalculating = scrollDirection == .Vertical ? oldRect.maxY <= frameOfInterest.maxY : oldRect.maxX <= frameOfInterest.maxX

            if shouldContinueCalculating {
                let currentSections = sections.values
                let updateAttributes: OnAttributesUpdatedHandler = { attributes, oldFrame in
                }

                var updated = false
                for section in currentSections {
                    updateSection(section, updatedAttributes: updateAttributes, action: {
                        updated = updated || section.continueCalculatingCells()
                    })
                }

                if updated { // Invalidate the behaviors
                    BrickLayoutInvalidationContext(type: .Scrolling).invalidateWithLayout(self)
                }
            }
        } else {
            BrickLayoutInvalidationContext(type: .Creation).invalidateWithLayout(self)
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

        if _collectionView.numberOfSections() > 0 {
            calculateSection(for: 0, with: nil, containedInWidth: self.contentSize.width, at: CGPoint.zero)
        }
    }

    /// Array that keeps track of indexPaths that need downstream calculation
    var downStreamBehaviorIndexPaths: [Int: [NSIndexPath]] = [:]

    internal func calculateDownStreamIndexPaths() {
        downStreamBehaviorIndexPaths = [:]

        let downstreamBehaviors = self.behaviors.filter { $0.needsDownstreamCalculation }
        if !downstreamBehaviors.isEmpty {
            // This is an expensive operation, so only execute when needed
            for section in 0..<_collectionView.numberOfSections() {
                var downstreamIndexPaths = [NSIndexPath]()
                for item in 0..<_collectionView.numberOfItemsInSection(section) {
                    let indexPath = NSIndexPath(forItem: item, inSection: section)
                    let identifier = _dataSource.brickLayout(self, identifierForIndexPath: indexPath)
                    for behavior in downstreamBehaviors {
                        if behavior.shouldUseForDownstreamCalculation(for: indexPath, with: identifier, forCollectionViewLayout: self) {
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
        guard _collectionView.numberOfSections() > sectionIndex else {
            fatalError("The section is not found")
        }
        let section = BrickLayoutSection(sectionIndex: sectionIndex, sectionAttributes: sectionAttributes, numberOfItems: _collectionView.numberOfItemsInSection(sectionIndex), origin: origin, sectionWidth: width, dataSource: self, delegate: self)
        section.invalidateAttributes { (attributes, oldFrame) in
        }
        sections?[sectionIndex] = section
    }

    internal func updateNumberOfItems(brickSection: BrickLayoutSection, numberOfItems: Int? = nil) {
        brickSection.setNumberOfItems(numberOfItems ?? _collectionView.numberOfItemsInSection(brickSection.sectionIndex), addedAttributes: { (attributes, oldFrame) in
            }, removedAttributes: { (attributes, oldFrame) in
        })
    }

    internal func updateNumberOfItemsInSection(section: Int, numberOfItems: Int, updatedAttributes: OnAttributesUpdatedHandler) {
        guard let brickSection = sections?[section] else {
            return
        }

        if let indexPath = dataSource?.brickLayout(self, indexPathForSection: section) {
            brickSection.sectionAttributes = self.layoutAttributesForItemAtIndexPath(indexPath) as? BrickLayoutAttributes
        }

        let height = brickSection.frame.height
        self.updateNumberOfItems(brickSection, numberOfItems: numberOfItems)

        guard let indexPath = dataSource?.brickLayout(self, indexPathForSection: section) else {
            return
        }

        if brickSection.frame.height != height {
            updateHeight(for: indexPath, with: brickSection.frame.height, updatedAttributes: updatedAttributes)
        }
    }

    internal func updateHeight(indexPath: NSIndexPath, newHeight: CGFloat) {
        if _dataSource.brickLayout(self, isEstimatedHeightForIndexPath: indexPath) {
            let context = BrickLayoutInvalidationContext(type: .UpdateHeight(indexPath: indexPath, newHeight: newHeight))
            invalidateLayoutWithContext(context)
        }
    }

}

// MARK: - UICollectionViewLayout
extension BrickFlowLayout {

    public override func prepareLayout() {
        contentSize.width = max(contentSize.width, contentWidth ?? _collectionView.frame.width)
        super.prepareLayout()
    }

    public override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        if newBounds.width != contentWidth {
            return true
        } else if contentOffset != newBounds.origin {
            contentOffset = newBounds.origin
            return !behaviors.isEmpty
        }

        return false
    }

    public override func invalidationContextForBoundsChange(newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        if newBounds.width != contentWidth {
            contentWidth = newBounds.width
            frameOfInterest = newBounds
            return BrickLayoutInvalidationContext(type: .Invalidate)
        }
        return BrickLayoutInvalidationContext(type: .Scrolling)
    }

    public override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return BrickLayoutInvalidationContext.targetContentOffsetForProposedContentOffset(proposedContentOffset, withScrollingVelocity: velocity, withBehaviors: behaviors, inCollectionViewLayout: self)
    }

    public override func collectionViewContentSize() -> CGSize {
        return contentSize
    }

    public override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        guard sections != nil else { // No need to invalidate if there are no sections
            super.invalidateLayoutWithContext(context)
            return
        }

        if context.invalidateEverything {
            self.removeAllCachedSections()
        } else if let context = context as? BrickLayoutInvalidationContext {
            context.invalidateWithLayout(self)

            switch context.type {
            case .UpdateHeight(let indexPath, _): delegate?.brickLayout(self, didUpdateHeightForItemAtIndexPath: indexPath)
            default: break
            }
        } else if context.invalidateDataSourceCounts {
            invalidateDataCounts(context)
        } else {
            return
        }

        super.invalidateLayoutWithContext(context)
    }

    func invalidateDataCounts(context: UICollectionViewLayoutInvalidationContext) {
        zIndexer.reset(for: self)

        var changedSections = [Int: Int]()
        for section in 0..<_collectionView.numberOfSections() {
            if let brickSection = sections?[section] {
                let numberOfItems = _collectionView.numberOfItemsInSection(section)
                if brickSection.numberOfItems != numberOfItems {
                    changedSections[section] = numberOfItems
                }
            }
        }
        if !changedSections.isEmpty {
            BrickLayoutInvalidationContext(type: .InvalidateDataSourceCounts(sections: changedSections)).invalidateWithLayout(self, context: context)
        }

    }

    public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if !isCalculating {
            calculateSectionsIfNeeded(rect)
        }

        guard let sections = self.sections else {
            return nil
        }

        var attributes: [UICollectionViewLayoutAttributes] = []
        for (_, section) in sections {
            attributes.appendContentsOf(section.layoutAttributesForElementsInRect(rect, with: zIndexer))
        }

        return attributes
    }

    public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {

        if let attributes = sections?[indexPath.section]?.attributes[indexPath.item] {
            attributes.setAutoZIndex(zIndexer.zIndex(for: indexPath))
            return attributes
        } else if indexPath.section < _collectionView.numberOfSections() && indexPath.row < _collectionView.numberOfItemsInSection(indexPath.section) {

            // The attributes haven't been calculated because it's is not needed to be displayed yet
            // But `insertItemsAtIndexPaths` and `deleteItemsAtIndexPaths` might be called and the animation controller will need to know where these attributes are
            // So just return BrickAttributes with no values

            let attributes = BrickLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.hidden = true
            attributes.frame = .zero
            attributes.originalFrame = .zero
            attributes.identifier = ""

            return attributes
        }

        return nil
    }

    public override func shouldInvalidateLayoutForPreferredLayoutAttributes(preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        guard let brickAttribute = originalAttributes as? BrickLayoutAttributes else {
            return false
        }
        let shouldInvalidate = preferredAttributes.frame.height != brickAttribute.originalFrame.height
        brickAttribute.isEstimateSize = false
        return shouldInvalidate
    }

    public override func invalidationContextForPreferredLayoutAttributes(preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        return BrickLayoutInvalidationContext(type: .UpdateHeight(indexPath: originalAttributes.indexPath, newHeight: preferredAttributes.frame.size.height))
    }

}

extension BrickFlowLayout: BrickLayoutSectionDelegate {

    func brickLayoutSection(section: BrickLayoutSection, didCreateAttributes attributes: BrickLayoutAttributes) {
        for behavior in behaviors {
            behavior.registerAttributes(attributes, forCollectionViewLayout: self)
        }
    }

}

// MARK: - BrickLayoutSectionDataSource
extension BrickFlowLayout: BrickLayoutSectionDataSource {

    func edgeInsets(in section: BrickLayoutSection) -> UIEdgeInsets {
        return _dataSource.brickLayout(self, edgeInsetsForSection: section.sectionIndex)
    }

    func inset(in section: BrickLayoutSection) -> CGFloat {
        return _dataSource.brickLayout(self, insetForSection: section.sectionIndex)
    }

    func isAlignRowHeights(in section: BrickLayoutSection) -> Bool {
        return _dataSource.brickLayout(self, isAlignRowHeightsForSection: section.sectionIndex)
    }

    func aligment(in section: BrickLayoutSection) -> BrickAlignment {
        return _dataSource.brickLayout(self, alignmentForSection: section.sectionIndex)
    }

    func identifier(for index: Int, in section: BrickLayoutSection) -> String {
        return _dataSource.brickLayout(self, identifierForIndexPath: NSIndexPath(forItem: index, inSection: section.sectionIndex))
    }

    func isEstimate(for attributes: BrickLayoutAttributes, in section: BrickLayoutSection) -> Bool {
        return _dataSource.brickLayout(self, isEstimatedHeightForIndexPath: attributes.indexPath)
    }

    func width(for index: Int, totalWidth: CGFloat, startingAt origin: CGFloat, in section: BrickLayoutSection) -> CGFloat {
        let indexPath = NSIndexPath(forItem: index, inSection: section.sectionIndex)
        let width = _dataSource.brickLayout(self, widthForItemAtIndexPath: indexPath, totalWidth: totalWidth, widthRatio: widthRatio, startingAt: origin)

        return width
    }

    func prepareForSizeCalculation(for attributes: BrickLayoutAttributes, containedIn width: CGFloat, origin: CGPoint, invalidate: Bool, in section: BrickLayoutSection, updatedAttributes: OnAttributesUpdatedHandler?) {
        let indexPath = attributes.indexPath

        if let hideBehaviorDataSource = self.hideBehaviorDataSource {
            attributes.hidden = hideBehaviorDataSource.hideBehaviorDataSource(shouldHideItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: self)
        }

        if let sectionAttributes = section.sectionAttributes where sectionAttributes.hidden {
            attributes.hidden = true
        }

        let type = _dataSource.brickLayout(self, brickLayoutTypeForItemAtIndexPath: indexPath)
        switch type {
        case .Brick: break
        case .Section(let section):
            if let brickSection = sections?[section] {
                updateNumberOfItems(brickSection)
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
                calculateSection(for: section, with: attributes, containedInWidth: width, at: origin)
            }
        }
    }

    func size(for attributes: BrickLayoutAttributes, containedIn width: CGFloat, in section: BrickLayoutSection) -> CGSize {
        let indexPath = attributes.indexPath

        let type = _dataSource.brickLayout(self, brickLayoutTypeForItemAtIndexPath: indexPath)
        var size: CGSize = .zero
        switch type {
        case .Brick:
            // Check if the attributes already had a height. If so, use that height
            if attributes.frame.height != 0 && _dataSource.brickLayout(self, isEstimatedHeightForIndexPath: indexPath) {
                let height = attributes.frame.size.height
                size = CGSize(width: width, height: height)
            } else {
                let height = _dataSource.brickLayout(self, estimatedHeightForItemAtIndexPath: indexPath, containedInWidth: width)
                size = CGSize(width: width, height: height)
            }
        case .Section(let section):
            let height = _dataSource.brickLayout(self, estimatedHeightForItemAtIndexPath: indexPath, containedInWidth: width)
            if height == 0 {
                size = sections?[section]?.frame.size ?? .zero
            } else {
                size = CGSize(width: width, height: height)
            }
        }

        return size
    }

    func downStreamIndexPaths(in section: BrickLayoutSection) -> [NSIndexPath] {
        return downStreamBehaviorIndexPaths[section.sectionIndex] ?? []
    }
}

extension BrickFlowLayout: BrickLayoutInvalidationProvider {
    func invalidateHeight(for indexPath: NSIndexPath, updatedAttributes: OnAttributesUpdatedHandler) {
        guard let section = sections?[indexPath.section] else {
            return
        }

        updateSection(section, updatedAttributes: updatedAttributes) {
            section.invalidate(at: indexPath.item, updatedAttributes: { attributes, oldFrame in
                updatedAttributes(attributes: attributes, oldFrame: oldFrame)
                self.attributesWereUpdated(attributes, oldFrame: oldFrame, fromBehaviors: false, updatedAttributes: updatedAttributes)
            })
        }
    }

    func updateHeight(for indexPath: NSIndexPath, with height: CGFloat, updatedAttributes: OnAttributesUpdatedHandler) {
        guard let section = sections?[indexPath.section] else {
            return
        }

        updateSection(section, updatedAttributes: updatedAttributes) {
            section.update(height: height, at: indexPath.item, updatedAttributes: { attributes, oldFrame in
                updatedAttributes(attributes: attributes, oldFrame: oldFrame)
                self.attributesWereUpdated(attributes, oldFrame: oldFrame, fromBehaviors: false, updatedAttributes: updatedAttributes)
            })
        }
    }

    private func updateSection(section: BrickLayoutSection, updatedAttributes: OnAttributesUpdatedHandler, action: (() -> Void)) {

        let currentFrame = section.frame
        action()

        guard let indexPathForSection = dataSource?.brickLayout(self, indexPathForSection: section.sectionIndex) else {
            return
        }

        if section.frame.size.height != currentFrame.size.height {
            // If the frame is changed, it's should update the frame of the section above
            updateHeight(for: indexPathForSection, with: section.frame.height, updatedAttributes: updatedAttributes)
        }
    }

    func registerUpdatedAttributes(attributes: BrickLayoutAttributes, oldFrame: CGRect?, fromBehaviors: Bool, updatedAttributes: OnAttributesUpdatedHandler) {
        self.sections?[attributes.indexPath.section]?.registerUpdatedAttributes(attributes)

        self.attributesWereUpdated(attributes, oldFrame: oldFrame, fromBehaviors: fromBehaviors, updatedAttributes: { attributes, oldFrame in
            updatedAttributes(attributes: attributes, oldFrame: oldFrame)
        })
    }

    func removeAllCachedSections() {
        sections = nil
    }

    func invalidateContent(updatedAttributes: OnAttributesUpdatedHandler) {
        guard let contentWidth = contentWidth else {
            return
        }

        self.contentSize.width = contentWidth

        let onAttributesUpdated: OnAttributesUpdatedHandler = { attributes, oldFrame in
            updatedAttributes(attributes: attributes, oldFrame: oldFrame)
        }

        if sections?[0]?.sectionWidth != contentWidth {
            sections?[0]?.setSectionWidth(contentWidth, updatedAttributes: onAttributesUpdated)
        } else {
            sections?[0]?.invalidateAttributes(onAttributesUpdated)
        }
    }

    func updateContentSize(contentSize: CGSize) {
        self.contentSize = contentSize
    }

    func recalculateContentSize() -> CGSize {
        let oldContentSize = self.contentSize
        contentSize = sections?[0]?.frame.size ?? CGSizeZero
        let difference = CGSize(width: contentSize.width - oldContentSize.width, height: contentSize.height - oldContentSize.height)

        return difference
    }

    public func layoutAttributesForSection(section: Int) -> BrickLayoutAttributes? {
        if let indexPath = dataSource?.brickLayout(self, indexPathForSection: section) {
            return self.layoutAttributesForItemAtIndexPath(indexPath) as? BrickLayoutAttributes
        }
        return nil
    }

    private func attributesWereUpdated(attributes: BrickLayoutAttributes, oldFrame: CGRect?, fromBehaviors: Bool, updatedAttributes: OnAttributesUpdatedHandler) {
        let type = _dataSource.brickLayout(self, brickLayoutTypeForItemAtIndexPath: attributes.indexPath)
        switch type {
        case .Section(let section):
            if let brickSection = self.sections?[section] {
                updateNumberOfItems(brickSection)
                brickSection.setOrigin(attributes.frame.origin, fromBehaviors: fromBehaviors, updatedAttributes: { attributes, oldFrame in
                    updatedAttributes(attributes: attributes, oldFrame: oldFrame)
                    self.attributesWereUpdated(attributes, oldFrame: oldFrame, fromBehaviors: fromBehaviors, updatedAttributes: updatedAttributes)
                })

                // Because attributes could have been added, the frame height might have been changed
                attributes.frame = brickSection.frame
                attributes.originalFrame.size = brickSection.frame.size
            }
        default: break
        }
    }

    func applyHideBehavior(hideBehaviorDataSource: HideBehaviorDataSource, updatedAttributes: OnAttributesUpdatedHandler) {
        guard let firstSection = sections?[0] else {
            return
        }

        applyHideBehaviorForSection(hideBehaviorDataSource, for: firstSection, updatedAttributes: updatedAttributes)
    }

    func applyHideBehaviorForSection(hideBehaviorDataSource: HideBehaviorDataSource, for section: BrickLayoutSection, updatedAttributes: OnAttributesUpdatedHandler) {
        let currentFrame = section.frame

        for attributes in section.attributes.values {
            var shouldHide = hideBehaviorDataSource.hideBehaviorDataSource(shouldHideItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: self)

            // If the sectionAttributes are hidden, hide this attribute as well
            if let sectionAttributes = section.sectionAttributes where sectionAttributes.hidden {
                shouldHide = true
            }

            if shouldHide != attributes.hidden {
                section.changeVisibility(shouldHide, at: attributes.indexPath.item, updatedAttributes: { attributes, oldFrame in
                    updatedAttributes(attributes: attributes, oldFrame: oldFrame)
                })
            }

            let type = _dataSource.brickLayout(self, brickLayoutTypeForItemAtIndexPath: attributes.indexPath)
            switch type {
            case .Section(let sectionIndex):
                if let brickSection = sections?[sectionIndex] {
                    applyHideBehaviorForSection(hideBehaviorDataSource, for: brickSection, updatedAttributes: updatedAttributes)
                }
            default: break
            }
        }


        if section.frame != currentFrame {
            // If the frame is changed, it's should update the frame of the section above
            if let indexPathForSection = _dataSource.brickLayout(self, indexPathForSection: section.sectionIndex) {
                updateHeight(for: indexPathForSection, with: section.frame.height, updatedAttributes: updatedAttributes)
            }
        }

    }

}

extension BrickFlowLayout {
    public override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        insertedIndexPaths = []
        deletedIndexPaths = []
        reloadIndexPaths = []

        for item in updateItems {
            if item.updateAction == .Insert {
                if let indexPath = item.indexPathAfterUpdate {
                    insertedIndexPaths.append(indexPath)
                }
            } else if item.updateAction == .Delete {
                if let indexPath = item.indexPathBeforeUpdate {
                    deletedIndexPaths.append(indexPath)
                }
            } else if item.updateAction == .Reload {
                if let indexPath = item.indexPathBeforeUpdate {
                    reloadIndexPaths.append(indexPath)
                }
            }
        }

        isUpdating = true

        reloadItems(at: reloadIndexPaths)
    }

    private func reloadItems(at indexPaths: [NSIndexPath]) {
        for indexPath in indexPaths {
            if indexPath.item >= collectionView?.numberOfItemsInSection(indexPath.section)  {
                continue
            }

            switch _dataSource.brickLayout(self, brickLayoutTypeForItemAtIndexPath: indexPath) {
            case .Brick:
                invalidateLayoutWithContext(BrickLayoutInvalidationContext(type: .InvalidateHeight(indexPath: indexPath)))
            default: break
            }
        }
    }

    public override func finalizeCollectionViewUpdates() { // called inside an animation block after the update

        insertedIndexPaths = []
        deletedIndexPaths = []
        reloadIndexPaths = []
        isUpdating = false
    }


    override public func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {

        var attributes: BrickLayoutAttributes?

        if insertedIndexPaths.contains(itemIndexPath) {
            if let copy = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath)?.copy() as? BrickLayoutAttributes {
                appearBehavior?.configureAttributesForAppearing(copy, in: _collectionView)
                attributes = copy
            }
        } else if let copy = self.layoutAttributesForItemAtIndexPath(itemIndexPath)?.copy() as? BrickLayoutAttributes {
            attributes = copy
        }

        attributes?.setAutoZIndex(zIndexer.zIndex(for: itemIndexPath))

        return attributes
    }
    
    override public func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes: BrickLayoutAttributes?

        if deletedIndexPaths.contains(itemIndexPath) {
            if let copy = super.finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath)?.copy() as? BrickLayoutAttributes {
                appearBehavior?.configureAttributesForDisappearing(copy, in: _collectionView)
                attributes = copy
            }
        } else if let copy = self.layoutAttributesForItemAtIndexPath(itemIndexPath)?.copy() as? BrickLayoutAttributes {
            attributes = copy
        }

        attributes?.setAutoZIndex(zIndexer.zIndex(for: itemIndexPath))

        return attributes
    }
}


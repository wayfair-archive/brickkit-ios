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

    /// Align Rowheights
    public var alignRowHeights: Bool = false

    public var behaviors: Set<BrickLayoutBehavior> = [] {
        didSet {
            for behavior in behaviors {
                behavior.collectionViewLayout = self
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
    public var hideBehaviorDataSource: HideBehaviorDataSource?

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
    public private(set) var maxZIndex = 0

    /// Current ZIndex
    private var zIndex = 0

    /// Unwrapped collectionView. This should only be called in a context where the collectionView is set
    private var _collectionView: UICollectionView {
        guard let unwrappedCollectionView = self.collectionView else {
            fatalError("`collectionView` should be set when calling a function to the layout")
        }
        return unwrappedCollectionView
    }


    /// Sections
    internal private(set) var sections: [Int: BrickLayoutSection]?

    /// BrickZones
    internal var brickZones: BrickZones?

    /// Flag to indicate that an update cycle is happening
    var isUpdating: Bool = false

    /// IndexPaths being added
    var insertedIndexPaths: [NSIndexPath] = []

    /// IndexPaths being deleted
    var deletedIndexPaths: [NSIndexPath] = []

    /// IndexPaths being reloaded
    var reloadIndexPaths: [NSIndexPath] = []


    internal func calculateSectionsIfNeeded() -> [Int: BrickLayoutSection] {
        guard let _ = dataSource else {
            fatalError("No dataSource was set for BrickFlowLayout")
        }

        if let sections = sections {
            return sections
        }

        BrickLayoutInvalidationContext(type: .Creation).invalidateWithLayout(self)

        return sections!
    }

    internal func calculateZIndex() {
        maxZIndex = 0
        for section in 0..<_collectionView.numberOfSections() {
            maxZIndex += _collectionView.numberOfItemsInSection(section)
        }
        maxZIndex -= 1

        if zIndexBehavior == .TopDown {
            zIndex = maxZIndex
        } else {
            zIndex = 0
        }
    }

    private func resetBrickZones(width: CGFloat) {
        brickZones = BrickZones(collectionViewSize: CGSize(width: width, height: _collectionView.frame.size.height), scrollDirection: self.scrollDirection)
    }

    internal func calculateSections() {
        sections = [:]

        if self.contentWidth == nil {
            self.contentWidth = _collectionView.frame.width
        }

        self.contentSize.width = self.contentWidth!

        self.resetBrickZones(self.contentWidth!)

        if _collectionView.numberOfSections() > 0 {
            calculateSection(for: 0, with: nil, containedInWidth: self.contentSize.width, at: CGPoint.zero)
        }
    }

    internal func calculateSection(for sectionIndex: Int, with sectionAttributes: BrickLayoutAttributes?, containedInWidth width: CGFloat, at origin: CGPoint) {
        guard _collectionView.numberOfSections() > sectionIndex else {
            fatalError("The section is not found")
        }
        let section = BrickLayoutSection(sectionIndex: sectionIndex, sectionAttributes: sectionAttributes, numberOfItems: _collectionView.numberOfItemsInSection(sectionIndex), origin: origin, sectionWidth: width, dataSource: self)
        section.invalidateAttributes { (attributes, oldFrame) in
            self.brickZones?.addAttributesToZones(attributes)
            for behavior in self.behaviors {
                behavior.registerAttributes(attributes, forCollectionViewLayout: self)
            }

        }
        sections?[sectionIndex] = section
    }


    internal func updateNumberOfItems(brickSection: BrickLayoutSection, numberOfItems: Int? = nil) {
        brickSection.setNumberOfItems(numberOfItems ?? _collectionView.numberOfItemsInSection(brickSection.sectionIndex), addedAttributes: { (attributes, oldFrame) in
            self.brickZones?.addAttributesToZones(attributes)
            }, removedAttributes: { (attributes, oldFrame) in
                self.brickZones?.removeAttributes(attributes)
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
        guard let dataSource = dataSource else {
            fatalError("Can't call `updateHeight` without collectionview")
        }

        if dataSource.brickLayout(self, isEstimatedHeightForIndexPath: indexPath) {
            let context = BrickLayoutInvalidationContext(type: .UpdateHeight(indexPath: indexPath, newHeight: newHeight))
            invalidateLayoutWithContext(context)
        }
    }

}

// MARK: - UICollectionViewLayout
extension BrickFlowLayout {

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
        
        super.invalidateLayoutWithContext(context)

    }

    public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        calculateSectionsIfNeeded()
        return brickZones?.layoutAttributesForElementsInRect(rect, for: self)
    }

    public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return sections?[indexPath.section]?.attributes[indexPath.item]
    }

    public override func shouldInvalidateLayoutForPreferredLayoutAttributes(preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        guard let brickAttribute = originalAttributes as? BrickLayoutAttributes else {
            return false
        }

        let shouldInvalidate = preferredAttributes.frame.height != brickAttribute.originalFrame.height
        return shouldInvalidate
    }

    public override func invalidationContextForPreferredLayoutAttributes(preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        return BrickLayoutInvalidationContext(type: .UpdateHeight(indexPath: originalAttributes.indexPath, newHeight: preferredAttributes.frame.size.height))
    }

}

extension BrickFlowLayout: BrickLayoutSectionDataSource {

    func edgeInsets(in section: BrickLayoutSection) -> UIEdgeInsets {
        guard let dataSource = dataSource else {
            return UIEdgeInsetsZero
        }
        return dataSource.brickLayout(self, edgeInsetsForSection: section.sectionIndex)
    }

    func inset(in section: BrickLayoutSection) -> CGFloat {
        guard let dataSource = dataSource else {
            return 0
        }
        return dataSource.brickLayout(self, insetForSection: section.sectionIndex)
    }

    func identifier(for index: Int, in section: BrickLayoutSection) -> String {
        return dataSource?.brickLayout(self, identifierForIndexPath: NSIndexPath(forItem: index, inSection: section.sectionIndex)) ?? ""
    }

    func zIndex(for index: Int, in section: BrickLayoutSection) -> Int {
        defer {
            switch zIndexBehavior {
            case .TopDown: zIndex -= 1
            case .BottomUp: zIndex += 1
            }
        }
        
        return zIndex
    }

    func isEstimate(for attributes: BrickLayoutAttributes, in section: BrickLayoutSection) -> Bool {
        return dataSource?.brickLayout(self, isEstimatedHeightForIndexPath: attributes.indexPath) ?? false
    }

    func zIndexBehaviorForSkeleton(in section: BrickLayoutSection) -> BrickLayoutZIndexBehavior {
        return zIndexBehavior
    }

    func width(for index: Int, totalWidth: CGFloat, in section: BrickLayoutSection) -> CGFloat {
        guard let dataSource = dataSource else {
            return 0
        }

        let indexPath = NSIndexPath(forItem: index, inSection: section.sectionIndex)
        let width = dataSource.brickLayout(self, widthForItemAtIndexPath: indexPath, totalWidth: totalWidth, widthRatio: widthRatio)

        return width
    }


    func prepareForSizeCalculation(for attributes: BrickLayoutAttributes, containedIn width: CGFloat, origin: CGPoint, invalidate: Bool, in section: BrickLayoutSection, updatedAttributes: OnAttributesUpdatedHandler?) {
        guard let dataSource = dataSource else {
            return
        }

        let indexPath = attributes.indexPath

        if let hideBehaviorDataSource = self.hideBehaviorDataSource {
            attributes.hidden = hideBehaviorDataSource.hideBehaviorDataSource(shouldHideItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: self)
        }

        if let sectionAttributes = section.sectionAttributes where sectionAttributes.hidden {
            attributes.hidden = true
        }

        let type = dataSource.brickLayout(self, brickLayoutTypeForItemAtIndexPath: indexPath)
        switch type {
        case .Brick: break
        case .Section(let section):
            if let brickSection = sections?[section] {
                updateNumberOfItems(brickSection)
                brickSection.setOrigin(origin, fromBehaviors: false, updatedAttributes: updatedAttributes)
                if brickSection.sectionWidth != width {
                    brickSection.setSectionWidth(width, updatedAttributes: updatedAttributes)
                } else if invalidate  {
                    brickSection.invalidateAttributes(updatedAttributes)
                }
            } else {
                calculateSection(for: section, with: attributes, containedInWidth: width, at: origin)
            }
        }
    }

    func size(for attributes: BrickLayoutAttributes, containedIn width: CGFloat, in section: BrickLayoutSection) -> CGSize {
        guard let dataSource = dataSource else {
            return .zero
        }
        let indexPath = attributes.indexPath

        let type = dataSource.brickLayout(self, brickLayoutTypeForItemAtIndexPath: indexPath)
        var size: CGSize = .zero
        switch type {
        case .Brick:
            // Check if the attributes already had a height. If so, use that height
            if attributes.frame.height != 0 {
                let height = attributes.frame.size.height
                size = CGSize(width: width, height: height)
            } else {
                let height = dataSource.brickLayout(self, estimatedHeightForItemAtIndexPath: indexPath, containedInWidth: width)
                size = CGSize(width: width, height: height)
            }
        case .Section(let section):
            let height = dataSource.brickLayout(self, estimatedHeightForItemAtIndexPath: indexPath, containedInWidth: width)
            if height == 0 {
                size = sections?[section]?.frame.size ?? .zero
            } else {
                size = CGSize(width: width, height: height)
            }
        }

        return size
    }

}

extension BrickFlowLayout: BrickLayoutInvalidationProvider {
    func invalidateHeight(for indexPath: NSIndexPath, updatedAttributes: OnAttributesUpdatedHandler) {
        guard let section = sections?[indexPath.section] else {
            return
        }

        let currentFrame = section.frame

        section.invalidate(at: indexPath.item, updatedAttributes: { attributes, oldFrame in
            updatedAttributes(attributes: attributes, oldFrame: oldFrame)
            self.attributesWereUpdated(attributes, oldFrame: oldFrame, fromBehaviors: false, updatedAttributes: updatedAttributes)
        })

        if section.frame != currentFrame {
            // If the frame is changed, it's should update the frame of the section above
            if let indexPathForSection = dataSource?.brickLayout(self, indexPathForSection: indexPath.section) {
                updateHeight(for: indexPathForSection, with: section.frame.height, updatedAttributes: updatedAttributes)
            }
        }
    }

    func updateHeight(for indexPath: NSIndexPath, with height: CGFloat, updatedAttributes: OnAttributesUpdatedHandler) {
        guard let section = sections?[indexPath.section] else {
            return
        }

        let currentFrame = section.frame

        section.update(height: height, at: indexPath.item, updatedAttributes: { attributes, oldFrame in
            updatedAttributes(attributes: attributes, oldFrame: oldFrame)
            self.attributesWereUpdated(attributes, oldFrame: oldFrame, fromBehaviors: false, updatedAttributes: updatedAttributes)
        })

        if section.frame != currentFrame {
            // If the frame is changed, it's should update the frame of the section above
            if let indexPathForSection = dataSource?.brickLayout(self, indexPathForSection: indexPath.section) {
                updateHeight(for: indexPathForSection, with: section.frame.height, updatedAttributes: updatedAttributes)
            }
        }
    }

    func registerUpdatedAttributes(attributes: BrickLayoutAttributes, oldFrame: CGRect?, fromBehaviors: Bool, updatedAttributes: OnAttributesUpdatedHandler) {
        self.brickZones?.updateZones(for: attributes, from: oldFrame)

        self.attributesWereUpdated(attributes, oldFrame: oldFrame, fromBehaviors: fromBehaviors, updatedAttributes: { attributes, oldFrame in
            self.brickZones?.updateZones(for: attributes, from: oldFrame)
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

        self.resetBrickZones(contentWidth)

        let onAttributesUpdated: OnAttributesUpdatedHandler = { attributes, oldFrame in
            self.brickZones?.addAttributesToZones(attributes)
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
        guard let dataSource = self.dataSource else {
            return
        }

        let type = dataSource.brickLayout(self, brickLayoutTypeForItemAtIndexPath: attributes.indexPath)
        switch type {
        case .Section(let section):
            if let brickSection = self.sections?[section] {
                updateNumberOfItems(brickSection)
                brickSection.setOrigin(attributes.frame.origin, fromBehaviors: fromBehaviors, updatedAttributes: { attributes, oldFrame in
                    updatedAttributes(attributes: attributes, oldFrame: oldFrame)
                    self.attributesWereUpdated(attributes, oldFrame: oldFrame, fromBehaviors: fromBehaviors, updatedAttributes: updatedAttributes)
                })
            }
        default: break
        }
    }

    func recalculateZIndexes(updatedAttributes: OnAttributesUpdatedHandler) {
        calculateZIndex()

        guard let firstSection = sections?[0] else {
            return
        }

        recalucateZIndexesForSection(firstSection, updatedAttributes: updatedAttributes)

    }

    func recalucateZIndexesForSection(section: BrickLayoutSection, updatedAttributes: OnAttributesUpdatedHandler) {
        guard let dataSource = dataSource else { return }
        for attributes in section.attributes {
            if zIndexBehavior == .BottomUp {
                attributes.zIndex = zIndex(for: attributes.indexPath.item, in: section)
            }

            let type = dataSource.brickLayout(self, brickLayoutTypeForItemAtIndexPath: attributes.indexPath)
            switch type {
            case .Section(let sectionIndex):
                if let brickSection = sections?[sectionIndex] {
                    recalucateZIndexesForSection(brickSection, updatedAttributes: updatedAttributes)
                }
            default: break
            }

            if zIndexBehavior == .TopDown {
                attributes.zIndex = zIndex(for: attributes.indexPath.item, in: section)
             }

            updatedAttributes(attributes: attributes, oldFrame: nil)
        }
    }

    func applyHideBehavior(hideBehaviorDataSource: HideBehaviorDataSource, updatedAttributes: OnAttributesUpdatedHandler) {
        guard let firstSection = sections?[0] else {
            return
        }

        applyHideBehaviorForSection(hideBehaviorDataSource, for: firstSection, updatedAttributes: updatedAttributes)
    }

    func applyHideBehaviorForSection(hideBehaviorDataSource: HideBehaviorDataSource, for section: BrickLayoutSection, updatedAttributes: OnAttributesUpdatedHandler) {
        guard let dataSource = dataSource else { return }

        let currentFrame = section.frame

        for attributes in section.attributes {
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

            let type = dataSource.brickLayout(self, brickLayoutTypeForItemAtIndexPath: attributes.indexPath)
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
            if let indexPathForSection = dataSource.brickLayout(self, indexPathForSection: section.sectionIndex) {
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
                    if indexPath.item >= collectionView?.numberOfItemsInSection(indexPath.section)  {
                        continue
                    }

                    if let dataSource = dataSource {
                        switch dataSource.brickLayout(self, brickLayoutTypeForItemAtIndexPath: indexPath) {
                        case .Brick:
                            BrickLayoutInvalidationContext(type: .InvalidateHeight(indexPath: indexPath)).invalidateWithLayout(self)
                        default: break
                        }
                    }
                }
            }
        }

        isUpdating = true
    }

    public override func finalizeCollectionViewUpdates() { // called inside an animation block after the update
        insertedIndexPaths = []
        deletedIndexPaths = []
        reloadIndexPaths = []

        isUpdating = false
    }


    override public func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        guard let appearBehavior = appearBehavior else {
            return nil
        }

        if let attributes = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath) {
            let a = attributes.copy() as! UICollectionViewLayoutAttributes
            if insertedIndexPaths.contains(attributes.indexPath) {
                appearBehavior.configureAttributesForAppearing(a, in: _collectionView)
            }
            return a
        }
        return nil
    }

    override public func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        guard let appearBehavior = appearBehavior else {
            return nil
        }

        if let attributes = super.finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath) {
            let a = attributes.copy() as! UICollectionViewLayoutAttributes
            if deletedIndexPaths.contains(attributes.indexPath) {
                appearBehavior.configureAttributesForDisappearing(a, in: _collectionView)
            }
            return a
        }
        return nil
    }
}


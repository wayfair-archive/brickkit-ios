//
//  BrickLayoutSection.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

protocol BrickLayoutSectionDataSource: class {
    var alignRowHeights: Bool { get }
    var zIndexBehavior: BrickLayoutZIndexBehavior { get }
    var scrollDirection: UICollectionViewScrollDirection { get }
    var widthRatio: CGFloat { get }

    func edgeInsets(in section: BrickLayoutSection) -> UIEdgeInsets
    func inset(in section: BrickLayoutSection) -> CGFloat
    func width(for index: Int, totalWidth: CGFloat, in section: BrickLayoutSection) -> CGFloat
    func prepareForSizeCalculation(for attributes: BrickLayoutAttributes, containedIn width: CGFloat, origin: CGPoint, invalidate: Bool, in section: BrickLayoutSection, updatedAttributes: OnAttributesUpdatedHandler?)
    func size(for attributes: BrickLayoutAttributes, containedIn width: CGFloat, in section: BrickLayoutSection) -> CGSize
    func identifier(for index: Int, in section: BrickLayoutSection) -> String
    func zIndex(for index: Int, in section: BrickLayoutSection) -> Int
    func isEstimate(for attributes: BrickLayoutAttributes, in section: BrickLayoutSection) -> Bool
}

/// BrickLayoutSection manages all the attributes that are in one specific section
internal class BrickLayoutSection {

    /// The BrickLayoutAttributes that represent this section on a level higher
    /// - Optional because the root section will not have this set
    internal var sectionAttributes: BrickLayoutAttributes?

    /// Index of the section
    internal let sectionIndex: Int

    /// Number of Items in this section
    internal private(set) var numberOfItems: Int

    /// Calculated attributes for this section
    internal private(set) var attributes: [BrickLayoutAttributes] = []

    /// Frame that contains this whole section
    internal private(set) var frame: CGRect = .zero

    /**
        Width of the section. Can be set by `setSectionWidth`

        This is not a calculated property of the frame because in case of horizontal scrolling, the values will be different
     */
    internal private(set) var sectionWidth: CGFloat

    /// Origin of the frame. Can be set by `setOrigin`
    private var origin: CGPoint {
        return frame.origin
    }

    /// DataSource that is used to calculate the section
    internal weak var dataSource: BrickLayoutSectionDataSource?

    /// Default constructor
    ///
    /// - parameter sectionIndex:      Index of the section
    /// - parameter sectionAttributes: Attributes on a higher level that contain this section
    /// - parameter numberOfItems:     Initial number of items in this section
    /// - parameter origin:            Origin of the section
    /// - parameter sectionWidth:      Width of the section
    /// - parameter dataSource:        DataSource
    ///
    /// - returns: instance of the BrickLayoutSection
    init(sectionIndex: Int, sectionAttributes: BrickLayoutAttributes?, numberOfItems: Int, origin: CGPoint, sectionWidth: CGFloat, dataSource: BrickLayoutSectionDataSource) {
        self.dataSource = dataSource
        self.sectionIndex = sectionIndex
        self.numberOfItems = numberOfItems
        self.sectionAttributes = sectionAttributes
        self.sectionWidth = sectionWidth

        initializeFrameWithOrigin(origin, sectionWidth: sectionWidth)
    }


    /// Initialize the frame with the default origin and width
    ///
    /// - parameter sectionOrigin: origin
    /// - parameter sectionWidth:  width
    ///
    private func initializeFrameWithOrigin(origin: CGPoint, sectionWidth: CGFloat) {
        frame.origin = origin
        frame.size.width = sectionWidth
    }

    func setNumberOfItems(numberOfItems: Int, addedAttributes: OnAttributesUpdatedHandler?, removedAttributes: OnAttributesUpdatedHandler?) {
        guard numberOfItems != self.numberOfItems else {
            return
        }

        let difference = numberOfItems - self.numberOfItems

        if difference > 0 {
            self.numberOfItems = numberOfItems
            createOrUpdateCells(from: attributes.count, invalidate: false, updatedAttributes: addedAttributes)
        } else {
            self.numberOfItems = numberOfItems
            while attributes.count != numberOfItems {
                if let last = attributes.last {
                    removedAttributes?(attributes: last, oldFrame: last.frame)
                }
                attributes.removeLast()
            }
            createOrUpdateCells(from: attributes.count, invalidate: true, updatedAttributes: nil)
        }

    }

    func appendItem(updatedAttributes: OnAttributesUpdatedHandler?) {
        numberOfItems += 1
        createOrUpdateCells(from: attributes.count, invalidate: true, updatedAttributes: updatedAttributes)
    }

    func deleteLastItem(updatedAttributes: OnAttributesUpdatedHandler?) {
        guard let last = attributes.last else {
            return
        }
        numberOfItems -= 1
        attributes.removeLast()
        createOrUpdateCells(from: attributes.count, invalidate: true, updatedAttributes: updatedAttributes)
        updatedAttributes?(attributes: last, oldFrame: last.frame)
    }


    func setOrigin(origin: CGPoint, fromBehaviors: Bool, updatedAttributes: OnAttributesUpdatedHandler?) {
        guard self.origin != origin else {
            return
        }
        let oldValue = self.origin
        self.frame.origin = origin
        let size = CGSize(width: origin.x - oldValue.x, height: origin.y - oldValue.y)
        self.offsetFrames(size, fromBehaviors: fromBehaviors, updatedAttributes: updatedAttributes)
    }


    func setSectionWidth(sectionWidth: CGFloat, updatedAttributes: OnAttributesUpdatedHandler?) {
        if self.sectionWidth != sectionWidth {
            self.sectionWidth = sectionWidth
            invalidateAttributes(updatedAttributes)
        }
    }

    internal func invalidateAttributes(updatedAttributes: OnAttributesUpdatedHandler?) {
        createOrUpdateCells(from: 0, invalidate: true, updatedAttributes: updatedAttributes)
    }

    func update(height height: CGFloat, at index: Int, updatedAttributes: OnAttributesUpdatedHandler?) {
        attributes[index].isEstimateSize = false

        guard attributes[index].originalFrame.height != height else {
            return
        }

        attributes[index].originalFrame.size.height = height

        createOrUpdateCells(from: index, invalidate: false, updatedAttributes: updatedAttributes, customHeightProvider:{ attributes -> CGFloat? in
            guard attributes.isEstimateSize else {
                return nil
            }

            if attributes.identifier == self.attributes[index].identifier {
                return self.attributes[index].originalFrame.height
            }

            return nil
        })
    }

    private func invalidateAttributes(attributes: BrickLayoutAttributes) {
        attributes.isEstimateSize = true
        attributes.originalFrame = .zero
        attributes.frame = .zero
    }

    func invalidate(at index: Int, updatedAttributes: OnAttributesUpdatedHandler?) {
        guard let dataSource = dataSource else {
            fatalError("Invalidate can't be called without dataSource")
        }

        invalidateAttributes(attributes[index])

        let width = widthAtIndex(index, dataSource: dataSource)
        let size = dataSource.size(for: attributes[index], containedIn: width, in: self)
        attributes[index].originalFrame.size = size
        attributes[index].frame.size = size

        createOrUpdateCells(from: index, invalidate: false, updatedAttributes: updatedAttributes, customHeightProvider: nil)
    }

    func changeVisibility(visibility: Bool, at index: Int, updatedAttributes: OnAttributesUpdatedHandler?) {
        attributes[index].hidden = visibility
        
        createOrUpdateCells(from: index, invalidate: false, updatedAttributes: updatedAttributes, customHeightProvider: nil)
    }

    private func offsetFrames(offset: CGSize, fromBehaviors: Bool, updatedAttributes: OnAttributesUpdatedHandler?) {
        for attribute in attributes {
            let oldFrame = attribute.frame
            if !fromBehaviors {
                attribute.originalFrame.origin.x += offset.width
                attribute.originalFrame.origin.y += offset.height
            }
            attribute.frame.origin.x += offset.width
            attribute.frame.origin.y += offset.height

            updatedAttributes?(attributes: attribute, oldFrame: oldFrame)
        }
    }

    private func widthAtIndex(index: Int, dataSource: BrickLayoutSectionDataSource) -> CGFloat {
        let edgeInsets = dataSource.edgeInsets(in: self)
        let totalWidth = sectionWidth - edgeInsets.left - edgeInsets.right

        return dataSource.width(for: index, totalWidth: totalWidth, in: self)
    }

    private func createOrUpdateCells(from firstIndex: Int, invalidate: Bool, updatedAttributes: OnAttributesUpdatedHandler?, customHeightProvider: ((attributes: BrickLayoutAttributes) -> CGFloat?)? = nil) {
        guard let dataSource = dataSource else {
            return
        }

        let create = attributes.isEmpty
        let zIndexBehavior = dataSource.zIndexBehavior

        let edgeInsets = dataSource.edgeInsets(in: self)
        let inset = dataSource.inset(in: self)

        var startOrigin: CGPoint
        var maxY: CGFloat

        startOrigin = CGPoint(x: frame.origin.x + edgeInsets.left, y: frame.origin.y + edgeInsets.top)
        maxY = frame.origin.y
        if !create {
            let visibleAttributes = attributes.filter({ !$0.hidden })
            if firstIndex > 0 {
                var lastVisibleAttribute: BrickLayoutAttributes?

                for index in 1...firstIndex {
                    let lastAttribute = attributes[firstIndex - index]
                    if !lastAttribute.hidden {
                        lastVisibleAttribute = lastAttribute
                        break
                    }
                }

                if let lastAttribute = lastVisibleAttribute, let lastIndex = visibleAttributes.indexOf(lastAttribute)  {
                    maxY = BrickUtils.findRowMaxY(for: lastIndex + 1, in: visibleAttributes.map{ $0.originalFrame }) ?? frame.origin.y

                    startOrigin = CGPoint(x: lastAttribute.originalFrame.maxX + inset, y: lastAttribute.originalFrame.origin.y)
                }
            } else if let first = visibleAttributes.first, let firstAttributesIndex = visibleAttributes.indexOf(first) where firstAttributesIndex <= firstIndex {
                maxY = first.originalFrame.maxY
                startOrigin = first.originalFrame.origin
            }
        }

        var x: CGFloat = startOrigin.x
        var y: CGFloat = startOrigin.y

        let numberOfItems = self.numberOfItems
        for index in firstIndex..<numberOfItems {
            let indexPath = NSIndexPath(forItem: index, inSection: sectionIndex)

            let brickAttributes: BrickLayoutAttributes
            let oldFrame:CGRect?
            let oldOriginalFrame: CGRect?

            let existingAttribute: Bool = index < attributes.count
            let recalculateZIndex = !existingAttribute || invalidate
            if existingAttribute {
                brickAttributes = attributes[index]
                oldFrame = brickAttributes.frame
                oldOriginalFrame = brickAttributes.originalFrame

                if invalidate {
                    invalidateAttributes(brickAttributes)
                    brickAttributes.isEstimateSize = dataSource.isEstimate(for: brickAttributes, in: self)
                }
            } else {
                brickAttributes = BrickLayoutAttributes(forCellWithIndexPath: indexPath)

                brickAttributes.identifier = dataSource.identifier(for: index, in: self)
                attributes.append(brickAttributes)
                oldFrame = nil
                oldOriginalFrame = nil
                brickAttributes.isEstimateSize = dataSource.isEstimate(for: brickAttributes, in: self)
            }


            if recalculateZIndex && zIndexBehavior == .BottomUp {
                brickAttributes.zIndex = dataSource.zIndex(for: index, in: self)
            }

            var width = widthAtIndex(index, dataSource: dataSource)

            let shouldBeOnNextRow: Bool
            switch dataSource.scrollDirection {
            case .Horizontal: shouldBeOnNextRow = false
            case .Vertical: shouldBeOnNextRow = (x + width - origin.x) > (sectionWidth - edgeInsets.right)
            }

            if shouldBeOnNextRow {
                if dataSource.alignRowHeights {
                    let maxHeight = maxY - y
                    updateHeightForRowsFromIndex(index - 1, maxHeight: maxHeight, updatedAttributes: updatedAttributes)
                }

                if maxY > y  {
                    y = maxY + inset
                }
                x = origin.x + edgeInsets.left
            }

            let cellOrigin = CGPoint(x: x, y: y)
            let height: CGFloat

            // Prepare the datasource that size calculation will happen
            dataSource.prepareForSizeCalculation(for: brickAttributes, containedIn: width, origin: cellOrigin, invalidate: invalidate, in: self, updatedAttributes: updatedAttributes)

            if let brickFrame = oldOriginalFrame where brickFrame.width == width && !invalidate {
                if let customHeight = customHeightProvider?(attributes: brickAttributes) {
                    height = customHeight
                } else {
                    height = brickFrame.height
                }
            } else {
                let size = dataSource.size(for: brickAttributes, containedIn: width, in: self)
                height = size.height
                width = size.width
            }

            let brickFrame = CGRect(origin: cellOrigin, size: CGSize(width: width, height: height))
            brickAttributes.originalFrame = brickFrame

            brickAttributes.frame = brickFrame
            
            if recalculateZIndex && zIndexBehavior == .TopDown {
                brickAttributes.zIndex = dataSource.zIndex(for: index, in: self)
            }

            updatedAttributes?(attributes: brickAttributes, oldFrame: oldFrame)

            let sectionIsHidden = sectionAttributes?.hidden ?? false
            let brickIsHiddenOrHasNoHeight = height <= 0 || brickAttributes.hidden

            if sectionIsHidden || !brickIsHiddenOrHasNoHeight {
                x = brickFrame.maxX + inset
                maxY = max(brickFrame.maxY, maxY)
            }

            brickAttributes.alpha = brickAttributes.hidden ? 0 : 1
        }

        if dataSource.alignRowHeights {
            let maxHeight = maxY - y
            updateHeightForRowsFromIndex(attributes.count - 1, maxHeight: maxHeight, updatedAttributes: updatedAttributes)
        }

        var frameHeight: CGFloat = 0
        if let first = attributes.first {
            frameHeight = (maxY - first.originalFrame.origin.y) + edgeInsets.bottom + edgeInsets.top
            let originY = first.originalFrame.origin.y - edgeInsets.top

            if frame.origin.y != originY {
                let originDiff = frame.origin.y - originY
                frame.origin.y = originY

                // The origin for the frame is changed. This means that previously calculated frames need to be compensated back up
                // Only update the attributes below the firstIndex (as the ones after are already correct)
                for index in 0..<firstIndex {
                    attributes[index].frame.origin.y -= originDiff
                }
            }
        }

        if frameHeight <= edgeInsets.bottom + edgeInsets.top {
            frameHeight = 0
        }
        frame.size.height = frameHeight


        switch dataSource.scrollDirection {
        case .Vertical: frame.size.width = sectionWidth
        case .Horizontal:
            x -= inset // Take off the inset as this is added to the end
            frame.size.width = x + edgeInsets.right
        }        
    }

    func updateHeightForRowsFromIndex(index: Int, maxHeight: CGFloat, updatedAttributes: OnAttributesUpdatedHandler?) {
        guard index >= 0 else {
            return
        }
        var currentIndex = index
        let y = attributes[index].originalFrame.origin.y
        while currentIndex >= 0 {
            if attributes[currentIndex].originalFrame.origin.y != y {
                return
            }
            let oldFrame = attributes[currentIndex].frame
            attributes[currentIndex].frame.size.height = maxHeight
            if attributes[currentIndex].frame != oldFrame {
                updatedAttributes?(attributes: attributes[currentIndex], oldFrame: oldFrame)
            }
            currentIndex -= 1
        }
    }

}

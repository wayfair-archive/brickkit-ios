//
//  BrickLayoutSection.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

private let PrecisionAccuracy: CGFloat = 0.0000001

protocol BrickLayoutSectionDelegate: class {
    func brickLayoutSection(section: BrickLayoutSection, didCreateAttributes attributes: BrickLayoutAttributes)
}

protocol BrickLayoutSectionDataSource: class {

    /// Scroll Direction of the layout
    var scrollDirection: UICollectionViewScrollDirection { get }

    /// The current frame of interest that we want to calculate attributes in
    var frameOfInterest: CGRect { get }

    /// The edge insets for this section
    func edgeInsets(in section: BrickLayoutSection) -> UIEdgeInsets

    /// The inset for this section
    func inset(in section: BrickLayoutSection) -> CGFloat

    /// Flag that indicates if row heights need to be aligned
    func isAlignRowHeights(in section: BrickLayoutSection) -> Bool

    ///
    func aligment(in section: BrickLayoutSection) -> BrickAlignment

    /// Function called right before the height is asked. This can be used to do some other pre-calcuations
    func prepareForSizeCalculation(for attributes: BrickLayoutAttributes, containedIn width: CGFloat, origin: CGPoint, invalidate: Bool, in section: BrickLayoutSection, updatedAttributes: OnAttributesUpdatedHandler?)

    /// Returns the width of attributes at a given index
    ///
    /// - Parameters:
    ///   - totalWidth: width minus the edgeinsets
    /// - Returns: width for attributes at a given index
    func width(for index: Int, totalWidth: CGFloat, startingAt origin: CGFloat, in section: BrickLayoutSection) -> CGFloat

    /// Returns the size for attributes at a given index
    func size(for attributes: BrickLayoutAttributes, containedIn size: CGSize, in section: BrickLayoutSection) -> CGSize


    /// Returns the identifier for attributes at a given index
    func identifier(for index: Int, in section: BrickLayoutSection) -> String

    /// Returns if attributes are estimated at a given index
    func isEstimate(for attributes: BrickLayoutAttributes, in section: BrickLayoutSection) -> Bool

    /// Returns the downstream indexpaths for this section
    func downStreamIndexPaths(in section: BrickLayoutSection) -> [NSIndexPath]

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
    /// This is a dictionary, because the attributes might get calculated in a different order and could get removed if we need to free up memory
    internal private(set) var attributes: [Int: BrickLayoutAttributes] = [:]

    /// IndexPaths of attributes that are touched by behaviors (originalFrame and frame are different)
    internal private(set) var behaviorAttributesIndexPaths: Set<NSIndexPath> = []

    /// Frame that contains this whole section
    internal private(set) var frame: CGRect = .zero

    /// Width of the section. Can be set by `setSectionWidth`
    /// This is not a calculated property of the frame because in case of horizontal scrolling, the values will be different
    internal private(set) var sectionWidth: CGFloat
    
    /// Estimated height of the section.
    /// This is not a calculated property of the frame because in case of vertical scrolling, the values will be different
    internal private(set) var sectionHeight: CGFloat?

    /// Origin of the frame. Can be set by `setOrigin`
    internal var origin: CGPoint {
        return frame.origin
    }

    /// DataSource that is used to calculate the section
    internal weak var dataSource: BrickLayoutSectionDataSource?

    /// Unwrapped dataSource that is used to avoid unwrapping all the time
    var _dataSource: BrickLayoutSectionDataSource {
        guard let unwrappedDataSource = self.dataSource else {
            fatalError("`dataSource` should be set when calling a function to the layoutSection")
        }
        return unwrappedDataSource
    }

    /// Delegate that is used get informed by certain events
    internal weak var delegate: BrickLayoutSectionDelegate?

    /// Default constructor
    ///
    /// - parameter sectionIndex:      Index of the section
    /// - parameter sectionAttributes: Attributes on a higher level that contain this section
    /// - parameter numberOfItems:     Initial number of items in this section
    /// - parameter origin:            Origin of the section
    /// - parameter sectionWidth:      Width of the section
    /// - parameter sectionHeight:     Height of the section, may be nil
    /// - parameter dataSource:        DataSource
    ///
    /// - returns: instance of the BrickLayoutSection
    init(sectionIndex: Int, sectionAttributes: BrickLayoutAttributes?, numberOfItems: Int, origin: CGPoint, sectionWidth: CGFloat, sectionHeight: CGFloat? = nil, dataSource: BrickLayoutSectionDataSource, delegate: BrickLayoutSectionDelegate? = nil) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.sectionIndex = sectionIndex
        self.numberOfItems = numberOfItems
        self.sectionAttributes = sectionAttributes
        self.sectionWidth = sectionWidth
        self.sectionHeight = sectionHeight

        initializeFrameWithOrigin(origin, sectionWidth: sectionWidth, sectionHeight: sectionHeight)
    }


    /// Initialize the frame with the default origin and width
    ///
    /// - parameter sectionOrigin: origin
    /// - parameter sectionWidth:  width
    ///
    private func initializeFrameWithOrigin(origin: CGPoint, sectionWidth: CGFloat, sectionHeight: CGFloat?) {
        frame.origin = origin
        frame.size.width = sectionWidth
        if let sectionHeight = sectionHeight {
            frame.size.height = sectionHeight
        }
    }

    /// Set the number of items for this BrickLayoutSection
    ///
    /// - Parameters:
    ///   - addedAttributes: callback for the added attributes
    ///   - removedAttributes: callback for the removed attributes
    func setNumberOfItems(numberOfItems: Int, addedAttributes: OnAttributesUpdatedHandler?, removedAttributes: OnAttributesUpdatedHandler?) {
        guard numberOfItems != self.numberOfItems else {
            return
        }

        let difference = numberOfItems - self.numberOfItems

        if difference > 0 {
            self.numberOfItems = numberOfItems
            var startIndex = attributes.count
            updateAttributeIdentifiers(&startIndex)
            createOrUpdateCells(from: startIndex, invalidate: true, updatedAttributes: addedAttributes)
        } else {
            self.numberOfItems = numberOfItems
            while attributes.count > numberOfItems {
                let lastIndex = attributes.keys.maxElement()! // Max Element will always be available based on this logic (difference is smaller than 0, so there are values available)
                let last = attributes[lastIndex]!
                removedAttributes?(attributes: last, oldFrame: last.frame)
                
                attributes.removeValueForKey(lastIndex)
            }
            var startIndex = attributes.count
            updateAttributeIdentifiers(&startIndex)
            createOrUpdateCells(from: startIndex, invalidate: true, updatedAttributes: nil)
        }
    }

    /// Update the identifiers for the attributes
    ///
    /// - Parameter targetStartIndex: The index that should start invalidating bricks
    func updateAttributeIdentifiers(inout targetStartIndex: Int) {
        for (index, attribute) in attributes {
            let identifier = _dataSource.identifier(for: index, in: self)
            if attribute.identifier != identifier {
                targetStartIndex = min(index, targetStartIndex)
                attribute.identifier = identifier
                invalidateAttributes(attribute)
            }
        }
    }

    func appendItem(updatedAttributes: OnAttributesUpdatedHandler?) {
        numberOfItems += 1
        createOrUpdateCells(from: attributes.count, invalidate: true, updatedAttributes: updatedAttributes)
    }

    func deleteLastItem(updatedAttributes: OnAttributesUpdatedHandler?) {
        guard let lastIndex = attributes.keys.maxElement(), let last = attributes[lastIndex] else {
            return
        }
        numberOfItems -= 1
        attributes.removeValueForKey(lastIndex)
        createOrUpdateCells(from: attributes.count, invalidate: true, updatedAttributes: updatedAttributes)
        updatedAttributes?(attributes: last, oldFrame: last.frame)
    }

    func setOrigin(origin: CGPoint, fromBehaviors: Bool, updatedAttributes: OnAttributesUpdatedHandler?) {
        guard self.origin != origin else {
            return
        }

        self.frame.origin = origin
        continueCalculatingCells()

        createOrUpdateCells(from: 0, invalidate: false, updatedAttributes: updatedAttributes)
    }

    func setSectionWidth(sectionWidth: CGFloat, updatedAttributes: OnAttributesUpdatedHandler?) {
        if self.sectionWidth != sectionWidth {
            self.sectionWidth = sectionWidth
            invalidateAttributes(updatedAttributes)
        }
    }

    func invalidateAttributes(updatedAttributes: OnAttributesUpdatedHandler?) {
        createOrUpdateCells(from: 0, invalidate: true, updatedAttributes: updatedAttributes)
    }

    private func invalidateAttributes(attributes: BrickLayoutAttributes) {
        attributes.isEstimateSize = true
        attributes.originalFrame.size.width = 0
        attributes.frame.size.width = 0
    }

    func update(height height: CGFloat, at index: Int, updatedAttributes: OnAttributesUpdatedHandler?) {
        guard let brickAttributes = attributes[index] else {
            return
        }
        brickAttributes.isEstimateSize = false

        guard brickAttributes.originalFrame.height != height else {
            return
        }

        brickAttributes.originalFrame.size.height = height
        createOrUpdateCells(from: index, invalidate: false, updatedAttributes: updatedAttributes)
    }

    func invalidate(at index: Int, updatedAttributes: OnAttributesUpdatedHandler?) {
        guard let brickAttributes = attributes[index] else {
            return // Attributes not yet calculated
        }

        invalidateAttributes(brickAttributes)

        let width = widthAtIndex(index, startingAt: brickAttributes.originalFrame.minX - _dataSource.edgeInsets(in: self).left, dataSource: _dataSource)
        let size = _dataSource.size(for: brickAttributes, containedIn: CGSize(width: width, height: 0), in: self)
        brickAttributes.originalFrame.size = size
        brickAttributes.frame.size = size

        createOrUpdateCells(from: index, invalidate: false, updatedAttributes: updatedAttributes)
    }

    func changeVisibility(visibility: Bool, at index: Int, updatedAttributes: OnAttributesUpdatedHandler?) {
        guard let brickAttributes = attributes[index] else {
            return
        }

        brickAttributes.hidden = visibility

        createOrUpdateCells(from: index, invalidate: false, updatedAttributes: updatedAttributes)
    }

    private func widthAtIndex(index: Int, startingAt origin: CGFloat, dataSource: BrickLayoutSectionDataSource) -> CGFloat {
        let edgeInsets = dataSource.edgeInsets(in: self)
        let totalWidth = sectionWidth - edgeInsets.left - edgeInsets.right

        return dataSource.width(for: index, totalWidth: totalWidth, startingAt: origin, in: self)
    }

    /// Continue the calculation of attributes if needed
    ///
    /// - Parameter updatedAttributes: callback for when attributes were actually calculated
    /// - Returns: flag that indicates if more cells were calculated
    func continueCalculatingCells(updatedAttributes: OnAttributesUpdatedHandler? = nil) -> Bool {
        guard attributes.count != numberOfItems else {
            return false
        }

        let downStreamIndexPathsCount = dataSource?.downStreamIndexPaths(in: self).count ?? 0
        let nextIndex = max(0, attributes.count - downStreamIndexPathsCount)

        createOrUpdateCells(from: nextIndex, invalidate: false, updatedAttributes: updatedAttributes)
        return true
    }

    /// Main function to recalculate cells
    ///
    /// - Parameters:
    ///   - firstIndex: The index the calculation needs to start from (the main reason is to just calculate the next cells
    ///   - invalidate: Identifies if the attributes need to be invalidated (reset height etc)
    ///   - updatedAttributes: Callback for the attributes that have been updated
    private func createOrUpdateCells(from firstIndex: Int, invalidate: Bool, updatedAttributes: OnAttributesUpdatedHandler?) {

        guard let dataSource = dataSource else {
            return
        }

        let edgeInsets = _dataSource.edgeInsets(in: self)
        let inset = dataSource.inset(in: self)

        let startAndMaxY = findStartOriginAndMaxY(for: firstIndex, edgeInsets: edgeInsets, inset: inset, invalidate: invalidate)

        var maxY: CGFloat = startAndMaxY.1
        var x: CGFloat = startAndMaxY.0.x
        var y: CGFloat = startAndMaxY.0.y

        let frameOfInterest = dataSource.frameOfInterest

        let numberOfItems = self.numberOfItems

        for index in firstIndex..<numberOfItems {
            // Create or Update an attribute at an index. If returned true, continue calculating. If not, break
            if !createOrUpdateAttribute(at: index, with: dataSource, x: &x, y: &y, maxY: &maxY, force: false, invalidate: invalidate, frameOfInterest: frameOfInterest, updatedAttributes: updatedAttributes) {
                break
            }
        }

        // If rows need to be aligned, make sure the previous lines are checked
        handleRow(for: attributes.count - 1, maxHeight: maxY - y, updatedAttributes: updatedAttributes)

        // Downstream IndexPaths. Just add these attributes at the end of the stack.
        // The idea is to have them available for behaviors, but not visible
        let downStreamIndexPaths = dataSource.downStreamIndexPaths(in: self)
        for indexPath in downStreamIndexPaths {
            guard indexPath.section == sectionIndex else {
                continue
            }
            if let downstreamAttributes = self.attributes[indexPath.item] {
                // If the attribute already exists, but not in the current frameset, push it off screen
                if indexPath.item >= attributes.count {
                    downstreamAttributes.frame.origin.y = maxY
                    downstreamAttributes.originalFrame.origin.y = maxY
                }
            } else {
                // create the attribute, so it's available for the behaviors to pick it up
                createOrUpdateAttribute(at: indexPath.item, with: dataSource, x: &x, y: &y, maxY: &maxY, force: true, invalidate: invalidate, frameOfInterest: frameOfInterest, updatedAttributes: updatedAttributes)
            }
        }

        // Frame Height
        var frameHeight: CGFloat = 0
        if let first = attributes[0] {
            let percentageDone = CGFloat(attributes.count) / CGFloat(numberOfItems)

            switch dataSource.scrollDirection {
            case .Horizontal:
                frameHeight = maxY + edgeInsets.bottom
                if percentageDone < 1 {
                    let width = (x - first.originalFrame.origin.x)
                    x = (width / percentageDone)
                }
            case .Vertical:
                // If not all attributes are calculated, we need to estimate how big the section will be
                let height = (maxY - first.originalFrame.origin.y) + inset
                let frameHeightA = (height / percentageDone) - inset + edgeInsets.bottom + edgeInsets.top

                let frameHeightB = (maxY - first.originalFrame.origin.y) + edgeInsets.bottom + edgeInsets.top
                if percentageDone < 1 {
                    frameHeight = frameHeightA
                } else {
                    frameHeight = frameHeightB
                }
            }

            //If the height is less than the edgeinsets, clearly nothing is calculated. Set it to 0
            if frameHeight <= edgeInsets.bottom + edgeInsets.top {
                frameHeight = 0
            }

        } else if numberOfItems > 0 {
            // there are no attributes calculated, but there will (because numberOfItems is larger than zero)
            // set a dummy height of 1 to not be set invisible
            frameHeight = 1 + edgeInsets.bottom + edgeInsets.top
        }

        frame.size.height = frameHeight

        switch dataSource.scrollDirection {
        case .Vertical:
            frame.size.width = sectionWidth
        case .Horizontal:
            x -= inset // Take off the inset as this is added to the end
            frame.size.width = x + edgeInsets.right
        }


        if brickDebug {
            printAttributes()
        }
    }

    /// To continue calculating, it needs to start from a certain origin. To make sure that the rows are
    ///
    /// - Parameters:
    ///   - index: start index
    ///   - edgeInsets
    ///   - inset
    /// - Returns: a tuple of the start origin and maxY
    private func findStartOriginAndMaxY(for index: Int, edgeInsets: UIEdgeInsets, inset: CGFloat, invalidate: Bool) -> (CGPoint, CGFloat) {
        let create = attributes.isEmpty

        let startFrame = sectionAttributes?.originalFrame ?? frame
        var startOrigin = CGPoint(x: startFrame.origin.x + edgeInsets.left, y: startFrame.origin.y + edgeInsets.top)
        var maxY = startFrame.origin.y

        if !create {
            if index > 0 {
                var originY: CGFloat?
                if let currentAttribute = attributes[index] {
                    originY = currentAttribute.originalFrame.minY
                }

                var startOriginFound = false
                for index in (index-1).stride(to: -1, by: -1) {
                    if let nextAttribute = attributes[index] where !nextAttribute.hidden {
                        if originY == nil {
                            originY = nextAttribute.originalFrame.minY
                        }
                        if !startOriginFound {
                            startOrigin = CGPoint(x: nextAttribute.originalFrame.maxX + inset, y: nextAttribute.originalFrame.origin.y)
                            startOriginFound = true
                        }

                        maxY = max(maxY, nextAttribute.originalFrame.maxY)
                        if startOrigin.y != nextAttribute.originalFrame.minY {
                            break
                        }
                    }
                }
            } else if !invalidate {
                // Check the first visible attribute
                for index in 0..<index {
                    if let first = attributes[index] where !first.hidden  {
                        maxY = first.originalFrame.maxY
                        startOrigin = first.originalFrame.origin
                    }
                }
            }
        }

        return (startOrigin, maxY)
    }

    func handleRow(for index: Int, maxHeight: CGFloat, updatedAttributes: OnAttributesUpdatedHandler?) {
        if _dataSource.scrollDirection == .Vertical {
            updateHeightAndAlignForRowWithStartingIndex(index, maxHeight: maxHeight, updatedAttributes: updatedAttributes)
        }
    }

    /// Update the height for a row starting at a given index
    func updateHeightAndAlignForRowWithStartingIndex(index: Int, maxHeight: CGFloat, updatedAttributes: OnAttributesUpdatedHandler?) {

        var rowWidthWithoutInsets: CGFloat = 0 // Keep track of all the widths, so we can calculate the correct inset for `Justified`-alignment
        let rowAttributes: [BrickLayoutAttributes] = calculateRowAttributes(startingAt: index, rowWidthWithoutInsets: &rowWidthWithoutInsets) // Keep track of all attributes in this row

        guard rowAttributes.count > 0 else {
            return
        }

        let edgeInsets = _dataSource.edgeInsets(in: self)
        let totalSectionWidth = (sectionWidth - edgeInsets.right - edgeInsets.left) // Total width of the section minus the insets
        let totalRowWidth = rowAttributes.last!.originalFrame.maxX - rowAttributes.first!.originalFrame.minX // Total width of the bricks (with insets, as supposed to rowWidths)

        let inset: CGFloat
        let numberOfInsets: CGFloat = CGFloat(rowAttributes.count-1)
        let alignment = _dataSource.aligment(in: self)

        switch alignment.horizontal {
        case .Justified:
            // Distribute insets evenly
            inset = (totalSectionWidth - rowWidthWithoutInsets) / numberOfInsets
        default:
            // Distribute the insets the way they were
            inset = (totalRowWidth - rowWidthWithoutInsets) / numberOfInsets
        }

        // Get the x value of the first brick
        let startX: CGFloat
        switch alignment.horizontal {
        case .Center: startX = (totalSectionWidth - totalRowWidth) / 2 // Start from the middle minus the middle of the bricks total width
        case .Right: startX = totalSectionWidth - totalRowWidth // Start at the end of the section minus the total of the bricks total width
        default: startX = 0 // Start at zero
        }

        updateRow(for: rowAttributes, with: maxHeight, startingAt: startX, edgeInsets: edgeInsets, inset: inset, updatedAttributes: updatedAttributes)
    }

    /// Update the attributes within the row
    private func updateRow(for rowAttributes: [BrickLayoutAttributes], with maxHeight: CGFloat, startingAt startX: CGFloat, edgeInsets: UIEdgeInsets, inset: CGFloat, updatedAttributes: OnAttributesUpdatedHandler?) {
        // Check if the height need to be aligned
        let alignRowHeights = _dataSource.isAlignRowHeights(in: self)

        // start at the startX + insets + origin
        var x: CGFloat = edgeInsets.left + origin.x + startX

        // Iterate over the attributes (starting from the first one) and update each frame
        for brickAttributes in rowAttributes {
            let oldFrame = brickAttributes.frame
            var newFrame = oldFrame
            if alignRowHeights {
                newFrame.size.height = maxHeight
            }
            newFrame.origin.x = x

            let offsetY: CGFloat
            switch _dataSource.aligment(in: self).vertical {
            case .Top: offsetY = 0
            case .Center: offsetY = (maxHeight / 2) - (newFrame.height / 2)
            case .Bottom: offsetY = maxHeight - newFrame.height
            }

            newFrame.origin.y += offsetY
            if newFrame != oldFrame {
                brickAttributes.frame = newFrame
                updatedAttributes?(attributes: brickAttributes, oldFrame: oldFrame)
                _dataSource.prepareForSizeCalculation(for: brickAttributes, containedIn: brickAttributes.frame.width, origin: brickAttributes.frame.origin, invalidate: false, in: self, updatedAttributes: updatedAttributes)
            }
            x += oldFrame.width + inset
        }

    }

    /// Calculate the row attributes
    ///
    /// - Parameters:
    ///   - startingIndex: index of the attributes within the row
    ///   - rowWidthWithoutInsets: variable to indicate what the row width is without insets
    /// - Returns: array of all attributes within the row
    private func calculateRowAttributes(startingAt startingIndex: Int, inout rowWidthWithoutInsets: CGFloat) -> [BrickLayoutAttributes] {
        guard let brickAttributes = self.attributes[startingIndex] else {
            return []
        }

        var currentIndex = startingIndex
        let y = brickAttributes.originalFrame.origin.y

        var rowAttributes: [BrickLayoutAttributes] = [] // Keep track of all attributes in this row

        // Count down until attributes are found with a lower Y-origin
        while currentIndex >= 0 {
            guard let brickAttributes = attributes[currentIndex] where !brickAttributes.hidden else {
                currentIndex -= 1
                continue
            }
            if brickAttributes.originalFrame.origin.y != y {
                break // Done, no more attributes on this row
            }

            rowAttributes.insert(brickAttributes, atIndex: 0) // insert at the front, so the attributes are sorted by lowest first
            rowWidthWithoutInsets += brickAttributes.originalFrame.width
            currentIndex -= 1
        }

        return rowAttributes
    }

    func printAttributes() {
        guard attributes.count < 100 else {
            // Prevent that the "Huge" test aren't taking forever to complete
            return
        }
        print("\n")
        print("Attributes for section \(sectionIndex) in \(dataSource)")
        print("Number of attributes: \(attributes.count) in \(_dataSource.frameOfInterest)")
        print("Frame: \(self.frame)")
        let keys = attributes.keys.sort(<)
        for key in keys {
            print("\(key): \(attributes[key]!)")
        }
    }

    /// Create or update 1 cell
    /// - Returns: flag if the cell was created
    func createOrUpdateAttribute(at index: Int, with dataSource: BrickLayoutSectionDataSource, inout x: CGFloat, inout y: CGFloat, inout maxY: CGFloat, force: Bool, invalidate: Bool, frameOfInterest: CGRect, updatedAttributes: OnAttributesUpdatedHandler?) -> Bool {
        let edgeInsets = dataSource.edgeInsets(in: self)
        let inset = dataSource.inset(in: self)

        let indexPath = NSIndexPath(forItem: index, inSection: sectionIndex)

        var brickAttributes: BrickLayoutAttributes! = attributes[index]
        let existingAttribute: Bool = brickAttributes != nil

        var width = widthAtIndex(index, startingAt: x - edgeInsets.left - origin.x, dataSource: dataSource)

        let shouldBeOnNextRow: Bool
        switch dataSource.scrollDirection {
        case .Horizontal: shouldBeOnNextRow = false
        case .Vertical:
            let leftOverSpace = (sectionWidth - edgeInsets.right) - (x + width - origin.x)
            shouldBeOnNextRow = leftOverSpace < 0 && fabs(leftOverSpace) > PrecisionAccuracy
        }

        var nextY: CGFloat = y
        var nextX: CGFloat = x
        if shouldBeOnNextRow {
            handleRow(for: index - 1, maxHeight: maxY - nextY, updatedAttributes: updatedAttributes)

            if maxY > nextY  {
                nextY = maxY + inset
            }
            nextX = origin.x + edgeInsets.left
        }

        let offsetX: CGFloat
        let offsetY: CGFloat
        if let sectionAttributes = sectionAttributes where sectionAttributes.originalFrame != nil {
            offsetX = sectionAttributes.frame.origin.x - sectionAttributes.originalFrame.origin.x
            offsetY = sectionAttributes.frame.origin.y - sectionAttributes.originalFrame.origin.y
        } else {
            offsetX = 0
            offsetY = 0
        }

        nextX += offsetX
        nextY += offsetY

        let nextOrigin = CGPoint(x: nextX, y: nextY)

        let restrictedScrollDirection: Bool // For now, only restrict if scrolling vertically (will update later for Horizontal)
        switch dataSource.scrollDirection {
        case .Vertical: restrictedScrollDirection = true
        case .Horizontal: restrictedScrollDirection = false
        }

        if !existingAttribute && !frameOfInterest.contains(nextOrigin) && !force && restrictedScrollDirection {
            return false
        }

        nextX -= offsetX
        nextY -= offsetY

        x = nextX
        y = nextY

        let cellOrigin = nextOrigin

        let oldFrame:CGRect?
        let oldOriginalFrame: CGRect?

        if existingAttribute {
            brickAttributes = attributes[index]
            oldFrame = brickAttributes.frame
            oldOriginalFrame = brickAttributes.originalFrame

            if invalidate {
                invalidateAttributes(brickAttributes)
                brickAttributes.isEstimateSize = dataSource.isEstimate(for: brickAttributes, in: self)
            }
        } else {
            brickAttributes = createAttribute(at: indexPath, with: dataSource)
            oldFrame = nil
            oldOriginalFrame = nil
        }
        brickAttributes.identifier = dataSource.identifier(for: indexPath.item, in: self)

        let height: CGFloat

        // Prepare the datasource that size calculation will happen
        brickAttributes.frame.origin = cellOrigin
        brickAttributes.originalFrame = brickAttributes.frame
        dataSource.prepareForSizeCalculation(for: brickAttributes, containedIn: width, origin: cellOrigin, invalidate: invalidate, in: self, updatedAttributes: updatedAttributes)

        if let brickFrame = oldOriginalFrame where !invalidate {
            height = brickFrame.height
            width = brickFrame.width
        } else {
            let size = dataSource.size(for: brickAttributes, containedIn: CGSize(width: width, height: self.sectionHeight ?? 0), in: self)
            height = size.height
            width = size.width
        }

        var brickFrame = CGRect(origin: cellOrigin, size: CGSize(width: width, height: height))

        brickAttributes.frame = brickFrame
        brickFrame.origin.x -= offsetX
        brickFrame.origin.y -= offsetY
        brickAttributes.originalFrame = brickFrame

        if !existingAttribute {
            delegate?.brickLayoutSection(self, didCreateAttributes: brickAttributes)
        }

        updatedAttributes?(attributes: brickAttributes, oldFrame: oldFrame)

        let sectionIsHidden = sectionAttributes?.hidden ?? false
        let brickIsHiddenOrHasNoHeight = height <= 0 || brickAttributes.hidden

        if sectionIsHidden || !brickIsHiddenOrHasNoHeight {
            x = brickFrame.maxX + inset
            maxY = max(brickAttributes.originalFrame.maxY, maxY)
        }

        brickAttributes.alpha = brickAttributes.hidden ? 0 : 1

        return true
    }

    func createAttribute(at indexPath: NSIndexPath, with dataSource: BrickLayoutSectionDataSource) -> BrickLayoutAttributes {
        let brickAttributes = BrickLayoutAttributes(forCellWithIndexPath: indexPath)

        attributes[indexPath.item] = brickAttributes
        brickAttributes.isEstimateSize = dataSource.isEstimate(for: brickAttributes, in: self)
        return brickAttributes
    }
}

// MARK: - Binary search for elements
extension BrickLayoutSection {

    func registerUpdatedAttributes(attributes: BrickLayoutAttributes) {
        if attributes.frame != attributes.originalFrame {
            behaviorAttributesIndexPaths.insert(attributes.indexPath)
        } else {
            behaviorAttributesIndexPaths.remove(attributes.indexPath)
        }
    }

    func layoutAttributesForElementsInRect(rect: CGRect, with zIndexer: BrickZIndexer) -> [UICollectionViewLayoutAttributes] {
        var attributes = [UICollectionViewLayoutAttributes]()

        if self.attributes.isEmpty {
            return attributes
        }

        // Find an index that is pretty close to the top of the rect
        let closestIndex: Int
        switch _dataSource.scrollDirection {
        case .Vertical: closestIndex = findEstimatedClosestIndexVertical(in: rect)
        case .Horizontal: closestIndex = findEstimatedClosestIndexHorizontal(in: rect)
        }

        // Closure that checks if an attribute is within the rect and adds it to the attributes to return
        // Returns true if the frame is within the rect
        let frameCheck: (index: Int) -> Bool = { index in
            guard let brickAttributes = self.attributes[index] else {
                return false
            }
            if rect.intersects(brickAttributes.frame) {
                let hasZeroHeight = brickAttributes.frame.height == 0 || brickAttributes.frame.width == 0
                if !brickAttributes.hidden && !hasZeroHeight && !attributes.contains(brickAttributes) {
                    brickAttributes.setAutoZIndex(zIndexer.zIndex(for: brickAttributes.indexPath))
                    attributes.append(brickAttributes)
                }
                return true
            } else {
                // if the frame is not the same as the originalFrame, continue checking because the attribute could be offscreen
                return brickAttributes.frame != brickAttributes.originalFrame
            }

        }

        // Go back to see if previous attributes are not closer
        for index in (closestIndex - 1).stride(to: -1, by: -1) {
            if !frameCheck(index: index) {
                // Check if the next attribute is on the same row. If so, continue checking
                let nextAttributeIsOnSameRow = index != 0 && self.attributes[index]!.frame.minY == self.attributes[index - 1]!.frame.minY

                if !nextAttributeIsOnSameRow {
                    break
                }
            }
        }

        // Go forward until an attribute is outside or the rect
        for index in closestIndex..<self.attributes.count {
            if !frameCheck(index: index) {
                break
            }
        }

        // Verify the behaviors attributes and check if they are in the frame as well
        for indexPath in behaviorAttributesIndexPaths {
            frameCheck(index: indexPath.item)
        }

        return attributes
    }

    func findEstimatedClosestIndexVertical(in rect: CGRect) -> Int {
        return findEstimatedClosestIndex(in: rect, referencePoint: { (frame) -> CGFloat in
            return frame.minY
        })
    }

    func findEstimatedClosestIndexHorizontal(in rect: CGRect) -> Int {
        return findEstimatedClosestIndex(in: rect, referencePoint: { (frame) -> CGFloat in
            return frame.minX
        })
    }
    
    func findEstimatedClosestIndex(in rect: CGRect, referencePoint: (forFrame: CGRect) -> CGFloat) -> Int {
        let min = referencePoint(forFrame: rect)
        
        var complexity = 0
        var lowerBound = 0
        var upperBound = attributes.count
        while lowerBound < upperBound {
            complexity += 1
            let midIndex = lowerBound + (upperBound - lowerBound) / 2
            guard let frame = attributes[midIndex]?.frame else {
                break
            }
            if referencePoint(forFrame: frame) < min {
                lowerBound = midIndex + 1
            } else {
                upperBound = midIndex
            }
        }
        return lowerBound
    }
}

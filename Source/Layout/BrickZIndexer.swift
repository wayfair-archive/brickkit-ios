//
//  BrickZIndexer.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 11/15/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation

/// Behavior that determines how the zIndex of bricks are layed out
public enum BrickLayoutZIndexBehavior {
    case TopDown // The cell at the top has the highest zIndex. Ideally for layouts that needs `Sticky` cells where the lower cells need to go below the top cells
    case BottomUp // The cell at the bottom has the highest zIndex. Ideally for layouts where the lower cells are above the higher cells

    /// Get the zIndex from an array of SectionRanges
    ///
    /// - Parameters:
    ///   - ranges: array of ranges
    ///   - index: the index for which the zIndex needs to be returned for
    /// - Returns: the zIndex for the given index
    internal func zIndexFromRanges(ranges: [SectionRange], index: Int) -> Int {
        if let range = ranges.filter({$0.range.contains(index)}).first {
            return self.zIndexForRange(range, index: index)
        }

        return 0
    }

    /// Get the zIndex based on a range
    ///
    /// - Parameters:
    ///   - range: range
    ///   - index: the index for which the zIndex needs to be returned for
    /// - Returns: the zIndex for the given index
    private func zIndexForRange(range: SectionRange, index: Int) -> Int {
        let diff = index - range.range.startIndex
        switch self {
        case .BottomUp:
            return range.startIndex + diff
        case .TopDown:
            return range.startIndex - diff
        }
    }

    /// Flat that indicates if the range after a given index needs to be updated or not
    /// If false, the range of the given index is updated
    private var handleNextRangeWhileAppending: Bool {
        switch self {
        case .BottomUp:
            return true
        case .TopDown:
            return false
        }
    }

    /// Returns the updated start index for a given number of items
    private func updateStartIndex(startIndex: Int, for numberOfItems: Int) -> Int {
        switch self {
        case .BottomUp:
            return startIndex + numberOfItems
        case .TopDown:
            return startIndex - numberOfItems
        }
    }

    /// Returns the start index for given zIndex of the parent section
    private func startIndex(for zIndex: Int) -> Int {
        switch self {
        case .BottomUp:
            return zIndex + 1
        case .TopDown:
            return zIndex
        }
    }

    /// Flag that indicates if a indexPath should split a range in half
    private func shouldSplit(for indexPath: NSIndexPath, in range: Range<Int>) -> Bool {
        guard range.count > 1 else {
            return false
        }
        switch self {
        case .TopDown: return indexPath.item < range.endIndex
        case .BottomUp: return indexPath.item < range.endIndex - 1
        }
    }

    /// Split a range into two with the correct indexes
    private func split(at index: Int, in sectionRange: SectionRange, with numberOfItems: Int, sectionStartIndex: Int) -> (SectionRange, SectionRange) {
        let startIndex = sectionRange.startIndex
        let range = sectionRange.range

        let range1: Range<Int>
        let range2: Range<Int>
        let startIndex1: Int
        let startIndex2: Int

        switch self {
        case .BottomUp:
            range1 = range.startIndex..<index + 1
            range2 = index + 1..<range.endIndex
            startIndex1 = startIndex
            startIndex2 = startIndex + (index - range.startIndex) + numberOfItems + 1
        case .TopDown:
            range1 = range.startIndex..<index
            range2 = index..<range.endIndex
            startIndex1 = startIndex // + numberOfItems
            startIndex2 = sectionStartIndex - numberOfItems
        }

        return (SectionRange(range: range1, startIndex: startIndex1), SectionRange(range: range2, startIndex: startIndex2))
    }

    func updateRange(at index: Int, in section: Int, for indexer: BrickZIndexer, with numberOfItems: Int) {
        switch self {
        case .TopDown:
            indexer.sectionRanges[section][index].startIndex -= numberOfItems
        default:
            break
        }
    }

    /// Finalize the reset procedure
    func finalizeReset(indexer: BrickZIndexer) {
        switch self {
        case .TopDown:
            for (section, ranges) in indexer.sectionRanges.enumerate() {
                for rangeIndex in 0..<ranges.count {
                    indexer.sectionRanges[section][rangeIndex].startIndex += indexer.maxZIndex
                }
            }
        default: break
        }

    }

}

// Mark: - SectionRange

/// Container object that holds a range and the start zIndex
struct SectionRange {
    var range: Range<Int>
    var startIndex: Int
}

extension SectionRange: Equatable { }

func ==(lhs: SectionRange, rhs: SectionRange) -> Bool {
    return lhs.startIndex == rhs.startIndex && lhs.range == rhs.range
}

/// Class that is used to calculate the zIndex of a given indexPath
class BrickZIndexer {

    /// Default behavior
    var zIndexBehavior: BrickLayoutZIndexBehavior = .TopDown

    /// The maximum zIndex for a given layout
    var maxZIndex: Int = 0

    /// Holds the range-differences, so each section can be determined
    var sectionRanges: [[SectionRange]] = []

    func reset(for layout: BrickFlowLayout) {
        zIndexBehavior = layout.zIndexBehavior
        sectionRanges = []
        maxZIndex = 0

        guard let dataSource = layout.dataSource, let collectionView = layout.collectionView else {
            return
        }

        var zIndex = 0
        for section in 0..<collectionView.numberOfSections() {
            let numberOfItems = collectionView.numberOfItemsInSection(section)
            maxZIndex += numberOfItems
            let sectionRange: Range<Int> = 0..<numberOfItems
            let sectionStartIndex: Int
            if let indexPath = dataSource.brickLayout(layout, indexPathForSection: section) {

                let indexPathZIndex = self.zIndex(for: indexPath)
                sectionStartIndex = zIndexBehavior.startIndex(for: indexPathZIndex)

                let ranges = sectionRanges[indexPath.section]

                    // Let's find the range of this section in its parent and split the ranges there
                    let sectionRange = ranges.filter({ (sectionRange) -> Bool in
                        return sectionRange.range.contains(indexPath.row)
                    }).first! // We can force unwrap, because this index will always be found in the ranges
                    let i = ranges.indexOf(sectionRange)! // Because the range was found, the index is also there

                    if zIndexBehavior.shouldSplit(for: indexPath, in: sectionRange.range) { // Only spit if it can be split...
                        let newRanges = zIndexBehavior.split(at: indexPath.item, in: sectionRange, with: numberOfItems, sectionStartIndex: sectionStartIndex)
                        sectionRanges[indexPath.section].removeAtIndex(i)
                        sectionRanges[indexPath.section].insert(newRanges.0, atIndex: i)
                        sectionRanges[indexPath.section].insert(newRanges.1, atIndex: i+1)
                    } else {
                        zIndexBehavior.updateRange(at: i, in: indexPath.section, for: self, with: numberOfItems)
                }

                    updateRanges(to: indexPath.section, with: numberOfItems, dataSource: dataSource, layout: layout)
            } else {
                sectionStartIndex = 0
            }

            sectionRanges.append([SectionRange(range: sectionRange, startIndex: sectionStartIndex)])

            zIndex += 1
        }
        maxZIndex -= 1

        zIndexBehavior.finalizeReset(self)
    }

    func zIndex(for indexPath: NSIndexPath) -> Int {
        let section = indexPath.section
        guard section < sectionRanges.count else {
            return 0
        }
        let ranges = sectionRanges[section]
        return zIndexBehavior.zIndexFromRanges(ranges, index: indexPath.item)
    }

// Mark: - Private methods

    /// Update the count of the ranges to the parent section(s) of an inserted section
    private func updateRanges(to section: Int, with numberOfItems: Int, dataSource: BrickLayoutDataSource, layout: BrickFlowLayout) {
        if let indexPath = dataSource.brickLayout(layout, indexPathForSection: section) {
            let ranges = sectionRanges[indexPath.section]
                var nextRange = false
                for i in 0..<ranges.count {
                    let sectionRange = ranges[i]

                    if nextRange {
                        updateRange(at: i, for: indexPath.section, with: numberOfItems, dataSource: dataSource, layout: layout)
                        return
                    }

                    if sectionRange.range.contains(indexPath.row) {
                        if zIndexBehavior.handleNextRangeWhileAppending {
                            nextRange = true
                        } else {
                            updateRange(at: i, for: indexPath.section, with: numberOfItems, dataSource: dataSource, layout: layout)
                            return
                        }
                    }
                }

        }
    }

    /// Update the start index of a range
    private func updateRange(at index: Int, for section: Int, with numberOfItems: Int, dataSource: BrickLayoutDataSource, layout: BrickFlowLayout) {
        sectionRanges[section][index].startIndex = zIndexBehavior.updateStartIndex(sectionRanges[section][index].startIndex, for: numberOfItems)
        updateRanges(to: section, with: numberOfItems, dataSource: dataSource, layout: layout)
    }
}

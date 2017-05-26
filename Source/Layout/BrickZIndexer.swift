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
    case topDown // The cell at the top has the highest zIndex. Ideally for layouts that needs `Sticky` cells where the lower cells need to go below the top cells
    case bottomUp // The cell at the bottom has the highest zIndex. Ideally for layouts where the lower cells are above the higher cells

    /// Get the zIndex from an array of SectionRanges
    ///
    /// - Parameters:
    ///   - ranges: array of ranges
    ///   - index: the index for which the zIndex needs to be returned for
    /// - Returns: the zIndex for the given index
    internal func zIndexFromRanges(_ ranges: [SectionRange], index: Int) -> Int {
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
    fileprivate func zIndexForRange(_ range: SectionRange, index: Int) -> Int {
        let diff = index - range.range.startIndex
        switch self {
        case .bottomUp:
            return range.startIndex + diff
        case .topDown:
            return range.startIndex - diff
        }
    }

    /// Flat that indicates if the range after a given index needs to be updated or not
    /// If false, the range of the given index is updated
    fileprivate var handleNextRangeWhileAppending: Bool {
        switch self {
        case .bottomUp:
            return true
        case .topDown:
            return false
        }
    }

    /// Returns the updated start index for a given number of items
    fileprivate func updateStartIndex(_ startIndex: Int, for numberOfItems: Int) -> Int {
        switch self {
        case .bottomUp:
            return startIndex + numberOfItems
        case .topDown:
            return startIndex - numberOfItems
        }
    }

    /// Returns the start index for given zIndex of the parent section
    fileprivate func startIndex(for zIndex: Int) -> Int {
        switch self {
        case .bottomUp:
            return zIndex + 1
        case .topDown:
            return zIndex
        }
    }

    /// Flag that indicates if a indexPath should split a range in half
    fileprivate func shouldSplit(for indexPath: IndexPath, in range: CountableRange<Int>) -> Bool {
        guard range.count > 1 else {
            return false
        }
        switch self {
        case .topDown: return indexPath.item < range.upperBound
        case .bottomUp: return indexPath.item < range.upperBound - 1
        }
    }

    /// Split a range into two with the correct indexes
    fileprivate func split(at index: Int, in sectionRange: SectionRange, with numberOfItems: Int, sectionStartIndex: Int) -> (SectionRange, SectionRange) {
        let startIndex = sectionRange.startIndex
        let range = sectionRange.range

        let range1: CountableRange<Int>
        let range2: CountableRange<Int>
        let startIndex1: Int
        let startIndex2: Int

        switch self {
        case .bottomUp:
            range1 = range.startIndex..<index + 1
            range2 = index + 1..<range.endIndex
            startIndex1 = startIndex
            startIndex2 = startIndex + (index - range.startIndex) + numberOfItems + 1
        case .topDown:
            range1 = range.startIndex..<index
            range2 = index..<range.endIndex
            startIndex1 = startIndex // + numberOfItems
            startIndex2 = sectionStartIndex - numberOfItems
        }

        return (SectionRange(range: range1, startIndex: startIndex1), SectionRange(range: range2, startIndex: startIndex2))
    }

    func updateRange(at index: Int, in section: Int, for indexer: BrickZIndexer, with numberOfItems: Int) {
        switch self {
        case .topDown:
            indexer.sectionRanges[section][index].startIndex -= numberOfItems
        default:
            break
        }
    }

    /// Finalize the reset procedure
    func finalizeReset(_ indexer: BrickZIndexer) {
        switch self {
        case .topDown:
            for (section, ranges) in indexer.sectionRanges.enumerated() {
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
    var range: CountableRange<Int>
    var startIndex: Int
}

extension SectionRange: Equatable { }

func ==(lhs: SectionRange, rhs: SectionRange) -> Bool {
    return lhs.startIndex == rhs.startIndex && lhs.range == rhs.range
}

/// Class that is used to calculate the zIndex of a given indexPath
class BrickZIndexer {

    /// Default behavior
    var zIndexBehavior: BrickLayoutZIndexBehavior = .topDown

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
        for section in 0..<collectionView.numberOfSections {
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            maxZIndex += numberOfItems
            let sectionRange: CountableRange<Int> = 0..<numberOfItems
            let sectionStartIndex: Int
            if let indexPath = dataSource.brickLayout(layout, indexPathFor: section) {

                let indexPathZIndex = self.zIndex(for: indexPath, withOffset: false)
                sectionStartIndex = zIndexBehavior.startIndex(for: indexPathZIndex)

                let ranges = sectionRanges[indexPath.section]

                    // Let's find the range of this section in its parent and split the ranges there
                    let sectionRange = ranges.filter({ (sectionRange) -> Bool in
                        return sectionRange.range.contains(indexPath.row)
                    }).first! // We can force unwrap, because this index will always be found in the ranges
                    let i = ranges.index(of: sectionRange)! // Because the range was found, the index is also there

                    if zIndexBehavior.shouldSplit(for: indexPath, in: sectionRange.range) { // Only spit if it can be split...
                        let newRanges = zIndexBehavior.split(at: indexPath.item, in: sectionRange, with: numberOfItems, sectionStartIndex: sectionStartIndex)
                        sectionRanges[indexPath.section].remove(at: i)
                        sectionRanges[indexPath.section].insert(newRanges.0, at: i)
                        sectionRanges[indexPath.section].insert(newRanges.1, at: i+1)
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

    /// Gets the zIndex of a given indexPath
    ///
    /// - Parameters:
    ///   - indexPath: indexPath
    ///   - withOffset: flag that indicates if the zIndex needs to be offset (substract the maxZIndex)
    func zIndex(for indexPath: IndexPath, withOffset: Bool = true) -> Int {
        let section = indexPath.section
        guard section < sectionRanges.count else {
            return 0
        }
        let ranges = sectionRanges[section]

        // Offset with maxZIndex, because BrickCollectionView is using `self.layer.zPosition`
        // But because this affects how things are layed out with normal UIViews (like scrolling indicator)
        // the zIndex is now offset by the maxZIndex (so 0->20 is now -20->0)
        return zIndexBehavior.zIndexFromRanges(ranges, index: indexPath.item) - (withOffset ? maxZIndex : 0)
    }

// Mark: - Private methods

    /// Update the count of the ranges to the parent section(s) of an inserted section
    fileprivate func updateRanges(to section: Int, with numberOfItems: Int, dataSource: BrickLayoutDataSource, layout: BrickFlowLayout) {
        if let indexPath = dataSource.brickLayout(layout, indexPathFor: section) {
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
    fileprivate func updateRange(at index: Int, for section: Int, with numberOfItems: Int, dataSource: BrickLayoutDataSource, layout: BrickFlowLayout) {
        sectionRanges[section][index].startIndex = zIndexBehavior.updateStartIndex(sectionRanges[section][index].startIndex, for: numberOfItems)
        updateRanges(to: section, with: numberOfItems, dataSource: dataSource, layout: layout)
    }
}

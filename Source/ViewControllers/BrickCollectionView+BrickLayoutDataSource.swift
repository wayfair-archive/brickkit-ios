//
//  BrickViewController+BrickLayoutDataSource.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/3/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

extension BrickCollectionView: BrickLayoutDataSource {
    
    public func brickLayout(_ layout: BrickLayout, widthForItemAt indexPath: IndexPath, totalWidth: CGFloat, widthRatio: CGFloat, startingAt origin: CGFloat) -> CGFloat {
        let inset = self.brickLayout(layout, insetFor: indexPath.section)
        let widthDimension = self.brick(at: indexPath).size.width

        let dimension = widthDimension.dimension(withValue: totalWidth)

        switch dimension {
        case .ratio(let ratio): return BrickUtils.calculateWidth(for: ratio, widthRatio: widthRatio, totalWidth: totalWidth, inset: inset)
        default: return dimension.value(for: totalWidth, startingAt: origin)
        }
    }

    public func brickLayout(_ layout: BrickLayout, isItemHiddenAt indexPath: IndexPath) -> Bool {
        return self.brick(at: indexPath).isHidden
    }

    public func brickLayout(_ layout: BrickLayout, isEstimatedHeightFor indexPath: IndexPath) -> Bool {
        let brick = self.brick(at: indexPath)
        if brick is BrickSection {
            return false
        }

        return brick.size.height.isEstimate(withValue: nil)
    }

    public func brickLayout(_ layout: BrickLayout, estimatedHeightForItemAt indexPath: IndexPath, containedIn width: CGFloat) -> CGFloat {
        let brick = self.brick(at: indexPath)
        if brick is BrickSection {
            return 0
        }

        // If the brick height is an estimate, check if the cell is on screen
        // If so, calculate the height directly, so the estimation is correct from the get-go
        if brick.size.height.isEstimate(withValue: nil), let brickCell = self.cellForItem(at: indexPath) as? BrickCell {
            return brickCell.heightForBrickView(withWidth: width)
        }

        let heightDimension = brick.size.height
        return heightDimension.value(for: width, startingAt: 0)
    }

    public func brickLayout(_ layout: BrickLayout, edgeInsetsFor section: Int) -> UIEdgeInsets {
        guard
            let indexPath = self.section.indexPathFor(section, in: collectionInfo),
            let brickSection = self.brick(at:indexPath) as? BrickSection
            else {
                return UIEdgeInsets.zero
        }
        return brickSection.edgeInsets
    }

    public func brickLayout(_ layout: BrickLayout, insetFor section: Int) -> CGFloat {
        guard
            let indexPath = self.section.indexPathFor(section, in: collectionInfo),
            let brickSection = self.brick(at:indexPath) as? BrickSection
            else {
                return 0
        }
        return brickSection.inset
    }

    public func brickLayout(_ layout: BrickLayout, isAlignRowHeightsFor section: Int) -> Bool {
        guard
            let indexPath = self.section.indexPathFor(section, in: collectionInfo),
            let brickSection = self.brick(at:indexPath) as? BrickSection
            else {
                return false
        }
        return brickSection.alignRowHeights
    }

    public func brickLayout(_ layout: BrickLayout, alignmentFor section: Int) -> BrickAlignment {
        guard
            let indexPath = self.section.indexPathFor(section, in: collectionInfo),
            let brickSection = self.brick(at:indexPath) as? BrickSection
            else {
                return BrickAlignment(horizontal: .left, vertical: .top)
        }
        return brickSection.alignment
    }

    public func brickLayout(_ layout: BrickLayout, brickLayoutTypeForItemAt indexPath: IndexPath) -> BrickLayoutType {
        let brick = self.brick(at:indexPath)
        if brick is BrickSection {
            return .section(sectionIndex: self.section.sectionIndexForSectionAtIndexPath(indexPath, in: collectionInfo)!) // We can safely unwrap, because this function will always return a value as the model knows it's a section
        }

        return .brick
    }

    public func brickLayout(_ layout: BrickLayout, identifierFor indexPath: IndexPath) -> String {
        return self.section.brick(at:indexPath, in: collectionInfo)!.identifier
    }

    public func brickLayout(_ layout: BrickLayout, indexPathFor section: Int) -> IndexPath? {
        return self.section.sectionIndexPaths[collectionInfo]?[section]
    }

    public func brickLayout(_ layout: BrickLayout, prefetchAttributeIndexPathsFor section: Int) -> [IndexPath] {
        return self.prefetchAttributeIndexPaths[section] ?? []
    }
}

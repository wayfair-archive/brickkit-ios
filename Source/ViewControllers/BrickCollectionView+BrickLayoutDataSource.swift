//
//  BrickViewController+BrickLayoutDataSource.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/3/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

extension BrickCollectionView: BrickLayoutDataSource {
    
    public func brickLayout(layout: BrickLayout, widthForItemAtIndexPath indexPath: NSIndexPath, totalWidth: CGFloat, widthRatio: CGFloat, startingAt origin: CGFloat) -> CGFloat {
        let inset = self.brickLayout(layout, insetForSection: indexPath.section)
        let widthDimension = self.brick(at: indexPath).size.width

        let dimension = widthDimension.dimension(in: self)

        switch dimension {
        case .Ratio(let ratio): return BrickUtils.calculateWidth(for: ratio, widthRatio: widthRatio, totalWidth: totalWidth, inset: inset)
        default: return dimension.value(for: totalWidth, startingAt: origin, in: self)
        }
    }

    public func brickLayout(layout: BrickLayout, isEstimatedHeightForIndexPath indexPath: NSIndexPath) -> Bool {
        let brick = self.brick(at: indexPath)
        if brick is BrickSection {
            return false
        }

        return brick.size.height.isEstimate(in: self)
    }

    public func brickLayout(layout: BrickLayout, estimatedHeightForItemAtIndexPath indexPath: NSIndexPath, containedInWidth width: CGFloat) -> CGFloat {
        let brick = self.brick(at: indexPath)
        if brick is BrickSection {
            return 0
        }

        let heightDimension = brick.size.height
        return heightDimension.value(for: width, startingAt: 0, in: self)
    }

    public func brickLayout(layout: BrickLayout, edgeInsetsForSection section: Int) -> UIEdgeInsets {
        guard
            let indexPath = self.section.indexPathForSection(section, in: collectionInfo),
            let brickSection = self.brick(at:indexPath) as? BrickSection
            else {
                return UIEdgeInsetsZero
        }
        return brickSection.edgeInsets
    }

    public func brickLayout(layout: BrickLayout, insetForSection section: Int) -> CGFloat {
        guard
            let indexPath = self.section.indexPathForSection(section, in: collectionInfo),
            let brickSection = self.brick(at:indexPath) as? BrickSection
            else {
                return 0
        }
        return brickSection.inset
    }

    public func brickLayout(layout: BrickLayout, isAlignRowHeightsForSection section: Int) -> Bool {
        guard
            let indexPath = self.section.indexPathForSection(section, in: collectionInfo),
            let brickSection = self.brick(at:indexPath) as? BrickSection
            else {
                return false
        }
        return brickSection.alignRowHeights
    }

    public func brickLayout(layout: BrickLayout, alignmentForSection section: Int) -> BrickAlignment {
        guard
            let indexPath = self.section.indexPathForSection(section, in: collectionInfo),
            let brickSection = self.brick(at:indexPath) as? BrickSection
            else {
                return .Left
        }
        return brickSection.alignment
    }

    public func brickLayout(layout: BrickLayout, brickLayoutTypeForItemAtIndexPath indexPath: NSIndexPath) -> BrickLayoutType {
        let brick = self.brick(at:indexPath)
        if brick is BrickSection {
            return .Section(sectionIndex: self.section.sectionIndexForSectionAtIndexPath(indexPath, in: collectionInfo)!) // We can safely unwrap, because this function will always return a value as the model knows it's a section
        }

        return .Brick
    }

    public func brickLayout(layout: BrickLayout, identifierForIndexPath indexPath: NSIndexPath) -> String {
        return self.section.brick(at:indexPath, in: collectionInfo)!.identifier
    }

    public func brickLayout(layout: BrickLayout, indexPathForSection section: Int) -> NSIndexPath? {
        return self.section.sectionIndexPaths[collectionInfo]?[section]
    }
}

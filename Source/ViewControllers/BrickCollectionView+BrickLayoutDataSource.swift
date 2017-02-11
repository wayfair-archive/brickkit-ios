//
//  BrickViewController+BrickLayoutDataSource.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/3/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

extension BrickCollectionView: BrickLayoutDataSource {
    
    public func brickLayout(_ layout: BrickLayout, widthForItemAtIndexPath indexPath: IndexPath, totalWidth: CGFloat, widthRatio: CGFloat, startingAt origin: CGFloat) -> CGFloat {
        let inset = self.brickLayout(layout, insetForSection: (indexPath as IndexPath).section)
        let widthDimension = self.brick(at: indexPath).size.width

        let dimension = widthDimension.dimension(in: self)

        switch dimension {
        case .ratio(let ratio): return BrickUtils.calculateWidth(for: ratio, widthRatio: widthRatio, totalWidth: totalWidth, inset: inset)
        default: return dimension.value(for: totalWidth, startingAt: origin, in: self)
        }
    }

    public func brickLayout(_ layout: BrickLayout, isEstimatedHeightForIndexPath indexPath: IndexPath) -> Bool {
        let brick = self.brick(at: indexPath)
        if brick is BrickSection {
            return false
        }

        return brick.size.height.isEstimate(in: self)
    }

    public func brickLayout(_ layout: BrickLayout, estimatedHeightForItemAtIndexPath indexPath: IndexPath, containedInWidth width: CGFloat) -> CGFloat {
        let brick = self.brick(at: indexPath)
        if brick is BrickSection {
            return 0
        }

        let heightDimension = brick.size.height
        return heightDimension.value(for: width, startingAt: 0, in: self)
    }

    public func brickLayout(_ layout: BrickLayout, edgeInsetsForSection section: Int) -> UIEdgeInsets {
        guard
            let indexPath = self.section.indexPathForSection(section, in: collectionInfo),
            let brickSection = self.brick(at:indexPath) as? BrickSection
            else {
                return UIEdgeInsets.zero
        }
        return brickSection.edgeInsets
    }

    public func brickLayout(_ layout: BrickLayout, insetForSection section: Int) -> CGFloat {
        guard
            let indexPath = self.section.indexPathForSection(section, in: collectionInfo),
            let brickSection = self.brick(at:indexPath) as? BrickSection
            else {
                return 0
        }
        return brickSection.inset
    }

    public func brickLayout(_ layout: BrickLayout, isAlignRowHeightsForSection section: Int) -> Bool {
        guard
            let indexPath = self.section.indexPathForSection(section, in: collectionInfo),
            let brickSection = self.brick(at:indexPath) as? BrickSection
            else {
                return false
        }
        return brickSection.alignRowHeights
    }

    public func brickLayout(_ layout: BrickLayout, alignmentForSection section: Int) -> BrickAlignment {
        guard
            let indexPath = self.section.indexPathForSection(section, in: collectionInfo),
            let brickSection = self.brick(at:indexPath) as? BrickSection
            else {
                return BrickAlignment(horizontal: .left, vertical: .top)
        }
        return brickSection.alignment
    }

    public func brickLayout(_ layout: BrickLayout, brickLayoutTypeForItemAtIndexPath indexPath: IndexPath) -> BrickLayoutType {
        let brick = self.brick(at:indexPath)
        if brick is BrickSection {
            return .section(sectionIndex: self.section.sectionIndexForSectionAtIndexPath(indexPath, in: collectionInfo)!) // We can safely unwrap, because this function will always return a value as the model knows it's a section
        }

        return .brick
    }

    public func brickLayout(_ layout: BrickLayout, identifierForIndexPath indexPath: IndexPath) -> String {
        return self.section.brick(at:indexPath, in: collectionInfo)!.identifier
    }

    public func brickLayout(_ layout: BrickLayout, indexPathForSection section: Int) -> IndexPath? {
        return self.section.sectionIndexPaths[collectionInfo]?[section] as IndexPath?
    }
}

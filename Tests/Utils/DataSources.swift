//
//  FakeCollectionViewDataSource.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/20/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
@testable import BrickKit

class SectionsCollectionViewDataSource: NSObject, UICollectionViewDataSource {

    let sections: [Int]

    init(sections: [Int]) {
        self.sections = sections
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section]
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
}

class SectionsLayoutDataSource: NSObject, BrickLayoutDataSource {

    let widthRatios: [[CGFloat]]
    let heights: [[CGFloat]]
    let edgeInsets: [UIEdgeInsets]
    let insets: [CGFloat]
    let types: [[BrickLayoutType]]

    init(widthRatios: [[CGFloat]] = [[1]], heights: [[CGFloat]] = [[0]], edgeInsets: [UIEdgeInsets] = [UIEdgeInsetsZero], insets: [CGFloat] = [0], types: [[BrickLayoutType]] = [[.Brick]]) {
        self.widthRatios = widthRatios
        self.heights = heights
        self.edgeInsets = edgeInsets
        self.insets = insets
        self.types = types
    }

    func brickLayout(layout: BrickLayout, widthRatioForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let sectionWidthRatios = widthRatios[indexPath.section]
        if sectionWidthRatios.count <= indexPath.item {
            return sectionWidthRatios.last ?? 0
        } else {
            return sectionWidthRatios[indexPath.item]
        }
    }

    func brickLayout(layout: BrickLayout, widthForItemAtIndexPath indexPath: NSIndexPath, totalWidth: CGFloat, widthRatio: CGFloat, startingAt origin: CGFloat) -> CGFloat {
        let ratio: CGFloat
        let sectionWidthRatios = widthRatios[indexPath.section]
        if sectionWidthRatios.count <= indexPath.item {
            ratio =  sectionWidthRatios.last ?? 0
        } else {
            ratio = sectionWidthRatios[indexPath.item]
        }
        return BrickUtils.calculateWidth(for: ratio, widthRatio: widthRatio, totalWidth: totalWidth, inset: self.brickLayout(layout, insetForSection: indexPath.section))
    }

    func brickLayout(layout: BrickLayout, estimatedHeightForItemAtIndexPath indexPath: NSIndexPath, containedInWidth width: CGFloat) -> CGFloat {
        let sectionHeights = heights[indexPath.section]
        if sectionHeights.count <= indexPath.item {
            return sectionHeights.last ?? 0
        } else {
            return sectionHeights[indexPath.item]
        }
    }

    func brickLayout(layout: BrickLayout, edgeInsetsForSection section: Int) -> UIEdgeInsets {
        if edgeInsets.count <= section {
            return edgeInsets.last ?? UIEdgeInsetsZero
        } else {
            return edgeInsets[section]
        }
    }

    func brickLayout(layout: BrickLayout, insetForSection section: Int) -> CGFloat {
        if insets.count <= section {
            return insets.last ?? 0
        } else {
            return insets[section]
        }
    }

    func brickLayout(layout: BrickLayout, brickLayoutTypeForItemAtIndexPath indexPath: NSIndexPath) -> BrickLayoutType {
        let sectionTypes = types[indexPath.section]
        if sectionTypes.count <= indexPath.item {
            return sectionTypes.last ?? .Brick
        } else {
            return sectionTypes[indexPath.item]
        }
    }

    func brickLayout(layout: BrickLayout, identifierForIndexPath indexPath: NSIndexPath) -> String {
        return ""
    }

    func brickLayout(layout: BrickLayout, indexPathForSection section: Int) -> NSIndexPath? {
        for (sectionIndex, type) in types.enumerate() {
            for (itemIndex, t) in type.enumerate() {
                switch t {
                case .Section(let sIndex):
                    if sIndex == section {
                        return NSIndexPath(forItem: itemIndex, inSection: sectionIndex)
                    }
                default:
                    break
                }
            }
        }
        return nil
    }
    
}

class FixedBrickLayoutSectionDataSource: NSObject, BrickLayoutSectionDataSource {

    var widthRatios: [CGFloat]
    var heights: [CGFloat]
    var edgeInsets: UIEdgeInsets
    var inset: CGFloat

    var widthRatio: CGFloat = 1
    var frameOfInterest: CGRect = CGRect(x: 0, y: 0, width: 320, height: CGFloat.infinity) // Infinite frame height

    var downStreamIndexPaths: [NSIndexPath] = []
    
    init(widthRatios: [CGFloat], heights: [CGFloat], edgeInsets: UIEdgeInsets, inset: CGFloat) {
        self.widthRatios = widthRatios
        self.heights = heights
        self.edgeInsets = edgeInsets
        self.inset = inset
    }

    func edgeInsets(in skeleton: BrickLayoutSection) -> UIEdgeInsets {
        return edgeInsets
    }

    func inset(in skeleton: BrickLayoutSection) -> CGFloat {
        return inset
    }

    func width(for index: Int, totalWidth: CGFloat, startingAt origin: CGFloat, in skeleton: BrickLayoutSection) -> CGFloat {
        return BrickUtils.calculateWidth(for: widthRatios[index], widthRatio: widthRatio, totalWidth: totalWidth, inset: inset)
    }

    func widthRatio(for index: Int, in skeleton: BrickLayoutSection) -> CGFloat {
        return widthRatios[index]
    }

    func prepareForSizeCalculation(for attributes: BrickLayoutAttributes, containedIn width: CGFloat, origin: CGPoint, invalidate: Bool, in section: BrickLayoutSection, updatedAttributes: OnAttributesUpdatedHandler?) {
    }
    
    func size(for attributes: BrickLayoutAttributes, containedIn width: CGFloat, in section: BrickLayoutSection) -> CGSize {
        return CGSize(width: width, height: heights[attributes.indexPath.item])
    }

    func identifier(for index: Int, in skeleton: BrickLayoutSection) -> String {
        return "\(index)"
    }

    func zIndex(for index: Int, in skeleton: BrickLayoutSection) -> Int {
        return 0
    }

    var zIndexBehavior: BrickLayoutZIndexBehavior {
        return .BottomUp
    }

    func isEstimate(for attributes: BrickLayoutAttributes, in section: BrickLayoutSection) -> Bool {
        return true
    }

    func downStreamIndexPaths(in section: BrickLayoutSection) -> [NSIndexPath] {
        return downStreamIndexPaths
    }

    func isAlignRowHeights(in section: BrickLayoutSection) -> Bool {
        return false
    }

    func aligment(in section: BrickLayoutSection) -> BrickAlignment {
        return .Left
    }

    var scrollDirection: UICollectionViewScrollDirection = .Vertical
}

class FixedBrickLayoutDataSource: NSObject, BrickLayoutDataSource {
    let widthRatio: CGFloat
    let height: CGFloat
    let edgeInsets: UIEdgeInsets
    let inset: CGFloat
    let type: BrickLayoutType

    init(widthRatio: CGFloat = 1, height: CGFloat = 0, edgeInsets: UIEdgeInsets = UIEdgeInsetsZero, inset: CGFloat = 0, type: BrickLayoutType = .Brick) {
        self.widthRatio = widthRatio
        self.height = height
        self.edgeInsets = edgeInsets
        self.inset = inset
        self.type = type
    }

    func brickLayout(layout: BrickLayout, widthForItemAtIndexPath indexPath: NSIndexPath, totalWidth: CGFloat, widthRatio: CGFloat, startingAt origin: CGFloat) -> CGFloat {
        return BrickUtils.calculateWidth(for: self.widthRatio, widthRatio: widthRatio, totalWidth: totalWidth, inset: inset)
    }

    func brickLayout(layout: BrickLayout, estimatedHeightForItemAtIndexPath indexPath: NSIndexPath, containedInWidth width: CGFloat) -> CGFloat {
        return height
    }

    func brickLayout(layout: BrickLayout, edgeInsetsForSection section: Int) -> UIEdgeInsets {
        return edgeInsets
    }

    func brickLayout(layout: BrickLayout, insetForSection section: Int) -> CGFloat {
        return inset
    }

    func brickLayout(layout: BrickLayout, brickLayoutTypeForItemAtIndexPath indexPath: NSIndexPath) -> BrickLayoutType {
        return type
    }

    func brickLayout(layout: BrickLayout, isBrickHiddenAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    func brickLayout(layout: BrickLayout, identifierForIndexPath indexPath: NSIndexPath) -> String {
        return ""
    }
}

class FixedSpotlightLayoutBehaviorDataSource: SpotlightLayoutBehaviorDataSource {
    let height: CGFloat
    let identifiers: [String]?

    init(height: CGFloat, identifiers: [String]? = nil) {
        self.height = height
        self.identifiers = identifiers
    }

    func spotlightLayoutBehavior(behavior: SpotlightLayoutBehavior, smallHeightForItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGFloat? {
        if let identifiers = identifiers {
            return identifiers.contains(identifier) ? height : nil
        } else {
            return height
        }
    }
}

class FixedCardLayoutBehaviorDataSource: CardLayoutBehaviorDataSource {
    let height: CGFloat

    init(height: CGFloat) {
        self.height = height
    }

    func cardLayoutBehavior(behavior: CardLayoutBehavior, smallHeightForItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGFloat? {
        return height
    }
}

class FixedOffsetLayoutBehaviorDataSource: OffsetLayoutBehaviorDataSource {
    var originOffset: CGSize?
    var sizeOffset: CGSize?
    var indexPaths: [NSIndexPath]?

    init(originOffset: CGSize?, sizeOffset: CGSize?, indexPaths: [NSIndexPath]? = nil) {
        self.originOffset = originOffset
        self.sizeOffset = sizeOffset
        self.indexPaths = indexPaths
    }

    func offsetLayoutBehavior(behavior: OffsetLayoutBehavior, originOffsetForItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize? {
        if let indexPaths = self.indexPaths {
            if !indexPaths.contains(indexPath) {
                return nil
            }
        }
        return originOffset
    }

    func offsetLayoutBehavior(behavior: OffsetLayoutBehavior, sizeOffsetForItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize? {
        if let indexPaths = self.indexPaths {
            if !indexPaths.contains(indexPath) {
                return nil
            }
        }
        return sizeOffset
    }
}

class FixedMultipleOffsetLayoutBehaviorDataSource: OffsetLayoutBehaviorDataSource {
    var originOffsets: [String: CGSize]?
    var sizeOffsets: [String: CGSize]?

    init(originOffsets: [String: CGSize]?, sizeOffsets: [String: CGSize]?) {
        self.originOffsets = originOffsets
        self.sizeOffsets = sizeOffsets
    }

    func offsetLayoutBehavior(behavior: OffsetLayoutBehavior, originOffsetForItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize? {
        return originOffsets?[identifier]
    }

    func offsetLayoutBehavior(behavior: OffsetLayoutBehavior, sizeOffsetForItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize? {
        return sizeOffsets?[identifier]
    }
}

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

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section]
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
}

class SectionsLayoutDataSource: NSObject, BrickLayoutDataSource {

    let widthRatios: [[CGFloat]]
    let heights: [[CGFloat]]
    let edgeInsets: [UIEdgeInsets]
    let insets: [CGFloat]
    let types: [[BrickLayoutType]]

    init(widthRatios: [[CGFloat]] = [[1]], heights: [[CGFloat]] = [[0]], edgeInsets: [UIEdgeInsets] = [UIEdgeInsets.zero], insets: [CGFloat] = [0], types: [[BrickLayoutType]] = [[.brick]]) {
        self.widthRatios = widthRatios
        self.heights = heights
        self.edgeInsets = edgeInsets
        self.insets = insets
        self.types = types
    }

    func brickLayout(_ layout: BrickLayout, widthRatioForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        let sectionWidthRatios = widthRatios[indexPath.section]
        if sectionWidthRatios.count <= indexPath.item {
            return sectionWidthRatios.last ?? 0
        } else {
            return sectionWidthRatios[indexPath.item]
        }
    }

    func brickLayout(_ layout: BrickLayout, widthForItemAt indexPath: IndexPath, totalWidth: CGFloat, widthRatio: CGFloat, startingAt origin: CGFloat) -> CGFloat {
        let ratio: CGFloat
        let sectionWidthRatios = widthRatios[indexPath.section]
        if sectionWidthRatios.count <= indexPath.item {
            ratio =  sectionWidthRatios.last ?? 0
        } else {
            ratio = sectionWidthRatios[indexPath.item]
        }
        return BrickUtils.calculateWidth(for: ratio, widthRatio: widthRatio, totalWidth: totalWidth, inset: self.brickLayout(layout, insetFor: indexPath.section))
    }

    func brickLayout(_ layout: BrickLayout, estimatedHeightForItemAt indexPath: IndexPath, containedIn width: CGFloat) -> CGFloat {
        let sectionHeights = heights[indexPath.section]
        if sectionHeights.count <= indexPath.item {
            return sectionHeights.last ?? 0
        } else {
            return sectionHeights[indexPath.item]
        }
    }

    func brickLayout(_ layout: BrickLayout, edgeInsetsFor section: Int) -> UIEdgeInsets {
        if edgeInsets.count <= section {
            return edgeInsets.last ?? UIEdgeInsets.zero
        } else {
            return edgeInsets[section]
        }
    }

    func brickLayout(_ layout: BrickLayout, insetFor section: Int) -> CGFloat {
        if insets.count <= section {
            return insets.last ?? 0
        } else {
            return insets[section]
        }
    }

    func brickLayout(_ layout: BrickLayout, brickLayoutTypeForItemAt indexPath: IndexPath) -> BrickLayoutType {
        let sectionTypes = types[indexPath.section]
        if sectionTypes.count <= indexPath.item {
            return sectionTypes.last ?? .brick
        } else {
            return sectionTypes[indexPath.item]
        }
    }

    func brickLayout(_ layout: BrickLayout, identifierFor indexPath: IndexPath) -> String {
        return ""
    }

    func brickLayout(_ layout: BrickLayout, indexPathFor section: Int) -> IndexPath? {
        for (sectionIndex, type) in types.enumerated() {
            for (itemIndex, t) in type.enumerated() {
                switch t {
                case .section(let sIndex):
                    if sIndex == section {
                        return IndexPath(item: itemIndex, section: sectionIndex)
                    }
                default:
                    break
                }
            }
        }
        return nil
    }

    func brickLayout(_ layout: BrickLayout, prefetchAttributeIndexPathsFor section: Int) -> [IndexPath] {
        return []
    }

}

class FixedBrickLayoutSectionDataSource: NSObject, BrickLayoutSectionDataSource {

    var widthRatios: [CGFloat]
    var heights: [CGFloat]
    var edgeInsets: UIEdgeInsets
    var inset: CGFloat

    var widthRatio: CGFloat = 1
    var frameOfInterest: CGRect = CGRect(x: 0, y: 0, width: 320, height: CGFloat.infinity) // Infinite frame height

    var downStreamIndexPaths: [IndexPath] = []
    
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
        return .bottomUp
    }

    func isEstimate(for attributes: BrickLayoutAttributes, in section: BrickLayoutSection) -> Bool {
        return true
    }

    func downStreamIndexPaths(in section: BrickLayoutSection) -> [IndexPath] {
        return downStreamIndexPaths
    }

    func isAlignRowHeights(in section: BrickLayoutSection) -> Bool {
        return false
    }

    func aligment(in section: BrickLayoutSection) -> BrickAlignment {
        return BrickAlignment(horizontal: .left, vertical: .top)
    }

    func prefetchIndexPaths(in section: BrickLayoutSection) -> [IndexPath] {
        return []
    }

    var scrollDirection: UICollectionViewScrollDirection = .vertical
}

class FixedBrickLayoutDataSource: NSObject, BrickLayoutDataSource {

    let widthRatio: CGFloat
    let height: CGFloat
    let edgeInsets: UIEdgeInsets
    let inset: CGFloat
    let type: BrickLayoutType

    init(widthRatio: CGFloat = 1, height: CGFloat = 0, edgeInsets: UIEdgeInsets = UIEdgeInsets.zero, inset: CGFloat = 0, type: BrickLayoutType = .brick) {
        self.widthRatio = widthRatio
        self.height = height
        self.edgeInsets = edgeInsets
        self.inset = inset
        self.type = type
    }

    func brickLayout(_ layout: BrickLayout, widthForItemAt indexPath: IndexPath, totalWidth: CGFloat, widthRatio: CGFloat, startingAt origin: CGFloat) -> CGFloat {
        return BrickUtils.calculateWidth(for: self.widthRatio, widthRatio: widthRatio, totalWidth: totalWidth, inset: inset)
    }

    func brickLayout(_ layout: BrickLayout, estimatedHeightForItemAt indexPath: IndexPath, containedIn width: CGFloat) -> CGFloat {
        return height
    }

    func brickLayout(_ layout: BrickLayout, edgeInsetsFor section: Int) -> UIEdgeInsets {
        return edgeInsets
    }

    func brickLayout(_ layout: BrickLayout, insetFor section: Int) -> CGFloat {
        return inset
    }

    func brickLayout(_ layout: BrickLayout, brickLayoutTypeForItemAt indexPath: IndexPath) -> BrickLayoutType {
        return type
    }

    func brickLayout(_ layout: BrickLayout, isBrickHiddenAtIndexPath indexPath: IndexPath) -> Bool {
        return false
    }

    func brickLayout(_ layout: BrickLayout, identifierFor indexPath: IndexPath) -> String {
        return ""
    }

    func brickLayout(_ layout: BrickLayout, prefetchAttributeIndexPathsFor section: Int) -> [IndexPath] {
        return []
    }
}

class FixedSpotlightLayoutBehaviorDataSource: SpotlightLayoutBehaviorDataSource {
    let height: CGFloat?
    let identifiers: [String]?

    init(height: CGFloat?, identifiers: [String]? = nil) {
        self.height = height
        self.identifiers = identifiers
    }

    func spotlightLayoutBehavior(_ behavior: SpotlightLayoutBehavior, smallHeightForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGFloat? {
        if let identifiers = identifiers {
            return identifiers.contains(identifier) ? height : nil
        } else {
            return height
        }
    }
}

class FixedCardLayoutBehaviorDataSource: CardLayoutBehaviorDataSource {
    let height: CGFloat?

    init(height: CGFloat?) {
        self.height = height
    }

    func cardLayoutBehavior(_ behavior: CardLayoutBehavior, smallHeightForItemAt indexPath: IndexPath, with identifier: String, in collectionViewLayout: UICollectionViewLayout) -> CGFloat? {
        return height
    }
}

class FixedOffsetLayoutBehaviorDataSource: OffsetLayoutBehaviorDataSource {
    var originOffset: CGSize?
    var sizeOffset: CGSize?
    var indexPaths: [IndexPath]?

    init(originOffset: CGSize?, sizeOffset: CGSize?, indexPaths: [IndexPath]? = nil) {
        self.originOffset = originOffset
        self.sizeOffset = sizeOffset
        self.indexPaths = indexPaths
    }

    func offsetLayoutBehaviorWithOrigin(_ behavior: OffsetLayoutBehavior, originOffsetForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize? {
        if let indexPaths = self.indexPaths {
            if !indexPaths.contains(indexPath) {
                return nil
            }
        }
        return originOffset
    }

    func offsetLayoutBehavior(_ behavior: OffsetLayoutBehavior, sizeOffsetForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize? {
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

    func offsetLayoutBehaviorWithOrigin(_ behavior: OffsetLayoutBehavior, originOffsetForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize? {
        return originOffsets?[identifier]
    }

    func offsetLayoutBehavior(_ behavior: OffsetLayoutBehavior, sizeOffsetForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize? {
        return sizeOffsets?[identifier]
    }
}

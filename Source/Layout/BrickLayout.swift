//
//  BrickLayout.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/30/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation

internal typealias OnAttributesUpdatedHandler = (attributes: BrickLayoutAttributes, oldFrame: CGRect?) -> Void

public enum BrickLayoutZIndexBehavior {
    case TopDown // The cell at the top has the highest zIndex. Ideally for layouts that needs `Sticky` cells where the lower cells need to go below the top cells
    case BottomUp // The cell at the bottom has the highest zIndex. Ideally for layouts where the lower cells are above the higher cells
}

public protocol BrickLayout: class {
    var widthRatio: CGFloat { get set }
    var behaviors: Set<BrickLayoutBehavior> { get set }
    var contentSize: CGSize { get }
    var zIndexBehavior: BrickLayoutZIndexBehavior { get set }
    var maxZIndex: Int { get }
    var alignRowHeights: Bool { get set }
    var scrollDirection: UICollectionViewScrollDirection { get set }

    weak var dataSource: BrickLayoutDataSource? { get set }
    weak var delegate: BrickLayoutDelegate? { get set }
    weak var hideBehaviorDataSource: HideBehaviorDataSource? { get set }

    var appearBehavior: BrickAppearBehavior? { get set }
}

public enum BrickLayoutType {
    case Brick
    case Section(sectionIndex: Int)
}

public class BrickLayoutAttributes: UICollectionViewLayoutAttributes {
     // These properties are intentially unwrapper, because otherwise we needed to override every initializer
    public internal(set) var originalFrame: CGRect!
    internal var identifier: String!
    internal var isEstimateSize = true

    public override func copyWithZone(zone: NSZone) -> AnyObject {
        let any = super.copyWithZone(zone)
        (any as? BrickLayoutAttributes)?.originalFrame = originalFrame
        (any as? BrickLayoutAttributes)?.identifier = identifier
        (any as? BrickLayoutAttributes)?.isEstimateSize = isEstimateSize
        return any
    }
}

extension BrickLayoutAttributes {
    public override var description: String {
        return super.description + " originalFrame: \(originalFrame); identifier: \(identifier)"
    }
}

public protocol BrickLayoutDataSource: class {
    func brickLayout(layout: BrickLayout, widthForItemAtIndexPath indexPath: NSIndexPath, totalWidth: CGFloat, widthRatio: CGFloat) -> CGFloat
    func brickLayout(layout: BrickLayout, estimatedHeightForItemAtIndexPath indexPath: NSIndexPath, containedInWidth width: CGFloat) -> CGFloat
    func brickLayout(layout: BrickLayout, edgeInsetsForSection section: Int) -> UIEdgeInsets
    func brickLayout(layout: BrickLayout, insetForSection section: Int) -> CGFloat
    func brickLayout(layout: BrickLayout, brickLayoutTypeForItemAtIndexPath indexPath: NSIndexPath) -> BrickLayoutType
    func brickLayout(layout: BrickLayout, identifierForIndexPath indexPath: NSIndexPath) -> String
    func brickLayout(layout: BrickLayout, indexPathForSection section: Int) -> NSIndexPath?
    func brickLayout(layout: BrickLayout, isEstimatedHeightForIndexPath indexPath: NSIndexPath) -> Bool
}

extension BrickLayoutDataSource {

    public func brickLayout(layout: BrickLayout, indexPathForSection section: Int) -> NSIndexPath? {
        return nil
    }

    func brickLayout(layout: BrickLayout, isEstimatedHeightForIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

}

public protocol BrickLayoutDelegate: class {
    func brickLayout(layout: BrickLayout, didUpdateHeightForItemAtIndexPath indexPath: NSIndexPath)
}


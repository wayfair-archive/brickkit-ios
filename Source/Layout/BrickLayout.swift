//
//  BrickLayout.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/30/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation

internal typealias OnAttributesUpdatedHandler = (attributes: BrickLayoutAttributes, oldFrame: CGRect?) -> Void

public protocol BrickLayout: class {
    var widthRatio: CGFloat { get set }
    var behaviors: Set<BrickLayoutBehavior> { get set }
    var contentSize: CGSize { get }
    var zIndexBehavior: BrickLayoutZIndexBehavior { get set }
    var maxZIndex: Int { get }
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


    /// The calculated frame before any behaviors (behaviors can change the frame of an attribute)
    public internal(set) var originalFrame: CGRect!

    /// Brick Identifier
    internal var identifier: String!

    // Flag that indicates if the size of this attribute is an estimate
    internal var isEstimateSize = true

    /// Flag that keeps track if the zIndex has been set manually. This is to prevent that the `setAutoZIndex` will override the zIndex
    private var fixedZIndex: Bool = false

    /// zIndex
    public override var zIndex: Int {
        didSet {
            fixedZIndex = true
        }
    }

    /// Set a zIndex that is calculated automatically. If the zIndex was set manually, the given zIndex will be ignored
    ///
    /// - Parameter zIndex: The zIndex that is intended to be set
    func setAutoZIndex(zIndex: Int) {
        if !fixedZIndex {
            self.zIndex = zIndex
            self.fixedZIndex = false
        }
    }

    /// Copy the attributes with all custom attributes. This is needed as UICollectionView will make copies of the attributes for height calculation etc
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        let any = super.copyWithZone(zone)
        (any as? BrickLayoutAttributes)?.originalFrame = originalFrame
        (any as? BrickLayoutAttributes)?.identifier = identifier
        (any as? BrickLayoutAttributes)?.isEstimateSize = isEstimateSize
        (any as? BrickLayoutAttributes)?.fixedZIndex = fixedZIndex
        return any
    }
}

extension BrickLayoutAttributes {
    public override var description: String {
        return super.description + " originalFrame: \(originalFrame); identifier: \(identifier)"
    }
}

public protocol BrickLayoutDataSource: class {
    func brickLayout(layout: BrickLayout, widthForItemAtIndexPath indexPath: NSIndexPath, totalWidth: CGFloat, widthRatio: CGFloat, startingAt origin: CGFloat) -> CGFloat
    func brickLayout(layout: BrickLayout, estimatedHeightForItemAtIndexPath indexPath: NSIndexPath, containedInWidth width: CGFloat, containedInHeight height: CGFloat) -> CGFloat
    func brickLayout(layout: BrickLayout, edgeInsetsForSection section: Int) -> UIEdgeInsets
    func brickLayout(layout: BrickLayout, insetForSection section: Int) -> CGFloat
    func brickLayout(layout: BrickLayout, isAlignRowHeightsForSection section: Int) -> Bool
    func brickLayout(layout: BrickLayout, alignmentForSection section: Int) -> BrickAlignment
    func brickLayout(layout: BrickLayout, brickLayoutTypeForItemAtIndexPath indexPath: NSIndexPath) -> BrickLayoutType
    func brickLayout(layout: BrickLayout, identifierForIndexPath indexPath: NSIndexPath) -> String
    func brickLayout(layout: BrickLayout, indexPathForSection section: Int) -> NSIndexPath?
    func brickLayout(layout: BrickLayout, isEstimatedHeightForIndexPath indexPath: NSIndexPath) -> Bool
    func brickLayout(layout: BrickLayout, isItemHiddenAtIndexPath indexPath: NSIndexPath) -> Bool
}

extension BrickLayoutDataSource {

    public func brickLayout(layout: BrickLayout, indexPathForSection section: Int) -> NSIndexPath? {
        return nil
    }

    func brickLayout(layout: BrickLayout, isEstimatedHeightForIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func brickLayout(layout: BrickLayout, isAlignRowHeightsForSection section: Int) -> Bool {
        return false
    }

    public func brickLayout(layout: BrickLayout, alignmentForSection section: Int) -> BrickAlignment {
        return BrickAlignment(horizontal: .Left, vertical: .Top)
    }

    public func brickLayout(layout: BrickLayout, isItemHiddenAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

}

public protocol BrickLayoutDelegate: class {
    func brickLayout(layout: BrickLayout, didUpdateHeightForItemAtIndexPath indexPath: NSIndexPath)
}


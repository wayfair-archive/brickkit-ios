//
//  BrickLayout.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/30/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation

internal typealias OnAttributesUpdatedHandler = (_ attributes: BrickLayoutAttributes, _ oldFrame: CGRect?) -> Void

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
    case brick
    case section(sectionIndex: Int)
}

open class BrickLayoutAttributes: UICollectionViewLayoutAttributes {
     // These properties are intentially unwrapper, because otherwise we needed to override every initializer


    /// The calculated frame before any behaviors (behaviors can change the frame of an attribute)
    open internal(set) var originalFrame: CGRect!

    /// Brick Identifier
    internal var identifier: String!

    // Flag that indicates if the size of this attribute is an estimate
    internal var isEstimateSize = true

    /// Flag that keeps track if the zIndex has been set manually. This is to prevent that the `setAutoZIndex` will override the zIndex
    fileprivate var fixedZIndex: Bool = false

    /// zIndex
    open override var zIndex: Int {
        didSet {
            fixedZIndex = true
        }
    }

    /// Set a zIndex that is calculated automatically. If the zIndex was set manually, the given zIndex will be ignored
    ///
    /// - Parameter zIndex: The zIndex that is intended to be set
    func setAutoZIndex(_ zIndex: Int) {
        if !fixedZIndex {
            self.zIndex = zIndex
            self.fixedZIndex = false
        }
    }

    /// Copy the attributes with all custom attributes. This is needed as UICollectionView will make copies of the attributes for height calculation etc
    open override func copy(with zone: NSZone?) -> Any {
        let any = super.copy(with: zone)
        (any as? BrickLayoutAttributes)?.originalFrame = originalFrame
        (any as? BrickLayoutAttributes)?.identifier = identifier
        (any as? BrickLayoutAttributes)?.isEstimateSize = isEstimateSize
        (any as? BrickLayoutAttributes)?.fixedZIndex = fixedZIndex
        return any
    }
}

extension BrickLayoutAttributes {
    open override var description: String {
        return super.description + " originalFrame: \(originalFrame); identifier: \(identifier)"
    }
}

public protocol BrickLayoutDataSource: class {
    func brickLayout(_ layout: BrickLayout, widthForItemAt indexPath: IndexPath, totalWidth: CGFloat, widthRatio: CGFloat, startingAt origin: CGFloat) -> CGFloat
    func brickLayout(_ layout: BrickLayout, estimatedHeightForItemAt indexPath: IndexPath, containedIn width: CGFloat) -> CGFloat
    func brickLayout(_ layout: BrickLayout, edgeInsetsFor section: Int) -> UIEdgeInsets
    func brickLayout(_ layout: BrickLayout, insetFor section: Int) -> CGFloat
    func brickLayout(_ layout: BrickLayout, isAlignRowHeightsFor section: Int) -> Bool
    func brickLayout(_ layout: BrickLayout, alignmentFor section: Int) -> BrickAlignment
    func brickLayout(_ layout: BrickLayout, brickLayoutTypeForItemAt indexPath: IndexPath) -> BrickLayoutType
    func brickLayout(_ layout: BrickLayout, identifierFor indexPath: IndexPath) -> String
    func brickLayout(_ layout: BrickLayout, indexPathFor section: Int) -> IndexPath?
    func brickLayout(_ layout: BrickLayout, isEstimatedHeightFor indexPath: IndexPath) -> Bool
    func brickLayout(_ layout: BrickLayout, isItemHiddenAt indexPath: IndexPath) -> Bool
    func brickLayout(_ layout: BrickLayout, prefetchAttributeIndexPathsFor section: Int) -> [IndexPath]
}

extension BrickLayoutDataSource {

    public func brickLayout(_ layout: BrickLayout, indexPathFor section: Int) -> IndexPath? {
        return nil
    }

    func brickLayout(_ layout: BrickLayout, isEstimatedHeightFor indexPath: IndexPath) -> Bool {
        return true
    }

    func brickLayout(_ layout: BrickLayout, isAlignRowHeightsFor section: Int) -> Bool {
        return false
    }

    public func brickLayout(_ layout: BrickLayout, alignmentFor section: Int) -> BrickAlignment {
        return BrickAlignment(horizontal: .left, vertical: .top)
    }

    public func brickLayout(_ layout: BrickLayout, isItemHiddenAt indexPath: IndexPath) -> Bool {
        return false
    }

}

public protocol BrickLayoutDelegate: class {
    func brickLayout(_ layout: BrickLayout, didUpdateHeightForItemAtIndexPath indexPath: IndexPath)
}


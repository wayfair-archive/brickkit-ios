//
//  BrickLayoutBehavior.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation

/// A BrickBehavior can alter the way bricks are displayed and handled
/// By subclassing the Behavior, an implementation can alter the frame of the brick as well as its origin
public class BrickLayoutBehavior: NSObject {
    public internal(set) weak var brickFlowLayout: BrickFlowLayout?

    // Flag that indicates that this behavior needs some calculation down stream to function correctly
    public var needsDownstreamCalculation: Bool {
        return false
    }

    public func shouldUseForDownstreamCalculation(for indexPath: NSIndexPath, with identifier: String, forCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return false
    }

    public func sectionAttributesForIndexPath(for indexPath: NSIndexPath, in layout: UICollectionViewLayout) -> BrickLayoutAttributes? {
        return brickFlowLayout?.layoutAttributesForSection(indexPath.section)
    }

    public func resetRegisteredAttributes(collectionViewLayout: UICollectionViewLayout) {
        //Optional
    }

    public func layoutDoneCalculating(collectionViewLayout: UICollectionViewLayout) {
        //Optional
    }

    public func registerAttributes(attributes: BrickLayoutAttributes, forCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        //Optional
    }

    public func invalidateInCollectionViewLayout(collectionViewLayout: UICollectionViewLayout, inout contentSize: CGSize, attributesDidUpdate: (attributes: BrickLayoutAttributes, oldFrame: CGRect?) -> Void) {
        //Optional
    }

    /**
     Override this to change the targetContentOffset for a collectionview
     */
    public func targetContentOffsetForProposedContentOffset(inout proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        //Optional
    }

}

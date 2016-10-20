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
    public internal(set) weak var collectionViewLayout: UICollectionViewLayout?

    public func sectionAttributesForIndexPath(for indexPath: NSIndexPath, in layout: UICollectionViewLayout) -> BrickLayoutAttributes? {
        if let layout = layout as? BrickFlowLayout {
            return layout.layoutAttributesForSection(indexPath.section)
        } else {
            return nil
        }
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

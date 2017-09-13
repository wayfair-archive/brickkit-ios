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
open class BrickLayoutBehavior: NSObject {
    open internal(set) weak var brickFlowLayout: BrickFlowLayout?

    // Flag that indicates that this behavior needs some calculation down stream to function correctly
    open var needsDownstreamCalculation: Bool {
        return false
    }

    open func shouldUseForDownstreamCalculation(for indexPath: IndexPath, with identifier: String, for collectionViewLayout: UICollectionViewLayout) -> Bool {
        return false
    }

    open func sectionAttributes(for indexPath: IndexPath, in layout: UICollectionViewLayout) -> BrickLayoutAttributes? {
        return brickFlowLayout?.layoutAttributesForSection(indexPath.section)
    }
    
    open func hasInvalidatableAttributes() -> Bool {
        return true
    }

    open func resetRegisteredAttributes(_ collectionViewLayout: UICollectionViewLayout) {
        //Optional
    }

    open func layoutDoneCalculating(_ collectionViewLayout: UICollectionViewLayout) {
        //Optional
    }

    open func registerAttributes(_ attributes: BrickLayoutAttributes, for collectionViewLayout: UICollectionViewLayout) {
        //Optional
    }

    open func invalidateInCollectionViewLayout(_ collectionViewLayout: UICollectionViewLayout, contentSize: inout CGSize, attributesDidUpdate: (_ attributes: BrickLayoutAttributes, _ oldFrame: CGRect?) -> Void) {
        //Optional
    }

    /**
     Override this to change the targetContentOffset for a collectionview
     */
    open func targetContentOffsetForProposedContentOffset(_ proposedContentOffset: inout CGPoint, withScrollingVelocity velocity: CGPoint, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        //Optional
    }

}

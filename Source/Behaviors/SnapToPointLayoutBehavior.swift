//
//  SnapToPointLayoutBehavior.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/12/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

/// Scroll direction for the snap to point
///
/// - Horizontal: Horizontal Scroll
/// - Vertical:   Vertical Scroll
public enum SnapToPointScrollDirection {
    case horizontal(SnapToPointHorizontalScrollLocation)
    case vertical(SnapToPointVerticalScrollLocation)
}

/// Horizontal Scroll Location
///
/// - Left:   Snaps to the brick that is closests to the left of the brickCollectionView
/// - Center: Snaps to the brick that is closests to the center of the brickCollectionView
/// - Right:  Snaps to the brick that is closests to the right of the brickCollectionView
public enum SnapToPointHorizontalScrollLocation {
    case left, center, right

    func anchorXComponent(for frame: CGRect) -> CGFloat {
        switch self {
        case .left: return frame.minX
        case .center: return frame.midX
        case .right: return frame.maxX
        }
    }

    func offsetX(for cellWidth: CGFloat, in frameSize: CGSize) -> CGFloat {
        switch self {
        case .left: return 0
        case .center: return frameSize.width/2
        case .right: return frameSize.width
        }
    }
}

/// Vertical Scroll Location
///
/// - Top:    Snaps to the brick that is closests to the top of the brickCollectionView
/// - Middle: Snaps to the brick that is closests to the middle of the brickCollectionView
/// - Bottom: Snaps to the brick that is closests to the bottom of the brickCollectionView
public enum SnapToPointVerticalScrollLocation {
    case top, middle, bottom

    func anchorYComponent(for frame: CGRect) -> CGFloat {
        switch self {
        case .top: return frame.minY
        case .middle: return frame.midY
        case .bottom: return frame.maxY
        }
    }

    func offsetY(for cellWidth: CGFloat, in frameSize: CGSize, topContentInset: CGFloat) -> CGFloat {
        switch self {
        case .top: return topContentInset
        case .middle: return (frameSize.height + topContentInset)/2
        case .bottom: return frameSize.height
        }
    }
}

/// Snaps the closest brick to a given location
open class SnapToPointLayoutBehavior: BrickLayoutBehavior {
    var sectionsToIgnore: [Int] = [0]
    fileprivate var originalTopContentInset: CGFloat = 0
    open var forBehavior: BrickLayoutBehavior?
    open var scrollDirection: SnapToPointScrollDirection {
        didSet {
            guard let brickFlowLayout = brickFlowLayout else {
                return
            }
            resetCollectionViewContentInset(brickFlowLayout)
        }
    }

    public init(scrollDirection: SnapToPointScrollDirection, forBehavior: BrickLayoutBehavior? = nil) {
        self.scrollDirection = scrollDirection
        self.forBehavior = forBehavior
    }

    open override func resetRegisteredAttributes(_ collectionViewLayout: UICollectionViewLayout) {
        super.resetRegisteredAttributes(collectionViewLayout)
        collectionViewLayout.collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
    }

    open override func layoutDoneCalculating(_ collectionViewLayout: UICollectionViewLayout) {
        resetCollectionViewContentInset(collectionViewLayout)
    }

    internal func filteredAttributes(layout collectionViewLayout: UICollectionViewLayout, frame: CGRect) -> [BrickLayoutAttributes] {
        guard let attributes = collectionViewLayout.layoutAttributesForElements(in: frame) as? [BrickLayoutAttributes] else {
            return []
        }

        let filteredAttributes = attributes.filter {
            return !self.sectionsToIgnore.contains($0.indexPath.section)
        }

        return filteredAttributes
    }

    func resetCollectionViewContentInset(_ collectionViewLayout: UICollectionViewLayout) {
        guard let frame = collectionViewLayout.collectionView?.frame else {
            return
        }

        let filteredLayoutAttributes = filteredAttributes(layout: collectionViewLayout, frame: frame)

        guard !filteredLayoutAttributes.isEmpty else {
            return
        }

        originalTopContentInset = collectionViewLayout.collectionView!.contentInset.top

        switch scrollDirection {
        case .horizontal(let scrollLocation):
            let firstAttributes = filteredLayoutAttributes.min {
                return self.minimumAttributesByXAnchor($0, attributes2: $1, for: scrollLocation, with: 0)
            }! // We can safely unwrap, because we checked if attributes is empty or not

            // The location on the left is the anchor point of the view - the anchor point of the brick
            let left = scrollLocation.offsetX(for: firstAttributes.frame.width, in: frame.size) - scrollLocation.anchorXComponent(for: firstAttributes.frame)
            collectionViewLayout.collectionView?.contentInset.left = left

            // Right is the opposite
            let right = (frame.size.width - firstAttributes.frame.width) - left
            collectionViewLayout.collectionView?.contentInset.right = right

        case .vertical(let scrollLocation):
            let firstAttributes = filteredLayoutAttributes.min {
                return self.minimumAttributesByYAnchor($0, attributes2: $1, for: scrollLocation, with: 0)
            }! // We can safely unwrap, because we checked if attributes is empty or not

            // The location on the left is the anchor point of the view - the anchor point of the brick
            let top = scrollLocation.offsetY(for: firstAttributes.frame.height, in: frame.size, topContentInset: originalTopContentInset) - scrollLocation.anchorYComponent(for: firstAttributes.frame)
            // Right is the opposite
            let bottom = (frame.size.height - firstAttributes.frame.height) - top + originalTopContentInset

            collectionViewLayout.collectionView?.contentInset.top = top
            collectionViewLayout.collectionView?.contentInset.bottom = bottom
        }
    }

    override open func targetContentOffsetForProposedContentOffset(_ proposedContentOffset: inout CGPoint, withScrollingVelocity velocity: CGPoint, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        super.targetContentOffsetForProposedContentOffset(&proposedContentOffset, withScrollingVelocity: velocity, inCollectionViewLayout: collectionViewLayout)
        guard let collectionView = collectionViewLayout.collectionView else {
            fatalError("targetContentOffsetForProposedContentOffset should never be called without collectionview")
        }

        let frameSize = collectionView.frame.size
        let rect = CGRect(origin: CGPoint(x: proposedContentOffset.x, y: proposedContentOffset.y) , size: frameSize)

        guard let attributes = collectionViewLayout.layoutAttributesForElements(in: rect) as? [BrickLayoutAttributes] , !attributes.isEmpty else {
            return
        }

        switch scrollDirection {
        case .horizontal(let scrollLocation):
            let anchorXComponent = scrollLocation.anchorXComponent(for: rect)

            // Find the closest attribute
            let minimumAttributesByXAnchor: (BrickLayoutAttributes, BrickLayoutAttributes) -> Bool = {
                return self.minimumAttributesByXAnchor($0, attributes2: $1, for: scrollLocation, with: anchorXComponent)
            }

            let closestAttributes = attributes.min(by: minimumAttributesByXAnchor)! // We can safely unwrap, because we checked if attributes is empty or not

            proposedContentOffset.x = scrollLocation.anchorXComponent(for: closestAttributes.frame) - scrollLocation.offsetX(for: closestAttributes.frame.width, in: frameSize)

        case .vertical(let scrollLocation):
            let anchorYComponent = scrollLocation.anchorYComponent(for: rect)

            // Find the closest attribute
            let minimumAttributesByYAnchor: (BrickLayoutAttributes, BrickLayoutAttributes) -> Bool = {
                return self.minimumAttributesByYAnchor($0, attributes2: $1, for: scrollLocation, with: anchorYComponent)
            }

            let closestAttributes = attributes.min(by: minimumAttributesByYAnchor)!  // We can safely unwrap, because we checked if attributes is empty or not
            
            proposedContentOffset.y = scrollLocation.anchorYComponent(for: closestAttributes.originalFrame) - scrollLocation.offsetY(for: closestAttributes.frame.height, in: frameSize, topContentInset: originalTopContentInset)
        }
    }

    /// Find the closest attribute vertically
    func minimumAttributesByYAnchor(_ attributes1: BrickLayoutAttributes, attributes2: BrickLayoutAttributes, for scrollLocation: SnapToPointVerticalScrollLocation, with anchorYComponent: CGFloat) -> Bool {
        if self.sectionsToIgnore.contains(attributes1.indexPath.section) {
            return false
        }
        if self.sectionsToIgnore.contains(attributes2.indexPath.section) {
            return true
        }

        let distance1 = abs(scrollLocation.anchorYComponent(for: attributes1.originalFrame) - anchorYComponent - self.originalTopContentInset)
        let distance2 = abs(scrollLocation.anchorYComponent(for: attributes2.originalFrame) - anchorYComponent - self.originalTopContentInset)

        return distance1 <= distance2
    }

    /// Find the closest attribute horizontally
    func minimumAttributesByXAnchor(_ attributes1: BrickLayoutAttributes, attributes2: BrickLayoutAttributes, for scrollLocation: SnapToPointHorizontalScrollLocation, with anchorXComponent: CGFloat) -> Bool {
        if self.sectionsToIgnore.contains(attributes1.indexPath.section) {
            return false
        }
        if self.sectionsToIgnore.contains(attributes2.indexPath.section) {
            return true
        }

        let distance1 = abs(scrollLocation.anchorXComponent(for: attributes1.originalFrame) - anchorXComponent)
        let distance2 = abs(scrollLocation.anchorXComponent(for: attributes2.originalFrame) - anchorXComponent)

        return distance1 <= distance2
    }

}

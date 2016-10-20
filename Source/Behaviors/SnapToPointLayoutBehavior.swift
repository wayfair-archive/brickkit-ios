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
    case Horizontal(SnapToPointHorizontalScrollLocation)
    case Vertical(SnapToPointVerticalScrollLocation)
}

/// Horizontal Scroll Location
///
/// - Left:   Snaps to the brick that is closests to the left of the brickCollectionView
/// - Center: Snaps to the brick that is closests to the center of the brickCollectionView
/// - Right:  Snaps to the brick that is closests to the right of the brickCollectionView
public enum SnapToPointHorizontalScrollLocation {
    case Left, Center, Right

    func anchorXComponent(for frame: CGRect) -> CGFloat {
        switch self {
        case .Left: return frame.minX
        case .Center: return frame.midX
        case .Right: return frame.maxX
        }
    }

    func offsetX(for cellWidth: CGFloat, in frameSize: CGSize) -> CGFloat {
        switch self {
        case .Left: return 0
        case .Center: return frameSize.width/2
        case .Right: return frameSize.width
        }
    }
}

/// Vertical Scroll Location
///
/// - Top:    Snaps to the brick that is closests to the top of the brickCollectionView
/// - Middle: Snaps to the brick that is closests to the middle of the brickCollectionView
/// - Bottom: Snaps to the brick that is closests to the bottom of the brickCollectionView
public enum SnapToPointVerticalScrollLocation {
    case Top, Middle, Bottom

    func anchorYComponent(for frame: CGRect) -> CGFloat {
        switch self {
        case .Top: return frame.minY
        case .Middle: return frame.midY
        case .Bottom: return frame.maxY
        }
    }

    func offsetY(for cellWidth: CGFloat, in frameSize: CGSize, topContentInset: CGFloat) -> CGFloat {
        switch self {
        case .Top: return topContentInset
        case .Middle: return (frameSize.height + topContentInset)/2
        case .Bottom: return frameSize.height
        }
    }
}

/// Snaps the closest brick to a given location
public class SnapToPointLayoutBehavior: BrickLayoutBehavior {
    var sectionsToIgnore: [Int] = [0]
    private var originalTopContentInset: CGFloat = 0
    public var forBehavior: BrickLayoutBehavior?
    public var scrollDirection: SnapToPointScrollDirection {
        didSet {
            guard let collectionViewLayout = collectionViewLayout else {
                return
            }
            resetCollectionViewContentInset(collectionViewLayout)
        }
    }

    public init(scrollDirection: SnapToPointScrollDirection, forBehavior: BrickLayoutBehavior? = nil) {
        self.scrollDirection = scrollDirection
        self.forBehavior = forBehavior
    }

    public override func resetRegisteredAttributes(collectionViewLayout: UICollectionViewLayout) {
        super.resetRegisteredAttributes(collectionViewLayout)
        collectionViewLayout.collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
    }

    public override func layoutDoneCalculating(collectionViewLayout: UICollectionViewLayout) {
        resetCollectionViewContentInset(collectionViewLayout)
    }

    func resetCollectionViewContentInset(collectionViewLayout: UICollectionViewLayout) {
        guard let frame = collectionViewLayout.collectionView?.frame else {
            return
        }

        guard let attributes = collectionViewLayout.layoutAttributesForElementsInRect(frame) as? [BrickLayoutAttributes] where !attributes.isEmpty else {
            return
        }

        originalTopContentInset = collectionViewLayout.collectionView!.contentInset.top

        switch scrollDirection {
        case .Horizontal(let scrollLocation):
            let firstAttributes = attributes.minElement {
                if self.sectionsToIgnore.contains($0.indexPath.section) {
                    return false
                }
                if self.sectionsToIgnore.contains($1.indexPath.section) {
                    return true
                }

                let distance1 = abs($0.frame.origin.x - 0)
                let distance2 = abs($1.frame.origin.x - 0)

                return distance1 < distance2
            }! // We can safely unwrap, because we checked if attributes is empty or not

            // The location on the left is the anchor point of the view - the anchor point of the brick
            let left = scrollLocation.offsetX(for: firstAttributes.frame.width, in: frame.size) - scrollLocation.anchorXComponent(for: firstAttributes.frame)
            // Right is the opposite
            let right = (frame.size.width - firstAttributes.frame.width) - left

            collectionViewLayout.collectionView?.contentInset.left = left
            collectionViewLayout.collectionView?.contentInset.right = right

        case .Vertical(let scrollLocation):
            let firstAttributes = attributes.minElement {
                if self.sectionsToIgnore.contains($0.indexPath.section) {
                    return false
                }
                if self.sectionsToIgnore.contains($1.indexPath.section) {
                    return true
                }

                let distance1 = abs($0.frame.origin.y - 0)
                let distance2 = abs($1.frame.origin.y - 0)

                return distance1 < distance2
            }! // We can safely unwrap, because we checked if attributes is empty or not

            // The location on the left is the anchor point of the view - the anchor point of the brick
            let top = scrollLocation.offsetY(for: firstAttributes.frame.height, in: frame.size, topContentInset: originalTopContentInset) - scrollLocation.anchorYComponent(for: firstAttributes.frame)
            // Right is the opposite
            let bottom = (frame.size.height - firstAttributes.frame.height) - top + originalTopContentInset

            collectionViewLayout.collectionView?.contentInset.top = top
            collectionViewLayout.collectionView?.contentInset.bottom = bottom
        }
    }

    override public func targetContentOffsetForProposedContentOffset(inout proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        super.targetContentOffsetForProposedContentOffset(&proposedContentOffset, withScrollingVelocity: velocity, inCollectionViewLayout: collectionViewLayout)
        guard let collectionView = collectionViewLayout.collectionView else {
            fatalError("targetContentOffsetForProposedContentOffset should never be called without collectionview")
        }

        let frameSize = collectionView.frame.size
        let rect = CGRect(origin: CGPoint(x: proposedContentOffset.x, y: proposedContentOffset.y) , size: frameSize)

        guard let attributes = collectionViewLayout.layoutAttributesForElementsInRect(rect) as? [BrickLayoutAttributes] where !attributes.isEmpty else {
            return
        }

        switch scrollDirection {
        case .Horizontal(let scrollLocation):
            let anchorXComponent = scrollLocation.anchorXComponent(for: rect)

            // Find the closest attribute by frame
            let minimumAttributesByXAnchor: (UICollectionViewLayoutAttributes, UICollectionViewLayoutAttributes) -> Bool = {
                if self.sectionsToIgnore.contains($0.indexPath.section) {
                    return false
                }
                if self.sectionsToIgnore.contains($1.indexPath.section) {
                    return true
                }

                let distance1 = abs(scrollLocation.anchorXComponent(for: $0.frame) - anchorXComponent)
                let distance2 = abs(scrollLocation.anchorXComponent(for: $1.frame) - anchorXComponent)

                return distance1 < distance2
            }

            let closestAttributes = attributes.minElement(minimumAttributesByXAnchor)! // We can safely unwrap, because we checked if attributes is empty or not

            proposedContentOffset.x = scrollLocation.anchorXComponent(for: closestAttributes.frame) - scrollLocation.offsetX(for: closestAttributes.frame.width, in: frameSize)

        case .Vertical(let scrollLocation):
                let anchorYComponent = scrollLocation.anchorYComponent(for: rect)

                // Find the closest attribute by frame
                let minimumAttributesByYAnchor: (BrickLayoutAttributes, BrickLayoutAttributes) -> Bool = {
                    if self.sectionsToIgnore.contains($0.indexPath.section) {
                        return false
                    }
                    if self.sectionsToIgnore.contains($1.indexPath.section) {
                        return true
                    }

                    let distance1 = abs(scrollLocation.anchorYComponent(for: $0.originalFrame) - anchorYComponent - self.originalTopContentInset)
                    let distance2 = abs(scrollLocation.anchorYComponent(for: $1.originalFrame) - anchorYComponent - self.originalTopContentInset
                    )

                    return distance1 < distance2
                }

                let closestAttributes = attributes.minElement(minimumAttributesByYAnchor)!  // We can safely unwrap, because we checked if attributes is empty or not
                
                proposedContentOffset.y = scrollLocation.anchorYComponent(for: closestAttributes.originalFrame) - scrollLocation.offsetY(for: closestAttributes.frame.height, in: frameSize, topContentInset: originalTopContentInset)

        }
    }
}

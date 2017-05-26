//
//  StickyLayoutBehavior.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/30/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation

/// An OnScrollDownStickyLayoutBehavior will reveal certain bricks (based on the dataSource) when scroll back down
open class OnScrollDownStickyLayoutBehavior: StickyLayoutBehavior {
    fileprivate var lastCollectionViewContentOffset: CGPoint = CGPoint.zero
    
    fileprivate var currentlyScrollingDown = false {
        didSet {
            directionChanged = oldValue != currentlyScrollingDown
        }
    }
    fileprivate var directionChanged = false

    open override func invalidateInCollectionViewLayout(_ collectionViewLayout: UICollectionViewLayout, contentSize: inout CGSize, attributesDidUpdate: (_ attributes: BrickLayoutAttributes, _ oldFrame: CGRect?) -> Void) {
        let collectionView = collectionViewLayout.collectionView!

        guard lastCollectionViewContentOffset.y != collectionView.contentOffset.y else {
            return
        }

        currentlyScrollingDown = lastCollectionViewContentOffset.y >= collectionView.contentOffset.y
        lastCollectionViewContentOffset = collectionView.contentOffset

        super.invalidateInCollectionViewLayout(collectionViewLayout, contentSize: &contentSize, attributesDidUpdate: attributesDidUpdate)
    }

    override func updateStickyAttributesInCollectionView(_ collectionViewLayout: UICollectionViewLayout, attributesDidUpdate: (_ attributes: BrickLayoutAttributes, _ oldFrame: CGRect?) -> Void) {
        if directionChanged {
            //Sort the attributes ascending
            stickyAttributes.sort {
                $0.indexPath.section <= $1.indexPath.section && $0.indexPath.item > $1.indexPath.item
            }
        } else {
            //Sort the attributes decending
            stickyAttributes.sort(by: {
                $0.indexPath.section >= $1.indexPath.section && $0.indexPath.item < $1.indexPath.item
            })
        }

        super.updateStickyAttributesInCollectionView(collectionViewLayout, attributesDidUpdate: attributesDidUpdate)
    }

    override func updateFrameForAttribute(_ attributes:inout BrickLayoutAttributes, sectionAttributes: BrickLayoutAttributes?, lastStickyFrame: CGRect, contentBounds: CGRect, collectionViewLayout: UICollectionViewLayout) -> Bool {
        if currentlyScrollingDown {
            let topInset = collectionViewLayout.collectionView!.contentInset.top
            if directionChanged {
                let stickyY: CGFloat = contentBounds.origin.y - lastStickyFrame.height - attributes.frame.height
                attributes.frame.origin.y = stickyY + topInset
            }
            attributes.frame.origin.y = max(min(attributes.frame.origin.y, contentBounds.origin.y +  lastStickyFrame.height + topInset), attributes.originalFrame.origin.y)
        }
        return true
    }
}

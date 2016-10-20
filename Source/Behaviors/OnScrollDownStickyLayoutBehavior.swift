//
//  StickyLayoutBehavior.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/30/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation

/// An OnScrollDownStickyLayoutBehavior will reveal certain bricks (based on the dataSource) when scroll back down
public class OnScrollDownStickyLayoutBehavior: StickyLayoutBehavior {
    private var lastCollectionViewContentOffset: CGPoint = CGPoint.zero
    
    private var currentlyScrollingDown = false {
        didSet {
            directionChanged = oldValue != currentlyScrollingDown
        }
    }
    private var directionChanged = false

    public override func invalidateInCollectionViewLayout(collectionViewLayout: UICollectionViewLayout, inout contentSize: CGSize, attributesDidUpdate: (attributes: BrickLayoutAttributes, oldFrame: CGRect?) -> Void) {
        let collectionView = collectionViewLayout.collectionView!
        currentlyScrollingDown = lastCollectionViewContentOffset.y > collectionView.contentOffset.y
        lastCollectionViewContentOffset = collectionView.contentOffset

        super.invalidateInCollectionViewLayout(collectionViewLayout, contentSize: &contentSize, attributesDidUpdate: attributesDidUpdate)
    }

    override func updateStickyAttributesInCollectionView(collectionViewLayout: UICollectionViewLayout, attributesDidUpdate: (attributes: BrickLayoutAttributes, oldFrame: CGRect?) -> Void) {
        if directionChanged {
            //Sort the attributes ascending
            stickyAttributes.sortInPlace {
                $0.indexPath.section <= $1.indexPath.section && $0.indexPath.item > $1.indexPath.item
            }
        } else {
            //Sort the attributes decending
            stickyAttributes.sortInPlace({
                $0.indexPath.section >= $1.indexPath.section && $0.indexPath.item < $1.indexPath.item
            })
        }

        super.updateStickyAttributesInCollectionView(collectionViewLayout, attributesDidUpdate: attributesDidUpdate)
    }

    override func updateFrameForAttribute(inout attributes:BrickLayoutAttributes, sectionAttributes: BrickLayoutAttributes?, lastStickyFrame: CGRect, contentBounds: CGRect, collectionViewLayout: UICollectionViewLayout) -> Bool {
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

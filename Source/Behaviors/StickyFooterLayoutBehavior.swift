//
//  StickyFooterBehavior.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/2/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

/// A StickyFooterLayoutBehavior will stick certain bricks (based on the dataSource) on the bottom of its section
open class StickyFooterLayoutBehavior: StickyLayoutBehavior {

    open override var needsDownstreamCalculation: Bool {
        return true
    }

    open override func shouldUseForDownstreamCalculation(for indexPath: IndexPath, with identifier: String, for collectionViewLayout: UICollectionViewLayout) -> Bool {
        if dataSource?.stickyLayoutBehavior(self, shouldStickItemAtIndexPath: indexPath, withIdentifier: identifier, inCollectionViewLayout: collectionViewLayout) == true {
            return true
        } else {
            return super.shouldUseForDownstreamCalculation(for: indexPath, with: identifier, for: collectionViewLayout)
        }
    }


    override func updateStickyAttributesInCollectionView(_ collectionViewLayout: UICollectionViewLayout, attributesDidUpdate: (_ attributes: BrickLayoutAttributes, _ oldFrame: CGRect?) -> Void) {
        //Sort the attributes ascending
        stickyAttributes.sort { (attributesOne, attributesTwo) -> Bool in
            let maxYOne: CGFloat = attributesOne.originalFrame.maxY
            let maxYTwo: CGFloat = attributesTwo.originalFrame.maxY
            return maxYOne >= maxYTwo
        }
        super.updateStickyAttributesInCollectionView(collectionViewLayout, attributesDidUpdate: attributesDidUpdate)
    }

    override func updateFrameForAttribute(_ attributes:inout BrickLayoutAttributes, sectionAttributes: BrickLayoutAttributes?, lastStickyFrame: CGRect, contentBounds: CGRect, collectionViewLayout: UICollectionViewLayout) -> Bool {

        let isOnFirstSection = sectionAttributes == nil || sectionAttributes?.indexPath == IndexPath(row: 0, section: 0)
        let bottomInset = collectionViewLayout.collectionView!.contentInset.bottom

        if isOnFirstSection {
            collectionViewLayout.collectionView?.scrollIndicatorInsets.bottom = attributes.originalFrame.height  + bottomInset
            attributes.frame.origin.y = contentBounds.maxY - attributes.originalFrame.size.height - bottomInset
        } else {
            let y = contentBounds.maxY - attributes.originalFrame.size.height - bottomInset
            attributes.frame.origin.y = min(y, attributes.originalFrame.origin.y)
        }

        if lastStickyFrame.size != CGSize.zero {
            attributes.frame.origin.y = min(lastStickyFrame.minY - attributes.originalFrame.height, attributes.originalFrame.origin.y)
        }

        return !isOnFirstSection
    }
}

//
//  CoverFlowLayoutBehavior.swift
//  BrickKit
//
//  Created by Zachary Gay on 8/19/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

private let MaximumScaleFactor: CGFloat = 1.0

public class CoverFlowLayoutBehavior: BrickLayoutBehavior {
    private let minimumScaleFactor: CGFloat

    public init(minimumScaleFactor: CGFloat) {
        self.minimumScaleFactor = minimumScaleFactor
        super.init()
    }

    public override func registerAttributes(attributes: BrickLayoutAttributes, forCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        guard attributes.indexPath.section != 0 else {
            return
        }
        attributes.transform = CGAffineTransformMakeScale(minimumScaleFactor, minimumScaleFactor)
    }

    public override func invalidateInCollectionViewLayout(collectionViewLayout: UICollectionViewLayout, inout contentSize: CGSize, attributesDidUpdate: (attributes: BrickLayoutAttributes, oldFrame: CGRect?) -> Void) {
        guard let collectionView = collectionViewLayout.collectionView else {
            return
        }

        let safeOrigin = CGPoint(x: max(0, collectionView.contentOffset.x), y: max(0, collectionView.contentOffset.y))
        let visibleContentRect = CGRect(origin:safeOrigin, size:collectionView.frame.size)
        let visibleRectCenter = visibleContentRect.midX


        guard let attributes = collectionViewLayout.layoutAttributesForElementsInRect(visibleContentRect) as? [BrickLayoutAttributes] else {
            return
        }

        // Scale each on-screen cell according to how far it is from the center
        for anAttribute in attributes {
            guard anAttribute.indexPath.section != 0 else {
                continue
            }

            var cellCenter = anAttribute.originalFrame.midX
            if collectionView.contentOffset.x < 0 {
                cellCenter -= collectionView.contentOffset.x
            }

            let distanceFromCenter = fabs(visibleRectCenter - cellCenter)
            let baseScaleFactor = (visibleContentRect.width - distanceFromCenter) / visibleContentRect.width
            let finalScaleFactor = min(max(self.minimumScaleFactor, baseScaleFactor), MaximumScaleFactor)

            let oldFrame = anAttribute.frame
            anAttribute.transform = CGAffineTransformMakeScale(finalScaleFactor, finalScaleFactor)
            attributesDidUpdate(attributes: anAttribute, oldFrame: oldFrame)
        }
    }
}

//
//  OffsetLayoutBehavior.swift
//  BrickKit
//
//  Created by Justin Shiiba on 6/8/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

public protocol OffsetLayoutBehaviorDataSource: class {
    func offsetLayoutBehaviorWithOrigin(_ behavior: OffsetLayoutBehavior, originOffsetForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize?

    func offsetLayoutBehavior(_ behavior: OffsetLayoutBehavior, sizeOffsetForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize?
}

open class OffsetLayoutBehavior: BrickLayoutBehavior {

    weak var dataSource: OffsetLayoutBehaviorDataSource?

    fileprivate(set) var offsetZIndex = 100

    var offsetAttributes: [BrickLayoutAttributes] = []

    public init(dataSource: OffsetLayoutBehaviorDataSource) {
        self.dataSource = dataSource
    }
    
    open override func hasInvalidatableAttributes() -> Bool {
        // Only return true if there is at least one attribute that's not hidden
        return offsetAttributes.contains { !$0.isHidden }
    }

    open override func resetRegisteredAttributes(_ collectionViewLayout: UICollectionViewLayout) {
        super.resetRegisteredAttributes(collectionViewLayout)
        offsetAttributes = []
    }

    open override func registerAttributes(_ attributes: BrickLayoutAttributes, for collectionViewLayout: UICollectionViewLayout) {
        if let _ = dataSource?.offsetLayoutBehaviorWithOrigin(self, originOffsetForItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) {
            offsetAttributes.append(attributes)
        }

        if let _ = dataSource?.offsetLayoutBehavior(self, sizeOffsetForItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) {
            offsetAttributes.append(attributes)
        }
    }

    open override func invalidateInCollectionViewLayout(_ collectionViewLayout: UICollectionViewLayout, contentSize: inout CGSize, attributesDidUpdate: (_ attributes: BrickLayoutAttributes, _ oldFrame: CGRect?) -> Void) {
        offsetAttributesInCollectionView(collectionViewLayout, attributesDidUpdate: attributesDidUpdate)
    }

    fileprivate func offsetAttributesInCollectionView(_ collectionViewLayout: UICollectionViewLayout, attributesDidUpdate: (_ attributes: BrickLayoutAttributes, _ oldFrame: CGRect?) -> Void) {
        guard let _ = collectionViewLayout.collectionView , !offsetAttributes.isEmpty else {
            return
        }

        for attributes in offsetAttributes {

            // Only set attribute's Offset once
            guard !attributes.isHidden else {
                continue
            }

            let oldFrame = attributes.frame
            var currentFrame = attributes.originalFrame
            if let sizeOffset = dataSource?.offsetLayoutBehavior(self, sizeOffsetForItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) {
                let frame = currentFrame
                currentFrame?.size = CGSize(width: (frame?.size.width)! + sizeOffset.width, height: (frame?.size.height)! + sizeOffset.height)
            }

            if let originOffset = dataSource?.offsetLayoutBehaviorWithOrigin(self, originOffsetForItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) {
                currentFrame = currentFrame?.offsetBy(dx: originOffset.width, dy: originOffset.height)
            }

            if currentFrame != attributes.frame {
                attributes.frame = currentFrame!
                attributesDidUpdate(attributes, oldFrame)
            }
        }
    }
}

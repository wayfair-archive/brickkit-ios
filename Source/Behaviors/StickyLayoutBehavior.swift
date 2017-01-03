//
//  StickyLayoutBehavior.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/30/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation

private let stickyZIndex = 1000

public protocol StickyLayoutBehaviorDataSource: class {
    func stickyLayoutBehavior(behavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool
}

public protocol StickyLayoutBehaviorDelegate: class {
    func stickyLayoutBehavior(behavior: StickyLayoutBehavior, brickIsStickingWithPercentage percentage: CGFloat, forItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout)
}

/// A StickyLayoutBehavior will stick certain bricks (based on the dataSource) on the top of its section
public class StickyLayoutBehavior: BrickLayoutBehavior {
    weak var dataSource: StickyLayoutBehaviorDataSource?
    weak var delegate: StickyLayoutBehaviorDelegate?
    public var contentOffset: CGFloat
    var stickyAttributes: [BrickLayoutAttributes]!

    private(set) var stickyZIndex = 1

    public var canStackWithOtherSections = false

    public init(dataSource: StickyLayoutBehaviorDataSource, delegate: StickyLayoutBehaviorDelegate? = nil, contentOffset: CGFloat = 0) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.contentOffset = contentOffset
    }

    public override func resetRegisteredAttributes(collectionViewLayout: UICollectionViewLayout) {
        super.resetRegisteredAttributes(collectionViewLayout)
        stickyAttributes = []
    }

    public override func registerAttributes(attributes: BrickLayoutAttributes, forCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        if dataSource?.stickyLayoutBehavior(self, shouldStickItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) == true {
            stickyAttributes.append(attributes)
        }
    }

    public override func invalidateInCollectionViewLayout(collectionViewLayout: UICollectionViewLayout, inout contentSize: CGSize, attributesDidUpdate: (attributes: BrickLayoutAttributes, oldFrame: CGRect?) -> Void) {
        updateStickyAttributesInCollectionView(collectionViewLayout, attributesDidUpdate: attributesDidUpdate)
    }

    func updateStickyAttributesInCollectionView(collectionViewLayout: UICollectionViewLayout, attributesDidUpdate: (attributes: BrickLayoutAttributes, oldFrame: CGRect?) -> Void) {
        var lastStickyFrame = CGRect()
        var section: Int = 0
        for (index, brickAttribute) in stickyAttributes.enumerate() {
            guard !brickAttribute.hidden else {
                continue
            }
            let sectionAttributes: BrickLayoutAttributes? = sectionAttributesForIndexPath(for: brickAttribute.indexPath, in: collectionViewLayout)

            if !canStackWithOtherSections && section != brickAttribute.indexPath.section {
                section = brickAttribute.indexPath.section
                lastStickyFrame.origin = sectionAttributes?.frame.origin ?? CGPoint.zero
                lastStickyFrame.size = CGSizeZero
            }

            var brickAttributes = brickAttribute
            let oldFrame = brickAttributes.frame
            lastStickyFrame = self.updateStickyAttribute(&brickAttributes, sectionAttributes: sectionAttributes, inCollectionViewLayout: collectionViewLayout, withStickyIndex: index, withLastStickyFrame: lastStickyFrame)

            if oldFrame != brickAttributes.frame {
                attributesDidUpdate(attributes: brickAttributes, oldFrame: oldFrame)
            }
        }
    }

    private func updateStickyAttribute(inout attributes: BrickLayoutAttributes, sectionAttributes: BrickLayoutAttributes?, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout, withStickyIndex stickyIndex:Int, withLastStickyFrame lastStickyFrame: CGRect) -> CGRect {
        let collectionView = collectionViewLayout.collectionView!

        let shouldConstrain = updateFrameForAttribute(&attributes, sectionAttributes: sectionAttributes, lastStickyFrame: lastStickyFrame, contentBounds: collectionView.bounds, collectionViewLayout: collectionViewLayout)
        let containedInFrame = sectionAttributes.map({ $0.frame }) ?? CGRect(origin: CGPoint.zero, size: collectionViewLayout.collectionViewContentSize())
        if shouldConstrain && !containedInFrame.contains(attributes.frame) {
            //constain to top
            var originY = max(containedInFrame.origin.y, attributes.frame.origin.y)
            //constain to bottom
            originY = min(containedInFrame.maxY - attributes.frame.height, originY)

            //set origin
            attributes.frame.origin.y = originY
        }

        let stickingPercentage: CGFloat
        if lastStickyFrame == .zero || lastStickyFrame.origin.y > collectionView.contentOffset.y {
            stickingPercentage = (attributes.frame.origin.y - collectionView.contentOffset.y - collectionView.contentInset.top) / attributes.frame.height
        } else {
            stickingPercentage = (attributes.frame.origin.y - lastStickyFrame.maxY) / attributes.frame.height
        }
        self.delegate?.stickyLayoutBehavior(self, brickIsStickingWithPercentage: min(max(0, stickingPercentage), 1), forItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout)

        return attributes.frame
    }

    /// - returns: True is the attribute should be constrainted
    func updateFrameForAttribute(inout attributes:BrickLayoutAttributes, sectionAttributes: BrickLayoutAttributes?, lastStickyFrame: CGRect, contentBounds: CGRect, collectionViewLayout: UICollectionViewLayout) -> Bool {

        let topInset = collectionViewLayout.collectionView!.contentInset.top

        let stickyY: CGFloat = max(contentBounds.origin.y + topInset + contentOffset, lastStickyFrame.maxY)

        let minY = attributes.originalFrame.origin.y
        let y = max(minY, stickyY)

        attributes.frame.origin.y = y

        return true
    }

}

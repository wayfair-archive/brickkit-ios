//
//  SpotlightLayoutBehavior.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/4/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

public protocol SpotlightLayoutBehaviorDataSource: class {
    func spotlightLayoutBehavior(_ behavior: SpotlightLayoutBehavior, smallHeightForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGFloat?
}

open class SpotlightLayoutBehavior: BrickLayoutBehavior {
    weak var dataSource: SpotlightLayoutBehaviorDataSource?
    open var scrollLastBrickToTop = true
    open var lastBrickStretchy = false
    open var scrollAttributes: [BrickLayoutAttributes] = []
    open var indexInSpotlight: Int = 0

    open override var needsDownstreamCalculation: Bool {
        return true
    }

    open override func shouldUseForDownstreamCalculation(for indexPath: IndexPath, with identifier: String, for collectionViewLayout: UICollectionViewLayout) -> Bool {
        return dataSource?.spotlightLayoutBehavior(self, smallHeightForItemAtIndexPath: indexPath, withIdentifier: identifier, inCollectionViewLayout: collectionViewLayout) != nil
    }

    public init(dataSource: SpotlightLayoutBehaviorDataSource) {
        self.dataSource = dataSource
    }

    open override func hasInvalidatableAttributes() -> Bool {
        // Only return true if there is at least one attribute that's not hidden
        return scrollAttributes.contains { !$0.isHidden }
    }
    
    open override func resetRegisteredAttributes(_ collectionViewLayout: UICollectionViewLayout) {
        scrollAttributes = []
    }

    open override func registerAttributes(_ attributes: BrickLayoutAttributes, for collectionViewLayout: UICollectionViewLayout) {
        if let _ = dataSource?.spotlightLayoutBehavior(self, smallHeightForItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) {
            scrollAttributes.append(attributes)
        }
    }

    open override func invalidateInCollectionViewLayout(_ collectionViewLayout: UICollectionViewLayout, contentSize: inout CGSize, attributesDidUpdate: (_ attributes: BrickLayoutAttributes, _ oldFrame: CGRect?) -> Void) {

        guard let collectionView = collectionViewLayout.collectionView, let firstAttribute = scrollAttributes.first, let dataSource = self.dataSource else {
            return
        }

        let topContentInset: CGFloat = collectionView.contentInset.top
        let offsetY: CGFloat = collectionView.contentOffset.y + topContentInset //Current scroll offset
        var previousAttributeWasInSpotlight: Bool = false
        var currentY: CGFloat = 0  //Current Y
        var sectionInset: CGFloat = 0

        // removes extra space from the bottom
        collectionView.contentInset.bottom = 0

        //Prevents crash, can't have last brick stretchy if only two bricks.
        if (lastBrickStretchy && scrollAttributes.count < 3) {
            lastBrickStretchy = false
        }

        let firstFrameOriginY: CGFloat = firstAttribute.originalFrame.origin.y

        for (index, attributes) in scrollAttributes.enumerated() {
            if let brickCollectionView = collectionView as? BrickCollectionView, let inset = brickCollectionView.layout.dataSource?.brickLayout(brickCollectionView.layout, insetFor: attributes.indexPath.section) {
                sectionInset = inset
            }

            let oldFrame = attributes.frame

            var originalFrameWithInsets = attributes.originalFrame
            originalFrameWithInsets?.size.height = attributes.originalFrame.size.height + sectionInset

            let isAbove = (originalFrameWithInsets?.maxY)! <= offsetY
            let isBelow = (originalFrameWithInsets?.minY)! > offsetY
            let firstSpotlightBrickBelowTopOfCollectionView = firstFrameOriginY >= offsetY
            let isInSpotlight = (!isAbove && !isBelow) || (offsetY < 0 && index == 0) || (firstSpotlightBrickBelowTopOfCollectionView && index == 0)

            // we can unwrap height safely because only bricks that are given a non nil height will be members of scroll attributes
            let height = dataSource.spotlightLayoutBehavior(self, smallHeightForItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout)!

            if isInSpotlight {
                var spotlightHeight = max(height, (originalFrameWithInsets?.maxY)! - offsetY)
                indexInSpotlight = index

                attributes.frame.origin.y = (originalFrameWithInsets?.maxY)! - spotlightHeight
                // Dont stretch if the top brick is not a spotlight brick
                if firstSpotlightBrickBelowTopOfCollectionView && firstFrameOriginY > 0 {
                    spotlightHeight = (originalFrameWithInsets?.size.height)!
                    attributes.frame.origin.y = (originalFrameWithInsets?.origin.y)!
                }
                attributes.frame.size.height = spotlightHeight
            } else if previousAttributeWasInSpotlight && !firstSpotlightBrickBelowTopOfCollectionView {
                //Allows for the last brick to stretch.
                if lastBrickStretchy && indexInSpotlight == (scrollAttributes.count - 2) {
                    let spotlightHeight = (originalFrameWithInsets?.size.height)! - scrollAttributes[index-1].frame.size.height

                    attributes.frame.origin.y = scrollAttributes[index-1].frame.maxY + sectionInset
                    attributes.frame.size.height = (originalFrameWithInsets?.size.height)! + spotlightHeight
                } else {
                    let ratio = ((originalFrameWithInsets?.minY)! - offsetY) / (originalFrameWithInsets?.size.height)!
                    let leftOver = (originalFrameWithInsets?.size.height)! - height
                    let inset = (sectionInset - (leftOver * (1-ratio)))

                    attributes.frame.origin.y = currentY + (inset > 0 ? inset : 0)
                    attributes.frame.size.height = height + (leftOver * (1-ratio))
                }
            } else if isAbove {
                attributes.frame.origin.y = (originalFrameWithInsets?.maxY)! - height
                attributes.frame.size.height = height
            } else if isBelow {
                //Last brick now expands in height when second to last brick expands as well.
                if lastBrickStretchy && indexInSpotlight == (scrollAttributes.count - 3) {
                    var previousOriginalFrameWithInsets = scrollAttributes[index - 1].originalFrame
                    previousOriginalFrameWithInsets?.size.height = scrollAttributes[index - 1].originalFrame.size.height + sectionInset

                    let ratio = ((previousOriginalFrameWithInsets?.minY)! - offsetY) / (originalFrameWithInsets?.size.height)!
                    let leftOver = (originalFrameWithInsets?.size.height)! - height

                    attributes.frame.origin.y = scrollAttributes[index - 1].frame.maxY + sectionInset
                    attributes.frame.size.height = height + (leftOver * (1-ratio))
                } else {
                    attributes.frame.origin.y = currentY + sectionInset
                    attributes.frame.size.height = height
                }
            }

            currentY = attributes.frame.maxY
            previousAttributeWasInSpotlight = isInSpotlight && offsetY >= 0

            if attributes.frame != oldFrame {
                attributesDidUpdate(attributes, oldFrame)
            }
        }

        let lastAttribute = scrollAttributes.last! // We can safely unwrap, because we checked the count in the beginning of the function

        if let brickCollectionView = collectionView as? BrickCollectionView, let inset = brickCollectionView.layout.dataSource?.brickLayout(brickCollectionView.layout, insetFor: lastAttribute.indexPath.section) {
            sectionInset = inset
        }

        if scrollLastBrickToTop {
            contentSize.height = lastAttribute.originalFrame.minY + collectionView.frame.height + sectionInset
        } else if lastBrickStretchy {
            contentSize.height = lastAttribute.originalFrame.maxY
        } else {
            let firstHeight = scrollAttributes.first!.originalFrame.height // We can safely unwrap, because we checked the count in the beginning of the function
            contentSize.height = lastAttribute.originalFrame.maxY - firstHeight + sectionInset
        }
    }
}

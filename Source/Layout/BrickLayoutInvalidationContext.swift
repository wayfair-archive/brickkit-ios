//
//  BrickLayoutInvalidationContext.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/6/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

enum BrickLayoutInvalidationContextType {
    case Creation
    case UpdateHeight(indexPath: NSIndexPath, newHeight: CGFloat)
    case InvalidateHeight(indexPath: NSIndexPath)
    case Scrolling
    case Rotation
    case BehaviorsChanged
    case InvalidateDataSourceCounts(sections: [Int: Int]) // Key: section Value: numberOfItems
    case Invalidate
    case UpdateVisibility

    /**
     Flag that indicates if all attributes should be invalidated.
     When true, the context will not report specific attributes to invalidate
     Basically, invalidateItemsAtIndexPaths will be nil and contentSizeAdjustment will be zero
     */
    var shouldInvalidateAllAttributes: Bool {
        switch self {
        case .Rotation, .Invalidate, .Creation, .UpdateVisibility, .InvalidateDataSourceCounts(_)/*, .UpdateHeight(_)*/: return true
        default: return false
        }
    }
}

protocol BrickLayoutInvalidationProvider: class {
    var behaviors: Set<BrickLayoutBehavior> { get set }
    var contentSize: CGSize { get }

    func removeAllCachedSections()
    func calculateSections()
    func updateHeight(for indexPath: NSIndexPath, with height: CGFloat, updatedAttributes: OnAttributesUpdatedHandler) -> CGPoint
    func invalidateHeight(for indexPath: NSIndexPath, updatedAttributes: OnAttributesUpdatedHandler)
    func recalculateContentSize() -> CGSize
    func invalidateContent(updatedAttributes: OnAttributesUpdatedHandler)
    func registerUpdatedAttributes(attributes: BrickLayoutAttributes, oldFrame: CGRect?, fromBehaviors: Bool, updatedAttributes: OnAttributesUpdatedHandler)
    func updateNumberOfItemsInSection(section: Int, numberOfItems: Int, updatedAttributes: OnAttributesUpdatedHandler)
    func applyHideBehavior(updatedAttributes updatedAttributes: OnAttributesUpdatedHandler)
    func updateContentSize(contentSize: CGSize)
}

extension BrickLayoutInvalidationContext {
    override var description: String {
        return "BrickLayoutInvalidationContext of type: \(type)"
    }
}

class BrickLayoutInvalidationContext: UICollectionViewLayoutInvalidationContext {

    let type: BrickLayoutInvalidationContextType

    var updatedAttributes: [BrickLayoutAttributes] = []

    init(type: BrickLayoutInvalidationContextType) {
        self.type = type
    }

    func invalidateWithLayout(layout: UICollectionViewLayout) -> Bool {
        return self.invalidateWithLayout(layout, context: self)
    }

    func invalidateWithLayout(layout: UICollectionViewLayout, context: UICollectionViewLayoutInvalidationContext) -> Bool {
        guard
            let provider = layout as? BrickLayoutInvalidationProvider
            else { return false }

        let oldContentSize = provider.contentSize

        let updateAttributes: OnAttributesUpdatedHandler = { attributes, oldFrame in
            self.handleAttributes(attributes, oldFrame: oldFrame, provider: provider, layout: layout, fromBehaviors: false)
        }

        let updateAttributesFromBehaviors: OnAttributesUpdatedHandler = { attributes, oldFrame in
            self.handleAttributes(attributes, oldFrame: oldFrame, provider: provider, layout: layout, fromBehaviors: true)
        }

        // Update Type
        switch type {
        case .Creation:
            for behavior in provider.behaviors {
                behavior.resetRegisteredAttributes(layout)
            }

            provider.calculateSections()

            for behavior in provider.behaviors {
                behavior.layoutDoneCalculating(layout)
            }

        case .UpdateHeight(let indexPath, let newHeight):
            let contentOffsetAdjustment = provider.updateHeight(for: indexPath, with: newHeight, updatedAttributes: updateAttributes)
            context.contentOffsetAdjustment = contentOffsetAdjustment
        case .InvalidateHeight(let indexPath):
            provider.invalidateHeight(for: indexPath, updatedAttributes: updateAttributes)
        case .Rotation, .BehaviorsChanged, .Invalidate:
            self.invalidateSections(provider, layout: layout)
        case .UpdateVisibility:
            self.applyHideBehaviors(provider, updatedAttributes: updateAttributes)
        case .InvalidateDataSourceCounts(let sections):
            let keys = Array(sections.keys).sort(<) // We need to sort the keys first so the updates are done in the correct order
            for section in keys {
                let numberOfItems = sections[section]!
                provider.updateNumberOfItemsInSection(section, numberOfItems: numberOfItems, updatedAttributes: { attributes, olfFrame in
                })
            }
            applyHideBehaviors(provider, updatedAttributes: updateAttributes)
        default: break
        }

        // Calculate content size
        provider.recalculateContentSize()

        // Behaviors
        var contentSize = provider.contentSize
        invalidateInCollectionViewLayout(layout, withBehaviors: provider.behaviors, contentSize: &contentSize, updatedAttribute: {  attributes, oldFrame in
            updateAttributesFromBehaviors(attributes: attributes, oldFrame: oldFrame)
        })

        // Calculate content size
        if contentSize == provider.contentSize { // If no behavior changed the content size, let's just recalculate it based on the frames
            provider.recalculateContentSize()
        } else {
            provider.updateContentSize(contentSize)
        }

        if !type.shouldInvalidateAllAttributes {
            // Content Size
            let difference = CGSize(width: provider.contentSize.width - oldContentSize.width, height: provider.contentSize.height - oldContentSize.height)
            context.contentSizeAdjustment = difference
            context.contentOffsetAdjustment = CGPoint(x: difference.width, y: -difference.height)
            context.invalidateItemsAtIndexPaths(updatedAttributes.map{ $0.indexPath })
        }

        return true
    }

    func applyHideBehaviors(provider: BrickLayoutInvalidationProvider, updatedAttributes: OnAttributesUpdatedHandler) {
        provider.applyHideBehavior(updatedAttributes: updatedAttributes)
    }

    func invalidateSections(provider: BrickLayoutInvalidationProvider, layout: UICollectionViewLayout) {
        for behavior in provider.behaviors {
            behavior.resetRegisteredAttributes(layout)
        }

        provider.invalidateContent({ (attributes, oldFrame) in
            for behavior in provider.behaviors {
                behavior.registerAttributes(attributes, forCollectionViewLayout: layout)
            }
            self.handleAttributes(attributes, oldFrame: oldFrame, provider: provider, layout: layout, fromBehaviors: false)
        })

        for behavior in provider.behaviors {
            behavior.layoutDoneCalculating(layout)
        }
    }

    func handleAttributes(attributes: BrickLayoutAttributes, oldFrame: CGRect?, provider: BrickLayoutInvalidationProvider, layout: UICollectionViewLayout, fromBehaviors: Bool) {

        if !updatedAttributes.contains(attributes) {
            updatedAttributes.append(attributes)
        }
        
        provider.registerUpdatedAttributes(attributes, oldFrame: oldFrame, fromBehaviors: fromBehaviors, updatedAttributes: { attributes, oldFrame in
            if !self.updatedAttributes.contains(attributes) {
                self.updatedAttributes.append(attributes)
            }
        })
    }

    func invalidateInCollectionViewLayout(collectionViewLayout: UICollectionViewLayout, withBehaviors behaviors: Set<BrickLayoutBehavior>, inout contentSize: CGSize, updatedAttribute: OnAttributesUpdatedHandler) {
        for behavior in behaviors {
            behavior.invalidateInCollectionViewLayout(collectionViewLayout, contentSize: &contentSize, attributesDidUpdate: updatedAttribute)
        }
    }

    static func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint, withBehaviors behaviors: Set<BrickLayoutBehavior>, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGPoint {
        var contentOffset = proposedContentOffset
        for behavior in behaviors {
            behavior.targetContentOffsetForProposedContentOffset(&contentOffset, withScrollingVelocity: velocity, inCollectionViewLayout: collectionViewLayout)
        }
        return contentOffset
    }
}

class BrickLayoutResizeInvalidationContext: UICollectionViewLayoutInvalidationContext {

}

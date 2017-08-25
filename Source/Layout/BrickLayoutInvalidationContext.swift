//
//  BrickLayoutInvalidationContext.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/6/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

enum BrickLayoutInvalidationContextType {
    case creation
    case updateHeight(indexPath: IndexPath, newHeight: CGFloat)
    case invalidateHeight(indexPath: IndexPath)
    case scrolling
    case rotation
    case behaviorsChanged
    case invalidate
    case updateVisibility
    case updateDirtyBricks

    /**
     Flag that indicates if all attributes should be invalidated.
     When true, the context will not report specific attributes to invalidate
     Basically, invalidateItemsAtIndexPaths will be nil and contentSizeAdjustment will be zero
     */
    var shouldInvalidateAllAttributes: Bool {
        switch self {
        case .rotation, .invalidate, .creation, .updateVisibility, .updateDirtyBricks:
            return true
        default:
            return false
        }
    }
}

protocol BrickLayoutInvalidationProvider: class {
    var behaviors: Set<BrickLayoutBehavior> { get set }
    var contentSize: CGSize { get }

    func removeAllCachedSections()
    func calculateSections()
    func updateHeight(for indexPath: IndexPath, with height: CGFloat, updatedAttributes: @escaping OnAttributesUpdatedHandler) -> CGPoint
    func invalidateHeight(for indexPath: IndexPath, updatedAttributes: @escaping OnAttributesUpdatedHandler)
    func recalculateContentSize() -> CGSize
    func invalidateContent(_ updatedAttributes: @escaping OnAttributesUpdatedHandler)
    func registerUpdatedAttributes(_ attributes: BrickLayoutAttributes, oldFrame: CGRect?, fromBehaviors: Bool, updatedAttributes: @escaping OnAttributesUpdatedHandler)
    func applyHideBehavior(updatedAttributes: @escaping OnAttributesUpdatedHandler)
    func updateContentSize(_ contentSize: CGSize)
    func updateDirtyBricks(updatedAttributes: @escaping OnAttributesUpdatedHandler)
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

    @discardableResult
    func invalidateWithLayout(_ layout: UICollectionViewLayout) -> Bool {
        return self.invalidateWithLayout(layout, context: self)
    }

    @discardableResult
    func invalidateWithLayout(_ layout: UICollectionViewLayout, context: UICollectionViewLayoutInvalidationContext) -> Bool {
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
        case .creation:
            for behavior in provider.behaviors {
                behavior.resetRegisteredAttributes(layout)
            }

            provider.calculateSections()

            for behavior in provider.behaviors {
                behavior.layoutDoneCalculating(layout)
            }

        case .updateHeight(let indexPath, let newHeight):
            let contentOffsetAdjustment = provider.updateHeight(for: indexPath, with: newHeight, updatedAttributes: updateAttributes)
            context.contentOffsetAdjustment = contentOffsetAdjustment
        case .invalidateHeight(let indexPath):
            provider.invalidateHeight(for: indexPath, updatedAttributes: updateAttributes)
        case .rotation, .behaviorsChanged, .invalidate:
            self.invalidateSections(provider, layout: layout)
        case .updateVisibility:
            self.applyHideBehaviors(provider, updatedAttributes: updateAttributes)
        case .updateDirtyBricks:
            provider.updateDirtyBricks(updatedAttributes: updateAttributes)
        default: break
        }

        // Calculate content size
        _ = provider.recalculateContentSize()

        // Behaviors
        var contentSize = provider.contentSize
        invalidateInCollectionViewLayout(layout, withBehaviors: provider.behaviors, contentSize: &contentSize, updatedAttribute: {  attributes, oldFrame in
            updateAttributesFromBehaviors(attributes, oldFrame)
        })

        // Calculate content size
        if contentSize == provider.contentSize { // If no behavior changed the content size, let's just recalculate it based on the frames
            _ = provider.recalculateContentSize()
        } else {
            provider.updateContentSize(contentSize)
        }

        if !type.shouldInvalidateAllAttributes {
            // Content Size
            let difference = CGSize(width: provider.contentSize.width - oldContentSize.width, height: provider.contentSize.height - oldContentSize.height)
            context.contentSizeAdjustment = difference
            context.invalidateItems(at: updatedAttributes.map{ $0.indexPath })
        }

        return true
    }

    func applyHideBehaviors(_ provider: BrickLayoutInvalidationProvider, updatedAttributes: @escaping OnAttributesUpdatedHandler) {
        provider.applyHideBehavior(updatedAttributes: updatedAttributes)
    }

    func invalidateSections(_ provider: BrickLayoutInvalidationProvider, layout: UICollectionViewLayout) {
        for behavior in provider.behaviors {
            behavior.resetRegisteredAttributes(layout)
        }

        provider.invalidateContent({ (attributes, oldFrame) in
            for behavior in provider.behaviors {
                behavior.registerAttributes(attributes, for: layout)
            }
            self.handleAttributes(attributes, oldFrame: oldFrame, provider: provider, layout: layout, fromBehaviors: false)
        })

        for behavior in provider.behaviors {
            behavior.layoutDoneCalculating(layout)
        }
    }

    func handleAttributes(_ attributes: BrickLayoutAttributes, oldFrame: CGRect?, provider: BrickLayoutInvalidationProvider, layout: UICollectionViewLayout, fromBehaviors: Bool) {
        if !type.shouldInvalidateAllAttributes {
            if !updatedAttributes.contains(attributes) {
                updatedAttributes.append(attributes)
            }
        }

        provider.registerUpdatedAttributes(attributes, oldFrame: oldFrame, fromBehaviors: fromBehaviors, updatedAttributes: { attributes, oldFrame in
            if !self.type.shouldInvalidateAllAttributes {
                if !self.updatedAttributes.contains(attributes) {
                    self.updatedAttributes.append(attributes)
                }
            }
        })
    }

    func invalidateInCollectionViewLayout(_ collectionViewLayout: UICollectionViewLayout, withBehaviors behaviors: Set<BrickLayoutBehavior>, contentSize: inout CGSize, updatedAttribute: OnAttributesUpdatedHandler) {
        for behavior in behaviors {
            behavior.invalidateInCollectionViewLayout(collectionViewLayout, contentSize: &contentSize, attributesDidUpdate: updatedAttribute)
        }
    }

    static func targetContentOffsetForProposedContentOffset(_ proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint, withBehaviors behaviors: Set<BrickLayoutBehavior>, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGPoint {
        var contentOffset = proposedContentOffset
        for behavior in behaviors {
            behavior.targetContentOffsetForProposedContentOffset(&contentOffset, withScrollingVelocity: velocity, inCollectionViewLayout: collectionViewLayout)
        }
        return contentOffset
    }
}

class BrickLayoutResizeInvalidationContext: UICollectionViewLayoutInvalidationContext {

}

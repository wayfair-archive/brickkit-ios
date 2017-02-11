//
//  BrickDimension.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

extension UIView {
    
    var isPortrait: Bool {
        return UIScreen.main.bounds.width <= UIScreen.main.bounds.height
    }

    var horizontalSizeClass: UIUserInterfaceSizeClass {
        return UIScreen.main.traitCollection.horizontalSizeClass
    }

    var verticalSizeClass: UIUserInterfaceSizeClass {
        return UIScreen.main.traitCollection.verticalSizeClass
    }
    
}

public struct BrickSize {
    public var width: BrickDimension
    public var height: BrickDimension
    
    public init(width: BrickDimension, height: BrickDimension) {
        self.width = width
        self.height = height
    }
}

public indirect enum BrickDimension {
    case ratio(ratio: CGFloat)
    case fixed(size: CGFloat)
    case fill

    case auto(estimate: BrickDimension)
    case orientation(landscape: BrickDimension, portrait: BrickDimension)
    case horizontalSizeClass(regular: BrickDimension, compact: BrickDimension)
    case verticalSizeClass(regular: BrickDimension, compact: BrickDimension)

    public func isEstimate(in view: UIView) -> Bool {
        switch self.dimension(in: view) {
        case .auto(_): return true
        default: return false
        }
    }

    func dimension(in view: UIView) -> BrickDimension {
        switch self {
        case .orientation(let landScape, let portrait):
            let isPortrait: Bool = view.isPortrait
            return (isPortrait ? portrait : landScape).dimension(in: view)
        case .horizontalSizeClass(let regular, let compact):
            let isRegular = view.horizontalSizeClass == .regular
            return (isRegular ? regular : compact).dimension(in: view)
        case .verticalSizeClass(let regular, let compact):
            let isRegular = view.verticalSizeClass == .regular
            return (isRegular ? regular : compact).dimension(in: view)
        default: return self
        }
    }

    func value(for otherDimension: CGFloat, startingAt origin: CGFloat, in view: UIView) -> CGFloat {
        let actualDimension = dimension(in: view)

        switch actualDimension {
        case .auto(let dimension): return dimension.value(for: otherDimension, startingAt: origin, in: view)
        default: return BrickDimension._rawValue(for: otherDimension, startingAt: origin, in: view, with: actualDimension)
        }
    }

    /// Function that gets the raw value of a BrickDimension. As of right now, only Ratio, Fixed and Fill are allowed
    static func _rawValue(for otherDimension: CGFloat, startingAt origin: CGFloat, in view: UIView, with dimension: BrickDimension) -> CGFloat {
        switch dimension {
        case .ratio(let ratio): return ratio * otherDimension
        case .fixed(let size): return size
        case .fill:
            guard otherDimension > origin else {
                // If the origin is bigger than the actual dimension, just return the whole dimension
                return otherDimension
            }
            return otherDimension - origin
        default: fatalError("Only Ratio, Fixed and Fill are allowed")
        }
    }
}

extension BrickDimension: Equatable {
}

public func ==(lhs: BrickDimension, rhs: BrickDimension) -> Bool {
    switch (lhs, rhs) {
    case (let .auto(estimate1), let .auto(estimate2)):
        return estimate1 == estimate2

    case (let .ratio(ratio1), let .ratio(ratio2)):
        return ratio1 == ratio2

    case (let .fixed(size1), let .fixed(size2)):
        return size1 == size2

    case (let .orientation(landscape1, portrait1), let .orientation(landscape2, portrait2)):
        return landscape1 == landscape2 && portrait1 == portrait2

    case (let .horizontalSizeClass(regular1, compact1), let .horizontalSizeClass(regular2, compact2)):
        return regular1 == regular2 && compact1 == compact2

    case (let .verticalSizeClass(regular1, compact1), let .verticalSizeClass(regular2, compact2)):
        return regular1 == regular2 && compact1 == compact2

    case (.fill, .fill):
        return true

    default:
        return false
    }
}


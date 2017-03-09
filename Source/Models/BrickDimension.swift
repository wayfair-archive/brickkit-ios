//
//  BrickDimension.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

public struct BrickSize {
    public var width: BrickDimension
    public var height: BrickDimension
    
    public init(width: BrickDimension, height: BrickDimension) {
        self.width = width
        self.height = height
    }
}

public indirect enum BrickDimension {
    case Ratio(ratio: CGFloat)
    case Fixed(size: CGFloat)
    case Fill

    case Auto(estimate: BrickDimension)
    case Orientation(landscape: BrickDimension, portrait: BrickDimension)
    case HorizontalSizeClass(regular: BrickDimension, compact: BrickDimension)
    case VerticalSizeClass(regular: BrickDimension, compact: BrickDimension)

    public var isEstimate: Bool {
        switch self.dimension {
        case .Auto(_): return true
        default: return false
        }
    }

    var dimension: BrickDimension {
        switch self {
        case .Orientation(let landScape, let portrait):
            return (BrickDimension.isPortrait ? portrait : landScape).dimension
        case .HorizontalSizeClass(let regular, let compact):
            let isRegular = BrickDimension.horizontalSizeClass == .Regular
            return (isRegular ? regular : compact).dimension
        case .VerticalSizeClass(let regular, let compact):
            let isRegular = BrickDimension.verticalSizeClass == .Regular
            return (isRegular ? regular : compact).dimension
        default: return self
        }
    }

    func value(for otherDimension: CGFloat, startingAt origin: CGFloat) -> CGFloat {
        let actualDimension = dimension

        switch actualDimension {
        case .Auto(let dimension): return dimension.value(for: otherDimension, startingAt: origin)
        default: return BrickDimension._rawValue(for: otherDimension, startingAt: origin, with: actualDimension)
        }
    }

    /// Function that gets the raw value of a BrickDimension. As of right now, only Ratio, Fixed and Fill are allowed
    static func _rawValue(for otherDimension: CGFloat, startingAt origin: CGFloat, with dimension: BrickDimension) -> CGFloat {
        switch dimension {
        case .Ratio(let ratio): return ratio * otherDimension
        case .Fixed(let size): return size
        case .Fill:
            guard otherDimension > origin else {
                // If the origin is bigger than the actual dimension, just return the whole dimension
                return otherDimension
            }
            return otherDimension - origin
        default: fatalError("Only Ratio, Fixed and Fill are allowed")
        }
    }

}

extension BrickDimension {

    static var isPortrait: Bool {
        return UIScreen.mainScreen().bounds.width <= UIScreen.mainScreen().bounds.height
    }

    static var horizontalSizeClass: UIUserInterfaceSizeClass {
        return UIScreen.mainScreen().traitCollection.horizontalSizeClass
    }

    static var verticalSizeClass: UIUserInterfaceSizeClass {
        return UIScreen.mainScreen().traitCollection.verticalSizeClass
    }

}

extension BrickDimension: Equatable {
}

public func ==(lhs: BrickDimension, rhs: BrickDimension) -> Bool {
    switch (lhs, rhs) {
    case (let .Auto(estimate1), let .Auto(estimate2)):
        return estimate1 == estimate2

    case (let .Ratio(ratio1), let .Ratio(ratio2)):
        return ratio1 == ratio2

    case (let .Fixed(size1), let .Fixed(size2)):
        return size1 == size2

    case (let .Orientation(landscape1, portrait1), let .Orientation(landscape2, portrait2)):
        return landscape1 == landscape2 && portrait1 == portrait2

    case (let .HorizontalSizeClass(regular1, compact1), let .HorizontalSizeClass(regular2, compact2)):
        return regular1 == regular2 && compact1 == compact2

    case (let .VerticalSizeClass(regular1, compact1), let .VerticalSizeClass(regular2, compact2)):
        return regular1 == regular2 && compact1 == compact2

    case (.Fill, .Fill):
        return true

    default:
        return false
    }
}


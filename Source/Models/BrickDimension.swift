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

public enum BrickDimension {
    case ratio(ratio: CGFloat)
    case fixed(size: CGFloat)
    case fill

    indirect case auto(estimate: BrickDimension)
    indirect case orientation(landscape: BrickDimension, portrait: BrickDimension)
    indirect case horizontalSizeClass(regular: BrickDimension, compact: BrickDimension)
    indirect case verticalSizeClass(regular: BrickDimension, compact: BrickDimension)

    public var isEstimate: Bool {
        switch self.dimension {
        case .auto(_): return true
        default: return false
        }
    }

    var dimension: BrickDimension {
        switch self {
        case .orientation(let landScape, let portrait):
            return (BrickDimension.isPortrait ? portrait : landScape).dimension
        case .horizontalSizeClass(let regular, let compact):
            let isRegular = BrickDimension.horizontalInterfaceSizeClass == .regular
            return (isRegular ? regular : compact).dimension
        case .verticalSizeClass(let regular, let compact):
            let isRegular = BrickDimension.verticalInterfaceSizeClass == .regular
            return (isRegular ? regular : compact).dimension
        default: return self
        }
    }

    func value(for otherDimension: CGFloat, startingAt origin: CGFloat) -> CGFloat {
        let actualDimension = dimension
        
        switch actualDimension {
        case .auto(let dimension): return dimension.value(for: otherDimension, startingAt: origin)
        default: return BrickDimension._rawValue(for: otherDimension, startingAt: origin, with: actualDimension)
        }
    }

    /// Function that gets the raw value of a BrickDimension. As of right now, only Ratio, Fixed and Fill are allowed
    static func _rawValue(for otherDimension: CGFloat, startingAt origin: CGFloat, with dimension: BrickDimension) -> CGFloat {
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

extension BrickDimension {
    
    static var isPortrait: Bool {
        return UIScreen.main.bounds.width <= UIScreen.main.bounds.height
    }
    
    static var horizontalInterfaceSizeClass: UIUserInterfaceSizeClass {
        return UIScreen.main.traitCollection.horizontalSizeClass
    }
    
    static var verticalInterfaceSizeClass: UIUserInterfaceSizeClass {
        return UIScreen.main.traitCollection.verticalSizeClass
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


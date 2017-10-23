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

extension BrickSize: Equatable {
    public static func ==(lhs: BrickSize, rhs: BrickSize) -> Bool {
        return lhs.height == rhs.height && lhs.width == rhs.width
    }
}

public enum RestrictedSize {
    case minimumSize(size: BrickDimension)
    case maximumSize(size: BrickDimension)
}

public typealias RangeDimensionPair = (dimension: BrickDimension, minimumSize: CGFloat)

public struct BrickRangeDimension {
    
    internal var defaultPair : RangeDimensionPair
    internal var additionalPairs : [RangeDimensionPair]
    
    public init(default dimension: BrickDimension, additionalRangePairs: [RangeDimensionPair] = []) {
        defaultPair = (dimension, 0)
        additionalPairs = additionalRangePairs
    }
    
    public func dimension(forWidth width: CGFloat?) -> BrickDimension {
        guard let width = width  else {
            return defaultPair.dimension
        }
        var dimension = defaultPair.dimension
        for RangeDimensionPair in additionalPairs {
            if RangeDimensionPair.minimumSize > width {
                break
            }
            else {
                dimension = RangeDimensionPair.dimension
            }
        }
        return dimension
    }
}

internal func almostEqualRelative(first: CGFloat, second: CGFloat, maxRelDiff: CGFloat = CGFloat.ulpOfOne) -> Bool
{
    // Calculate the difference.
    let diff = fabs(first - second);
    let a = fabs(first)
    let b = fabs(second)
    // Find the largest
    let largest = (b > a) ? b : a
    
    if diff <= largest * maxRelDiff {
        return true
    }
    return false
}

public func ==(lhs: RangeDimensionPair, rhs: RangeDimensionPair) -> Bool {
    return lhs.dimension == rhs.dimension && almostEqualRelative(first: lhs.minimumSize, second: rhs.minimumSize)
}

public func ==(lhs: BrickRangeDimension, rhs: BrickRangeDimension) -> Bool {
    if lhs.additionalPairs.count != rhs.additionalPairs.count {
        return false
    }
    if lhs.defaultPair != rhs.defaultPair {
        return false
    }
    for (index, value) in lhs.additionalPairs.enumerated() {
        if value != rhs.additionalPairs[index] {
            return false
        }
    }
    return true
}


public enum BrickDimension {
    case ratio(ratio: CGFloat)
    case fixed(size: CGFloat)
    case fill
    
    indirect case auto(estimate: BrickDimension)
    indirect case orientation(landscape: BrickDimension, portrait: BrickDimension)
    indirect case horizontalSizeClass(regular: BrickDimension, compact: BrickDimension)
    indirect case verticalSizeClass(regular: BrickDimension, compact: BrickDimension)
    indirect case dimensionRange(default: BrickDimension, additionalRangePairs: [RangeDimensionPair] )
    indirect case restricted(size: BrickDimension, restrictedSize: RestrictedSize)
    
    public func isEstimate(withValue value: CGFloat?) -> Bool {
        switch self.dimension(withValue: value) {
        case .auto(_): return true
        case .restricted(let size, _): return size.isEstimate(withValue: value)
        default: return false
        }
    }

    func dimension(withValue value: CGFloat? = nil) -> BrickDimension {
        switch self {
        case .orientation(let landScape, let portrait):
            return (BrickDimension.isPortrait ? portrait : landScape).dimension(withValue: value)
        case .horizontalSizeClass(let regular, let compact):
            let isRegular = BrickDimension.horizontalInterfaceSizeClass == .regular
            return (isRegular ? regular : compact).dimension(withValue: value)
        case .verticalSizeClass(let regular, let compact):
            let isRegular = BrickDimension.verticalInterfaceSizeClass == .regular
            return (isRegular ? regular : compact).dimension(withValue: value)
        case .dimensionRange(let defaultValue, let additionalRanges):
            return BrickRangeDimension(default: defaultValue, additionalRangePairs: additionalRanges).dimension(forWidth:value)
        default: return self
        }
    }

    func value(for otherDimension: CGFloat, startingAt origin: CGFloat) -> CGFloat {
        let actualDimension = dimension(withValue: otherDimension)
        
        switch actualDimension {
        case .auto(let dimension): return dimension.value(for: otherDimension, startingAt: origin)
        case .restricted(let size, _): return size.value(for: otherDimension, startingAt: origin)
        default: return BrickDimension._rawValue(for: otherDimension, startingAt: origin, with: actualDimension)
        }
    }

    func isRatio() -> Bool {
        if case BrickDimension.ratio = self.dimension(withValue: nil) {
            return true
        }
        return false
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
    
    internal static func restrictedValue(for cellHeight: CGFloat, width: CGFloat, restrictedSize: RestrictedSize) -> CGFloat {
        switch restrictedSize {
        case .minimumSize(let minimumDimension):
            return max(cellHeight, minimumDimension.dimension(withValue: cellHeight).value(for: width, startingAt: 0))
        case .maximumSize(let maximumDimension):
            return min(cellHeight, maximumDimension.dimension(withValue: cellHeight).value(for: width, startingAt: 0))
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
    public static func ==(lhs: BrickDimension, rhs: BrickDimension) -> Bool {
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
            
        case (let .dimensionRange(range1, addtionalRanges1), let .dimensionRange(range2, addtionalRanges2)):
            if range1 != range2 || addtionalRanges1.count != addtionalRanges2.count {
                return false
            }
            for (index, value) in addtionalRanges1.enumerated() {
                if addtionalRanges2[index] != value {
                    return false
                }
            }
            return true
            
        default:
            return false
        }
    }
}


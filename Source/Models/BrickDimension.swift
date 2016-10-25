//
//  BrickDimension.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

internal protocol BrickDimensionDeviceInfo {
    var isPortrait: Bool { get }
    var horizontalSizeClass: UIUserInterfaceSizeClass { get }
    var verticalSizeClass: UIUserInterfaceSizeClass { get }
}

extension UIView: BrickDimensionDeviceInfo {
    var isPortrait: Bool {
        #if os(iOS)
        return UIDevice.currentDevice().orientation.isPortrait
        #else
        return false
        #endif
    }

    var horizontalSizeClass: UIUserInterfaceSizeClass {
        return UIScreen.mainScreen().traitCollection.horizontalSizeClass
    }

    var verticalSizeClass: UIUserInterfaceSizeClass {
        return UIScreen.mainScreen().traitCollection.verticalSizeClass
    }
}

public indirect enum BrickDimension {
    case Ratio(ratio: CGFloat)
    case Fixed(size: CGFloat)

    case Auto(estimate: BrickDimension)
    case Orientation(landscape: BrickDimension, portrait: BrickDimension)
    case HorizontalSizeClass(regular: BrickDimension, compact: BrickDimension)
    case VerticalSizeClass(regular: BrickDimension, compact: BrickDimension)

    public func isEstimate(in view: UIView) -> Bool {
        return _isEstimate(in: view)
    }

    func _isEstimate(in deviceInfo: BrickDimensionDeviceInfo) -> Bool {
        switch self.dimension(in: deviceInfo) {
        case .Auto(_): return true
        default: return false
        }
    }

    func dimension(in deviceInfo: BrickDimensionDeviceInfo) -> BrickDimension {
        switch self {
        case .Orientation(let landScape, let portrait):
            let isPortrait: Bool = deviceInfo.isPortrait
            return (isPortrait ? portrait : landScape).dimension(in: deviceInfo)
        case .HorizontalSizeClass(let regular, let compact):
            let isRegular = deviceInfo.horizontalSizeClass == .Regular
            return (isRegular ? regular : compact).dimension(in: deviceInfo)
        case .VerticalSizeClass(let regular, let compact):
            let isRegular = deviceInfo.verticalSizeClass == .Regular
            return (isRegular ? regular : compact).dimension(in: deviceInfo)
        default: return self
        }
    }

    func value(for otherDimension: CGFloat, in deviceInfo: BrickDimensionDeviceInfo) -> CGFloat {
        let actualDimension = dimension(in: deviceInfo)

        switch actualDimension {
        case .Auto(let dimension): return dimension.value(for: otherDimension, in: deviceInfo)
        default: return BrickDimension._rawValue(for: otherDimension, in: deviceInfo, with: actualDimension)
        }
    }

    /// Function that gets the raw value of a BrickDimension. As of right now, only Ratio and Fixed are allowed
    static func _rawValue(for otherDimension: CGFloat, in deviceInfo: BrickDimensionDeviceInfo, with dimension: BrickDimension) -> CGFloat {
        switch dimension {
        case .Ratio(let ratio): return ratio * otherDimension
        case .Fixed(let size): return size
        default: fatalError("Only Ratio and Fixed are allowed")
        }
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

    default:
        return false
    }
}


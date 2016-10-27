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
        return UIScreen.mainScreen().bounds.width <= UIScreen.mainScreen().bounds.height
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
        switch self.dimension(in: view) {
        case .Auto(_): return true
        default: return false
        }
    }

    func dimension(in view: UIView) -> BrickDimension {
        switch self {
        case .Orientation(let landScape, let portrait):
            let isPortrait: Bool = view.isPortrait
            return (isPortrait ? portrait : landScape).dimension(in: view)
        case .HorizontalSizeClass(let regular, let compact):
            let isRegular = view.horizontalSizeClass == .Regular
            return (isRegular ? regular : compact).dimension(in: view)
        case .VerticalSizeClass(let regular, let compact):
            let isRegular = view.verticalSizeClass == .Regular
            return (isRegular ? regular : compact).dimension(in: view)
        default: return self
        }
    }

    func value(for otherDimension: CGFloat, in view: UIView) -> CGFloat {
        let actualDimension = dimension(in: view)

        switch actualDimension {
        case .Auto(let dimension): return dimension.value(for: otherDimension, in: view)
        default: return BrickDimension._rawValue(for: otherDimension, in: view, with: actualDimension)
        }
    }

    /// Function that gets the raw value of a BrickDimension. As of right now, only Ratio and Fixed are allowed
    static func _rawValue(for otherDimension: CGFloat, in view: UIView, with dimension: BrickDimension) -> CGFloat {
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


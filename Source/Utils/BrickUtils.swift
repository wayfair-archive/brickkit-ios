//
//  BrickUtils.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/30/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

enum BrickUtils {

    /// Calculates a width, based on the total width and its inset
    ///
    /// - parameter ratio:      Ratio
    /// - parameter widthRatio: Value that represents 100%
    /// - parameter totalWidth: Total width to calculate from
    /// - parameter inset:      Inset inbetween widths
    ///
    /// - returns: The actual width
    static func calculateWidth(for ratio: CGFloat, widthRatio: CGFloat, totalWidth: CGFloat, inset: CGFloat) -> CGFloat {
        let rowWidth = totalWidth - CGFloat((widthRatio / ratio) - 1) * inset
        let width = rowWidth * (ratio / widthRatio)
        return width
    }
}


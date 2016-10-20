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

    /// Find the maxY in a row of frames, not including the itemIndex
    ///
    /// - parameter itemIndex: Index to start at
    /// - parameter frames:    Array of frames to search through
    ///
    /// - returns: MaxY in the
    static func findRowMaxY(for itemIndex: Int, in frames: [CGRect]) -> CGFloat? {
        guard itemIndex <= frames.count else {
            return nil
        }

        if itemIndex == 0 {
            return 0
        }

        let currentY = frames[itemIndex-1].origin.y
        var maxY = frames[itemIndex-1].maxY
        for index in (itemIndex-1).stride(to: -1, by: -1) {
            if currentY != frames[index].origin.y {
                return maxY
            }
            maxY = max(maxY, frames[index].maxY)
        }
        
        return maxY
    }
}


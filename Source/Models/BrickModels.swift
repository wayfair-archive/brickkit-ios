//
//  Brick.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation
import UIKit

/// A Brick is the model representation of a BrickCell in a BrickCollectionView
public class Brick: CustomStringConvertible {

    // Mark: - Public members

    /// Identifier of the brick. Defaults to empty string
    public let identifier: String

    /// Width dimension used to calculate the width. Defaults to .Ratio(ratio: 1)
    public var width: BrickDimension

    /// Height dimension used to calculate the height. Defaults to .Auto(estimate: .Fixed(size: 50))
    public var height: BrickDimension

    /// Background color used for the brick. Defaults to .clearColor()
    public var backgroundColor: UIColor

    /// Background view used for the brick. Defaults to nil
    public var backgroundView: UIView?

    /// Delegate used to handle tap gestures for the brick. Defaults to nil
    public var brickCellTapDelegate: BrickCellTapDelegate?

    /// Initialize a Brick
    ///
    /// - parameter identifier:      Identifier of the brick. Defaults to empty string
    /// - parameter width:           Width dimension used to calculate the width. Defaults to .Ratio(ratio: 1)
    /// - parameter height:          Height dimension used to calculate the height. Defaults to .Auto(estimate: .Fixed(size: 50))
    /// - parameter backgroundColor: Background color used for the brick. Defaults to .clearColor()
    /// - parameter backgroundView:  Background view used for the brick. Defaults to nil
    ///
    /// - returns: brick
    public init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil) {
        self.identifier = identifier
        self.width = width
        self.height = height
        self.backgroundColor = backgroundColor
        self.backgroundView = backgroundView
    }

    // Mark: - Internal

    /// Keeps track of the counts per collection info
    internal var counts: [CollectionInfo:Int] = [:]

    /// Get the count for a given collection info
    func count(for collection: CollectionInfo) -> Int {
        return counts[collection] ?? 1
    }

    // Mark: - Loading nibs/cells

    /// Instance variable: Name of the nib that should be used to load this brick's cell
    public var nibName: String {
        return self.dynamicType.nibName
    }

    /// Class variable: Default nib name to be used for this brick's cell
    // If not overriden, it uses the same as the Brick class
    public class var nibName: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }

    /// Class variable: If not nil, this class will be used to load this brick's cell
    public class var cellClass: UICollectionViewCell.Type? {
        return nil
    }

    /// Bundle where the nib/class should be loaded from
    public class var bundle: NSBundle {
        return NSBundle(forClass: self)
    }

    // Mark: - CustomStringConvertible

    public var description: String {
        return descriptionWithIndentationLevel(0)
    }

    /// Convenience method to show description with an indentation
    internal func descriptionWithIndentationLevel(indentationLevel: Int) -> String {
        var description = ""
        for _ in 0..<indentationLevel {
            description += "    "
        }
        description += "<\(self.nibName) -\(identifier)- width: \(width) - height: \(height)>"

        return description
    }
}

public class BrickSection: Brick {
    public var bricks: [Brick]
    public var inset: CGFloat
    public var edgeInsets: UIEdgeInsets

    internal private(set) var collectionIndex: Int = 0
    internal private(set) var collectionIdentifier: String = ""

    internal private(set) var sectionCount: Int = 0
    internal private(set) var sectionIndexPaths: [CollectionInfo: [Int: NSIndexPath]] = [:] // Variable that keeps track of the indexpaths of the sections

    public weak var repeatCountDataSource: BrickRepeatCountDataSource? {
        didSet {
            sectionIndexPaths.removeAll()
        }
    }

    public init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 0)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, bricks: [Brick], inset: CGFloat = 0, edgeInsets: UIEdgeInsets = UIEdgeInsetsZero) {
        self.bricks = bricks
        self.inset = inset
        self.edgeInsets = edgeInsets
        super.init(identifier, width: width, height: height, backgroundColor: backgroundColor, backgroundView: backgroundView)
    }

    /// Invalidate the brick counts for a given collection. Recalculate where sections are in the tree
    func invalidateIfNeeded(in collection: CollectionInfo) -> [Int: NSIndexPath] {
        if let sectionIndexPaths = self.sectionIndexPaths[collection] {
            return sectionIndexPaths
        }

        return invalidateSectionIndexPaths(in: collection)
    }

    /// Invalidate the counts for a given dimension
    func invalidateCounts(in collection: CollectionInfo) {
        sectionIndexPaths[collection] = nil
    }

    func invalidateSectionIndexPaths(in collection: CollectionInfo) -> [Int: NSIndexPath] {
        var sectionIndexPaths: [Int: NSIndexPath] = [:]
        var sectionCount = 0

        BrickSection.addSection(&sectionIndexPaths, sectionCount: &sectionCount, bricks: [self], repeatCountDataSource: repeatCountDataSource, in: collection)

        self.sectionIndexPaths[collection] = sectionIndexPaths
        self.sectionCount = sectionCount

        return sectionIndexPaths
    }

    /// Add a section
    static private func addSection(inout sectionIndexPaths: [Int: NSIndexPath], inout sectionCount: Int, bricks: [Brick], repeatCountDataSource: BrickRepeatCountDataSource?, atIndexPath indexPath: NSIndexPath? = nil, in collection: CollectionInfo) {
        let sectionId = sectionCount
        sectionCount += 1
        if let indexPath = indexPath {
            sectionIndexPaths[sectionId] = indexPath
        }

        var index = 0
        for brick in bricks {
            brick.counts[collection] = repeatCountDataSource?.repeatCount(for: brick.identifier, with: collection.index, collectionIdentifier: collection.identifier) ?? brick.count(for: collection)

            if let sectionModel = brick as? BrickSection {
                // Do not set a repeat count on a section
                if brick.count(for: collection) != 1 {
                    fatalError("Repeat count on a section is not allowed (requested \(brick.count(for: collection))). Please use `CollectionBrick`")
                }
                BrickSection.addSection(&sectionIndexPaths, sectionCount: &sectionCount, bricks: sectionModel.bricks, repeatCountDataSource: sectionModel.repeatCountDataSource ?? repeatCountDataSource, atIndexPath: NSIndexPath(forRow: index, inSection: sectionId), in: collection)
            }

            index += brick.count(for: collection)
        }
    }

    // Mark: - CustomStringConvertible

    /// Convenience method to show description with an indentation
    override internal func descriptionWithIndentationLevel(indentationLevel: Int) -> String {
        var description = super.descriptionWithIndentationLevel(indentationLevel)
        description += " inset: \(inset) edgeInsets: \(edgeInsets)"

        var brickDescription = ""
        for brick in bricks {
            brickDescription += "\n"
            brickDescription += "\(brick.descriptionWithIndentationLevel(indentationLevel + 1))"
        }
        description += brickDescription

        return description
    }
}



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
open class Brick: CustomStringConvertible {

    // Mark: - Public members

    /// Identifier of the brick. Defaults to empty string
    open let identifier: String

    /// Passes string to BrickCell's accessibilityIdentifier for UIAccessibility.  Defaults to the brick identifier
    open var accessibilityIdentifier: String

    /// Passes string to BrickCell's accessibilityLabel for UIAccessibility.  Defaults to nil
    open var accessibilityLabel: String?

    /// Passes string to BrickCell's accessibilityHint for UIAccessibility.  Defaults to nil
    open var accessibilityHint: String?

    open var size: BrickSize
    
    /// Width dimension used to calculate the width. Defaults to .ratio(ratio: 1)
    open var width: BrickDimension {
        set(newWidth) {
            size.width = newWidth
        }
        get {
            return size.width
        }
    }
    
    /// Height dimension used to calculate the height. Defaults to .auto(estimate: .fixed(size: 50))
    open var height: BrickDimension {
        set(newHeight) {
            size.height = newHeight
        }
        get {
            return size.height
        }
    }
    
    /// Background color used for the brick. Defaults to UIColor.clear
    open var backgroundColor: UIColor
    
    /// Background view used for the brick. Defaults to nil
    open var backgroundView: UIView?
    
    /// Delegate used to handle tap gestures for the brick. Defaults to nil
    open weak var brickCellTapDelegate: BrickCellTapDelegate?
    
    /// Used to override content. Defaults to nil
    open weak var overrideContentSource: OverrideContentSource?

    /// Initialize a Brick
    ///
    /// - parameter identifier:      Identifier of the brick. Defaults to empty string
    /// - parameter width:           Width dimension used to calculate the width. Defaults to .ratio(ratio: 1)
    /// - parameter height:          Height dimension used to calculate the height. Defaults to .auto(estimate: .fixed(size: 50))
    /// - parameter backgroundColor: Background color used for the brick. Defaults to UIColor.clear
    /// - parameter backgroundView:  Background view used for the brick. Defaults to nil
    /// - returns: brick
    convenience public init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil) {
        self.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView)
    }
    
    public init(_ identifier: String = "", size: BrickSize, backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil) {
        self.identifier = identifier
        self.size = size
        self.backgroundColor = backgroundColor
        self.backgroundView = backgroundView
        self.accessibilityIdentifier = identifier
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
    open var nibName: String {
        return type(of: self).nibName
    }

    /// Class variable: Default nib name to be used for this brick's cell
    // If not overriden, it uses the same as the Brick class
    open class var nibName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }

    // The internal identifier to use for this brick
    // This is used when storing the registered brick
    open class var internalIdentifier: String {
        return NSStringFromClass(self)
    }

    /// Class variable: If not nil, this class will be used to load this brick's cell
    open class var cellClass: UICollectionViewCell.Type? {
        return nil
    }

    /// Bundle where the nib/class should be loaded from
    open class var bundle: Bundle {
        return Bundle(for: self)
    }

    // Mark: - CustomStringConvertible

    open var description: String {
        return descriptionWithIndentationLevel(0)
    }

    /// Convenience method to show description with an indentation
    internal func descriptionWithIndentationLevel(_ indentationLevel: Int) -> String {
        var description = ""
        for _ in 0..<indentationLevel {
            description += "    "
        }
        description += "<\(self.nibName) -\(identifier)- size: \(size)>"

        return description
    }
}

open class BrickSection: Brick {
    open var bricks: [Brick]
    open var inset: CGFloat
    open var edgeInsets: UIEdgeInsets
    open var alignRowHeights: Bool
    open var alignment: BrickAlignment

    internal fileprivate(set) var collectionIndex: Int = 0
    internal fileprivate(set) var collectionIdentifier: String = ""

    internal fileprivate(set) var sectionCount: Int = 0
    internal fileprivate(set) var sectionIndexPaths: [CollectionInfo: [Int: IndexPath]] = [:] // Variable that keeps track of the indexpaths of the sections

    open weak var repeatCountDataSource: BrickRepeatCountDataSource? {
        didSet {
            sectionIndexPaths.removeAll()
        }
    }

    public init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 0)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, bricks: [Brick], inset: CGFloat = 0, edgeInsets: UIEdgeInsets = UIEdgeInsets.zero, alignRowHeights: Bool = false, alignment: BrickAlignment = BrickAlignment(horizontal: .left, vertical: .top)) {
        self.bricks = bricks
        self.inset = inset
        self.edgeInsets = edgeInsets
        self.alignRowHeights = alignRowHeights
        self.alignment = alignment
        super.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView)
    }

    /// Invalidate the brick counts for a given collection. Recalculate where sections are in the tree
    func invalidateIfNeeded(in collection: CollectionInfo) -> [Int: IndexPath] {
        if let sectionIndexPaths = self.sectionIndexPaths[collection] {
            return sectionIndexPaths
        }

        return invalidateSectionIndexPaths(in: collection)
    }

    /// Invalidate the counts for a given dimension
    func invalidateCounts(in collection: CollectionInfo) {
        sectionIndexPaths[collection] = nil
    }

    func invalidateSectionIndexPaths(in collection: CollectionInfo) -> [Int: IndexPath] {
        var sectionIndexPaths: [Int: IndexPath] = [:]
        var sectionCount = 0

        BrickSection.addSection(&sectionIndexPaths, sectionCount: &sectionCount, bricks: [self], repeatCountDataSource: repeatCountDataSource, in: collection)

        self.sectionIndexPaths[collection] = sectionIndexPaths
        self.sectionCount = sectionCount

        return sectionIndexPaths
    }

    /// Add a section
    static fileprivate func addSection(_ sectionIndexPaths: inout [Int: IndexPath], sectionCount: inout Int, bricks: [Brick], repeatCountDataSource: BrickRepeatCountDataSource?, atIndexPath indexPath: IndexPath? = nil, in collection: CollectionInfo) {
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
                BrickSection.addSection(&sectionIndexPaths, sectionCount: &sectionCount, bricks: sectionModel.bricks, repeatCountDataSource: sectionModel.repeatCountDataSource ?? repeatCountDataSource, atIndexPath: IndexPath(row: index, section: sectionId), in: collection)
            }

            index += brick.count(for: collection)
        }
    }

    // Mark: - CustomStringConvertible

    /// Convenience method to show description with an indentation
    override internal func descriptionWithIndentationLevel(_ indentationLevel: Int) -> String {
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



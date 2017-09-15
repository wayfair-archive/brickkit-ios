//
//  BrickSection.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 7/5/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import Foundation

public protocol BrickSectionOrderDataSource: class {
    func brickAndIndex(atIndex brickIndex: Int, section: BrickSection) -> (Brick, Int)?
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

    /// Optional dictionary that holds the identifier of a brick as a key and the value is the nib that should be used for that brick
    /// These nibs will be registered, when setting this BrickSection on a BrickCollectionView
    open var nibIdentifiers: [String: UINib]?

    open var classIdentifiers: [String: AnyClass]?

    open internal(set) weak var brickCollectionView: BrickCollectionView?

    open weak var orderDataSource: BrickSectionOrderDataSource?

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

    func brickAndIndex(atIndex brickIndex: Int, in collection: CollectionInfo) -> (Brick, Int)? {
        if let orderDataSource = orderDataSource, let brickAndIndex = orderDataSource.brickAndIndex(atIndex: brickIndex, section: self) {
            return brickAndIndex
        } else {
            var index = 0
            for brick in self.bricks {
                if brickIndex < index + brick.count(for: collection) {
                    return (brick, brickIndex - index)
                }
                index += brick.count(for: collection)
            }
        }
        return nil
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

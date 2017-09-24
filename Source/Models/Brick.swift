//
//  Brick.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation
import UIKit

public protocol BrickPreviewingDelegate: class {
    /**
     Returns a new instance of the view controller that the given brick is intended to peek during a 3D Touch press.
     
     Any special preview actions to be displayed when the user swipes up during a peek are implemented in the class of the returned UIViewController itself, so keep that in mind if you aren't subclassing.
     */
    func previewViewController(for brick: Brick) -> UIViewController?
    /**
     Implement this function to handle committing the preview view controller to the current focus.
     */
    func commit(viewController: UIViewController)
}

@available(iOS 11.0, *)
public protocol BrickDragDropDelegate: class {
    @available(iOS 11.0, *)
    var itemProviderType: NSItemProviderReading.Type { get }
    
    @available(iOS 11.0, *)
    func dragItems(for session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    
    @available(iOS 11.0, *)
    func previewParameters(for view: UICollectionViewCell, at indexPath: IndexPath) -> UIDragPreviewParameters?
    
    @available(iOS 11.0, *)
    func canHandle(_ session: UIDropSession) -> Bool

    @available(iOS 11.0, *)
    func willDrop(_ item: Any?) -> Bool

    @available(iOS 11.0, *)
    func drop(_ item: Any?, to destinationIndex: Int, from sourceIndex: Int?)
}

@available(iOS 11.0, *)
extension BrickDragDropDelegate {
    func dragItems(for session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
    func previewParameters(for view: UICollectionViewCell, at indexPath: IndexPath) -> UIDragPreviewParameters? {
        return nil
    }
    
    func canHandle(_ session: UIDropSession) -> Bool {
        return false
    }
    
    func willDrop(_ item: Any?) -> Bool {
        return false
    }

    func drop(_ item: Any?, to destinationIndex: Int, from sourceIndex: Int? = nil) {
        // no-op
    }
}

/// A Brick is the model representation of a BrickCell in a BrickCollectionView
open class Brick: CustomStringConvertible {

    // MARK: - Public members

    /// Identifier of the brick. Defaults to empty string
    open let identifier: String

    /// Passes string to BrickCell's accessibilityIdentifier for UIAccessibility.  Defaults to the brick identifier
    open var accessibilityIdentifier: String

    /// Passes string to BrickCell's accessibilityLabel for UIAccessibility.  Defaults to nil
    open var accessibilityLabel: String?

    /// Passes string to BrickCell's accessibilityHint for UIAccessibility.  Defaults to nil
    open var accessibilityHint: String?

    /// Size of the brick
    open var size: BrickSize

    /// Indicates if the brick is hidden
    open var isHidden: Bool = false

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

    /// Repeat Count for the brick. 
    /// This will be overwritten if there is a repeatCountDataSource specified
    open var repeatCount: Int = 1
    
    /// Delegate that handles behavior for how to present other view controllers using 3D Touch
    open weak var previewingDelegate: BrickPreviewingDelegate?
    
    private weak var _dragDropDelegate: AnyObject?
    @available(iOS 11.0, *)
    open weak var dragDropDelegate: BrickDragDropDelegate? {
        get {
            return _dragDropDelegate as? BrickDragDropDelegate
        }
        set(newDelegate) {
            _dragDropDelegate = newDelegate
        }
    }
    
    
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

    // MARK: - Internal

    /// Keeps track of the counts per collection info
    internal var counts: [CollectionInfo:Int] = [:]

    /// Get the count for a given collection info
    func count(for collection: CollectionInfo) -> Int {
        return counts[collection] ?? self.repeatCount
    }

    // MARK: - Loading nibs/cells

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

    // MARK: - CustomStringConvertible

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

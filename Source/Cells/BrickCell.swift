//
//  BrickCell.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit

// Mark: - Resizeable cells

public typealias CellSizeChangedHandler = ((cell: BrickCell) -> Void)

public protocol AsynchronousResizableCell {
    var sizeChangedHandler: CellSizeChangedHandler? { get set }
}

public protocol ImageDownloaderCell {
    var imageDownloader: ImageDownloader? { get set }
}

public protocol BrickCellTapDelegate: UIGestureRecognizerDelegate {
    func didTapBrickCell(brickCell: BrickCell)
}

public protocol Bricklike {
    associatedtype BrickType: Brick
    var brick: BrickType { get }
    var index: Int { get }
    var collectionIndex: Int { get }
    var collectionIdentifier: String? { get }
}

extension Bricklike where Self : BrickCell {
    public var brick: BrickType { return _brick as! BrickType }
}

public class BaseBrickCell: UICollectionViewCell {

    // Using the UICollectionViewCell.backgroundView is not really stable
    // Especially when reusing cells, the backgroundView might disappear and reappear when scrolling up or down
    // The suspicion is that the `removeFromSuperview()` is called, even if the view is no longer part of the cell
    // http://stackoverflow.com/questions/23059811/is-uicollectionview-backgroundview-broken
    var brickBackgroundView: UIView? {
        didSet {
            if oldValue?.superview == self.contentView {
                //Make sure not to remove the oldValue from its current superview if it's not this contentview (reusability)
                oldValue?.removeFromSuperview()
            }
            if let view = brickBackgroundView {
                view.frame = self.bounds
                view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
                self.contentView.insertSubview(view, atIndex: 0)
            }
        }
    }

    public lazy var bottomSeparatorLine: UIView = {
        return UIView()
    }()

    public lazy var topSeparatorLine: UIView = {
        return UIView()
    }()

    public override func layoutSubviews() {
        super.layoutSubviews()
        brickBackgroundView?.frame = self.bounds
    }
}

// MARK: UI Convenience Methods
extension BaseBrickCell {

    public func removeSeparators() {
        bottomSeparatorLine.removeFromSuperview()
        topSeparatorLine.removeFromSuperview()
    }

    public func addSeparatorLine(width: CGFloat, onTop: Bool? = false, xOrigin: CGFloat = 0, backgroundColor: UIColor = .lightGrayColor(), height: CGFloat = 0.5) {

        let separator = (onTop == true) ? topSeparatorLine : bottomSeparatorLine

        separator.frame = self.contentView.frame
        separator.backgroundColor = backgroundColor
        separator.frame.size.height = height
        separator.frame.size.width = width

        separator.frame.origin.x = xOrigin
        let originY = (onTop == true) ? 0 : (self.frame.height - separator.frame.height)
        separator.frame.origin.y = originY
        self.contentView.addSubview(separator)
    }
}

public class BrickCell: BaseBrickCell {

    private var _brick: Brick!
    public var tapGesture: UITapGestureRecognizer?
    public private(set) var index: Int = 0
    public private(set) var collectionIndex: Int = 0
    public private(set) var collectionIdentifier: String?

    #if os(tvOS)
    public var allowsFocus: Bool = true
    #endif

    @IBOutlet weak internal var topSpaceConstraint: NSLayoutConstraint? {
        didSet { defaultTopConstraintConstant = topSpaceConstraint?.constant ?? 0 }
    }
    @IBOutlet weak internal var bottomSpaceConstraint: NSLayoutConstraint? {
        didSet { defaultBottomConstraintConstant = bottomSpaceConstraint?.constant ?? 0 }
    }
    @IBOutlet weak internal var leftSpaceConstraint: NSLayoutConstraint? {
        didSet { defaultLeftConstraintConstant = leftSpaceConstraint?.constant ?? 0 }
    }
    @IBOutlet weak internal var rightSpaceConstraint: NSLayoutConstraint? {
        didSet { defaultRightConstraintConstant = rightSpaceConstraint?.constant ?? 0 }
    }

    private var defaultTopConstraintConstant: CGFloat = 0
    private var defaultBottomConstraintConstant: CGFloat = 0
    private var defaultLeftConstraintConstant: CGFloat = 0
    private var defaultRightConstraintConstant: CGFloat = 0

    public var defaultEdgeInsets: UIEdgeInsets {
        return UIEdgeInsetsMake(defaultTopConstraintConstant, defaultLeftConstraintConstant, defaultBottomConstraintConstant, defaultRightConstraintConstant)
    }

    public dynamic var edgeInsets: UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            self.topSpaceConstraint?.constant = edgeInsets.top
            self.bottomSpaceConstraint?.constant = edgeInsets.bottom
            self.leftSpaceConstraint?.constant = edgeInsets.left
            self.rightSpaceConstraint?.constant = edgeInsets.right
        }
    }

    public func setContent(brick: Brick, index: Int, collectionIndex: Int, collectionIdentifier: String?) {
        self._brick = brick
        self.index = index
        self.collectionIndex = collectionIndex
        self.collectionIdentifier = collectionIdentifier

        self.userInteractionEnabled = true
        if let gesture = self.tapGesture {
            self.removeGestureRecognizer(gesture)
        }
        self.tapGesture = nil
        if let _ = brick.brickCellTapDelegate {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(BrickCell.didTapCell))
            gesture.delegate = brick.brickCellTapDelegate
            self.tapGesture = gesture
            addGestureRecognizer(gesture)
        }

        reloadContent()
    }

    public func updateContent() {

    }

    internal func reloadContent() {
        updateContent()
    }

    func didTapCell() {
        _brick.brickCellTapDelegate?.didTapBrickCell(self)
    }

    public override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard self._brick.height.isEstimate(in: self) else {
            return layoutAttributes
        }

        let preferred = layoutAttributes.copy() as! UICollectionViewLayoutAttributes

        let size = CGSize(width: layoutAttributes.frame.width, height: self.heightForBrickView(withWidth: layoutAttributes.frame.width))
        preferred.frame.size = size
        return preferred
    }

    public func heightForBrickView(withWidth width: CGFloat) -> CGFloat {
        self.layoutIfNeeded()

        let size = self.systemLayoutSizeFittingSize(CGSize(width: width, height: 0), withHorizontalFittingPriority: 1000, verticalFittingPriority: 10)
        return size.height
    }

}


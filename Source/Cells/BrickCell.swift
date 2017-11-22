//
//  BrickCell.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit

// Mark: - Resizeable cells

public protocol AsynchronousResizableCell: class  {
    weak var resizeDelegate: AsynchronousResizableDelegate? { get set }
}

public protocol AsynchronousResizableDelegate: class {
    func performResize(cell: BrickCell, completion: (() -> Void)?)
}

public protocol ImageDownloaderCell {
    weak var imageDownloader: ImageDownloader? { get set }
}

public protocol BrickCellTapDelegate: UIGestureRecognizerDelegate {
    func didTapBrickCell(_ brickCell: BrickCell)
}

public protocol OverrideContentSource: class {
    func overrideContent(for brickCell: BrickCell)
    func resetContent(for brickCell: BrickCell)
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

open class BaseBrickCell: UICollectionViewCell {

    open fileprivate(set) var index: Int = 0
    open fileprivate(set) var collectionIndex: Int = 0
    open fileprivate(set) var collectionIdentifier: String?

    internal fileprivate(set) var _brick: Brick! {
        didSet {
            self.accessibilityIdentifier = _brick.accessibilityIdentifier
            self.accessibilityLabel = _brick.accessibilityLabel
            self.accessibilityHint = _brick.accessibilityHint
        }
    }

    open var identifier: String {
        return _brick.identifier
    }

    // This value stores the expected width, so we can identify when this is met
    private var requestedSize: CGSize = .zero

    open func setContent(_ brick: Brick, index: Int, collectionIndex: Int, collectionIdentifier: String?) {
        self._brick = brick
        self.index = index
        self.collectionIndex = collectionIndex
        self.collectionIdentifier = collectionIdentifier
    }

    open func setIndex(index: Int) {
        self.index = index
    }

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
                view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                self.contentView.insertSubview(view, at: 0)
            }
        }
    }

    open lazy var bottomSeparatorLine: UIView = {
        return UIView()
    }()

    open lazy var topSeparatorLine: UIView = {
        return UIView()
    }()
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        self.requestedSize = layoutAttributes.frame.size

        // Setting zPosition instead of relaying on
        // UICollectionView zIndex management 'fixes' the issue
        // http://stackoverflow.com/questions/12659301/uicollectionview-setlayoutanimated-not-preserving-zindex
        self.layer.zPosition = CGFloat(layoutAttributes.zIndex)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        brickBackgroundView?.frame = self.bounds

        if _brick != nil && frame.width == requestedSize.width {
            self.layoutIfNeeded() // This layoutIfNeeded is added to make sure that the subviews are laid out correctly
            self.framesDidLayout()
        }
    }

    open func framesDidLayout() {
        // No-op - available for others to implement
    }
}

// MARK: UI Convenience Methods
extension BaseBrickCell {

    public func removeSeparators() {
        bottomSeparatorLine.removeFromSuperview()
        topSeparatorLine.removeFromSuperview()
    }

    public func addSeparatorLine(_ width: CGFloat, onTop: Bool? = false, xOrigin: CGFloat = 0, backgroundColor: UIColor = UIColor.lightGray, height: CGFloat = 0.5) {

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

open class BrickCell: BaseBrickCell {

    open var tapGesture: UITapGestureRecognizer?

    #if os(tvOS)
    @objc public var allowsFocus: Bool = true
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

    fileprivate var defaultTopConstraintConstant: CGFloat = 0
    fileprivate var defaultBottomConstraintConstant: CGFloat = 0
    fileprivate var defaultLeftConstraintConstant: CGFloat = 0
    fileprivate var defaultRightConstraintConstant: CGFloat = 0

    open var defaultEdgeInsets: UIEdgeInsets {
        return UIEdgeInsetsMake(defaultTopConstraintConstant, defaultLeftConstraintConstant, defaultBottomConstraintConstant, defaultRightConstraintConstant)
    }

    open var needsLegacyEdgeInsetFunctionality = false
    private var didUpdateEdgeInsets: Bool = false
    @objc open dynamic var edgeInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {

            if edgeInsets == oldValue && needsLegacyEdgeInsetFunctionality {
                return
            }

            self.topSpaceConstraint?.constant = edgeInsets.top
            self.bottomSpaceConstraint?.constant = edgeInsets.bottom
            self.leftSpaceConstraint?.constant = edgeInsets.left
            self.rightSpaceConstraint?.constant = edgeInsets.right

            if needsLegacyEdgeInsetFunctionality {
                didUpdateEdgeInsets = true
            }
        }
    }

    open override func setContent(_ brick: Brick, index: Int, collectionIndex: Int, collectionIdentifier: String?) {
        super.setContent(brick, index: index, collectionIndex: collectionIndex, collectionIdentifier: collectionIdentifier)

        self.isUserInteractionEnabled = true
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

    open func updateContent() {

    }

    internal func reloadContent() {
        self._brick.overrideContentSource?.resetContent(for: self)
        updateContent()
        self._brick.overrideContentSource?.overrideContent(for: self)
    }
    
    @objc func didTapCell() {
        _brick.brickCellTapDelegate?.didTapBrickCell(self)
    }
    
    open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard self._brick.height.isEstimate(withValue: nil) else {
            return layoutAttributes
        }

        if needsLegacyEdgeInsetFunctionality {
            if !didUpdateEdgeInsets {
                guard let brickAttributes = layoutAttributes as? BrickLayoutAttributes, brickAttributes.isEstimateSize else {
                    return layoutAttributes
                }
            }
            didUpdateEdgeInsets = false
        }
        
        let preferred = layoutAttributes

        // We're inverting the frame because the given frame is already transformed
        var invertedFrame = layoutAttributes.frame.applying(layoutAttributes.transform.inverted())
        let size = CGSize(width: layoutAttributes.frame.width, height: self.heightForBrickView(withWidth: invertedFrame.width))

        // Setting the size of the frame will return the "transformed" size
        invertedFrame.size = size

        // We need to invert the frame again, because UILayoutAttributes will transform the frame again
        preferred.frame = invertedFrame.applying(layoutAttributes.transform.inverted())

        return preferred
    }

    open func heightForBrickView(withWidth width: CGFloat) -> CGFloat {
        self.layoutIfNeeded()

        let size = self.systemLayoutSizeFitting(CGSize(width: width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: UILayoutPriority(rawValue: 10))
        switch _brick.size.height.dimension(withValue: size.height) {
        case .restricted(_, let restriction):
            return BrickDimension.restrictedValue(for: size.height, width: width, restrictedSize: restriction)
        default:
            return size.height
        }
    }

}

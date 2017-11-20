//
//  GenericBrick.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 1/23/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import UIKit

protocol ViewGenerator {
    func generateView(_ frame: CGRect, in cell: GenericBrickCell) -> UIView
    func configure(view: UIView, cell: GenericBrickCell)
}

public protocol FrameLayoutListener: class {
    func didLayoutFrames(cell: GenericBrickCell)
}

public typealias HeightProviderHandler = ((_ width: CGFloat) -> CGFloat)

open class GenericBrick<T: UIView>: Brick, ViewGenerator {
    public typealias ConfigureView = (_ view: T, _ cell: GenericBrickCell) -> Void

    open var configureView: ConfigureView
    open weak var frameLayoutListener: FrameLayoutListener?

    public convenience init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, configureView: @escaping ConfigureView) {
        self.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView, configureView: configureView)
    }

    public init(_ identifier: String = "", size: BrickSize, backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, configureView: @escaping ConfigureView) {
        self.configureView = configureView
        super.init(identifier, size: size, backgroundColor: backgroundColor, backgroundView: backgroundView)
    }

    // Override this property to ensure that the identifier is correctly set (as it uses generics, `NSStringForClass` isn't reliable)
    open override class var internalIdentifier: String {
        let generic = NSStringFromClass(T.self)
        return "GenericBrick[\(generic)]"
    }

    open class override var cellClass: UICollectionViewCell.Type? {
        return GenericBrickCell.self
    }

    open func generateView(_ frame: CGRect, in cell: GenericBrickCell) -> UIView {
        let view = T(frame: frame)

        view.backgroundColor = UIColor.clear

        return view
    }

    func configure(view: UIView, cell: GenericBrickCell) {
        cell.frameLayoutListener = (view as? FrameLayoutListener) ?? self.frameLayoutListener
        self.configureView(view as! T, cell)
    }

}

open class GenericBrickCell: BrickCell {

    open private(set) var genericContentView: UIView?
    open var accessoryView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()

            if let accessoryView = self.accessoryView {
                accessoryView.translatesAutoresizingMaskIntoConstraints = false
                self.contentView.addSubview(accessoryView)
            }

            if let genericContentView = self.genericContentView {
                reconfigureConstraints(genericContentView: genericContentView)
            }
        }
    }
    
    open var customHeightProvider: HeightProviderHandler?
    open weak var frameLayoutListener: FrameLayoutListener?

    internal private(set) var fromNib: Bool = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        clearBackgroundColors()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clearBackgroundColors()
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        clearBackgroundColors()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        fromNib = true
    }

    fileprivate func clearBackgroundColors() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
    }

    open override func updateContent() {
        super.updateContent()

        guard !fromNib else {
            return
        }

        if let generic = self._brick as? ViewGenerator {
            if let genericContentView = self.genericContentView {
                generic.configure(view: genericContentView, cell: self)
            } else {

                // Setup generic content view
                let genericContentView = generic.generateView(self.frame, in: self)
                generic.configure(view: genericContentView, cell: self)
                genericContentView.translatesAutoresizingMaskIntoConstraints = false
                self.contentView.addSubview(genericContentView)

                reconfigureConstraints(genericContentView: genericContentView)

                // Assign to instance
                self.genericContentView = genericContentView
            }
        } else {
            clearContentViewAndConstraints()
        }
    }

    fileprivate func reconfigureConstraints(genericContentView: UIView) {
        // Remove previous constraints
        self.contentView.removeConstraints(self.contentView.constraints)

        // Setup constraints
        let topSpaceConstraint = genericContentView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: edgeInsets.top)
        let bottomSpaceConstraint = self.contentView.bottomAnchor.constraint(equalTo: genericContentView.bottomAnchor, constant: edgeInsets.bottom)
        let leftSpaceConstraint = genericContentView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: edgeInsets.left)


        let rightSpaceConstraint: NSLayoutConstraint
        if let accessoryView = self.accessoryView {
            rightSpaceConstraint = self.contentView.rightAnchor.constraint(equalTo: accessoryView.rightAnchor, constant: edgeInsets.right)
            accessoryView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            genericContentView.setContentHuggingPriority(.defaultLow, for: .horizontal)

            accessoryView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            genericContentView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            self.contentView.addConstraints([
                accessoryView.centerYAnchor.constraint(equalTo: genericContentView.centerYAnchor),
                accessoryView.leftAnchor.constraint(equalTo: genericContentView.rightAnchor, constant: 0),
                ])

        } else {
            rightSpaceConstraint = self.contentView.rightAnchor.constraint(equalTo: genericContentView.rightAnchor, constant: edgeInsets.right)
        }

        self.contentView.addConstraints([
            topSpaceConstraint,
            bottomSpaceConstraint,
            leftSpaceConstraint,
            rightSpaceConstraint
            ])
        self.contentView.setNeedsUpdateConstraints()

        self.topSpaceConstraint = topSpaceConstraint
        self.bottomSpaceConstraint = bottomSpaceConstraint
        self.leftSpaceConstraint = leftSpaceConstraint
        self.rightSpaceConstraint = rightSpaceConstraint
    }

    fileprivate func clearContentViewAndConstraints() {
        genericContentView?.removeFromSuperview()
        genericContentView = nil

        topSpaceConstraint = nil
        bottomSpaceConstraint = nil
        leftSpaceConstraint = nil
        rightSpaceConstraint = nil
    }

    open override func framesDidLayout() {
        super.framesDidLayout()
        frameLayoutListener?.didLayoutFrames(cell: self)
    }

    open override func heightForBrickView(withWidth width: CGFloat) -> CGFloat {
        if let heightProvider = customHeightProvider {
            let height = heightProvider(width)
            return height
        } else {
            return super.heightForBrickView(withWidth: width)
        }
    }

}

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
}

open class GenericBrick<T: UIView>: Brick, ViewGenerator {
    public typealias ConfigureView = (_ view: T, _ cell: GenericBrickCell) -> Void

    open var configureView: ConfigureView

    public convenience init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, configureView: @escaping ConfigureView) {
        self.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView, configureView: configureView)
    }

    public init(_ identifier: String = "", size: BrickSize, backgroundColor: UIColor = .clear(), backgroundView: UIView? = nil, configureView: @escaping ConfigureView) {
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

        viee.backgroundColor = UIColor.clear

        self.configureView(view, cell)

        return view
    }

}

open class GenericBrickCell: BrickCell {

    var genericContentView: UIView?

    var fromNib: Bool = false

    open override func awakeFromNib() {
        super.awakeFromNib()
        fromNib = true
    }

    open override func updateContent() {
        super.updateContent()

        guard !fromNib else {
            return
        }

        clearContentViewAndConstraints()

        backgroundColor = .clearColor()
        contentView.backgroundColor = .clearColor()

        if let generic = self._brick as? ViewGenerator {
            let genericContentView = generic.generateView(self.frame, in: self)
            genericContentView.translatesAutoresizingMaskIntoConstraints = false

            self.contentView.addSubview(genericContentView)

            let topSpaceConstraint = genericContentView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: edgeInsets.top)
            let bottomSpaceConstraint = self.contentView.bottomAnchor.constraint(equalTo: genericContentView.bottomAnchor, constant: edgeInsets.bottom)
            let leftSpaceConstraint = genericContentView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: edgeInsets.left)
            let rightSpaceConstraint = self.contentView.rightAnchor.constraint(equalTo: genericContentView.rightAnchor, constant: edgeInsets.right)

            self.contentView.addConstraints([topSpaceConstraint, bottomSpaceConstraint, leftSpaceConstraint, rightSpaceConstraint])
            self.contentView.setNeedsUpdateConstraints()

            // Assign to instance
            self.genericContentView = genericContentView
            self.topSpaceConstraint = topSpaceConstraint
            self.bottomSpaceConstraint = bottomSpaceConstraint
            self.leftSpaceConstraint = leftSpaceConstraint
            self.rightSpaceConstraint = rightSpaceConstraint
        }

<<<<<<< HEAD
=======
        backgroundColor = .clear()
        contentView.backgroundColor = .clear()
        genericContentView?.backgroundColor = .clear()

>>>>>>> e6dc8ea... 1st part of the conversion: With the swift conversion tool
    }

    fileprivate func clearContentViewAndConstraints() {
        genericContentView?.removeFromSuperview()
        genericContentView = nil

        topSpaceConstraint = nil
        bottomSpaceConstraint = nil
        leftSpaceConstraint = nil
        rightSpaceConstraint = nil
    }

}

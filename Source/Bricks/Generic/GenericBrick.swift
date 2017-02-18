//
//  GenericBrick.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 1/23/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import UIKit

protocol ViewGenerator {
    func generateView(frame: CGRect, in cell: GenericBrickCell) -> UIView
    func configureView(view: UIView, cell: GenericBrickCell)
}

public class GenericBrick<T: UIView>: Brick, ViewGenerator {
    public typealias ConfigureView = (view: T, cell: GenericBrickCell) -> Void

    public var configureView: ConfigureView

    public convenience init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = UIColor.clearColor(), backgroundView: UIView? = nil, configureView: ConfigureView) {
        self.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView, configureView: configureView)
    }

    public init(_ identifier: String = "", size: BrickSize, backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, configureView: ConfigureView) {
        self.configureView = configureView
        super.init(identifier, size: size, backgroundColor: backgroundColor, backgroundView: backgroundView)
    }

    // Override this property to ensure that the identifier is correctly set (as it uses generics, `NSStringForClass` isn't reliable)
    public override class var internalIdentifier: String {
        let generic = NSStringFromClass(T.self)
        return "GenericBrick[\(generic)]"
    }

    public class override var cellClass: UICollectionViewCell.Type? {
        return GenericBrickCell.self
    }

    public func generateView(frame: CGRect, in cell: GenericBrickCell) -> UIView {
        let view = T(frame: frame)

        view.backgroundColor = .clearColor()

        return view
    }

    func configureView(view: UIView, cell: GenericBrickCell) {
        self.configureView(view: view as! T, cell: cell)
    }

}

public class GenericBrickCell: BrickCell {

    var genericContentView: UIView?

    var fromNib: Bool = false

    public override func awakeFromNib() {
        super.awakeFromNib()
        fromNib = true
    }

    public override func updateContent() {
        super.updateContent()

        guard !fromNib else {
            return
        }

        backgroundColor = .clearColor()
        contentView.backgroundColor = .clearColor()

        if let generic = self._brick as? ViewGenerator {
            if let genericContentView = self.genericContentView {
                generic.configureView(genericContentView, cell: self)
            } else {
                let genericContentView = generic.generateView(self.frame, in: self)
                generic.configureView(genericContentView, cell: self)
                genericContentView.translatesAutoresizingMaskIntoConstraints = false

                self.contentView.addSubview(genericContentView)

                let topSpaceConstraint = genericContentView.topAnchor.constraintEqualToAnchor(self.contentView.topAnchor, constant: edgeInsets.top)
                let bottomSpaceConstraint = self.contentView.bottomAnchor.constraintEqualToAnchor(genericContentView.bottomAnchor, constant: edgeInsets.bottom)
                let leftSpaceConstraint = genericContentView.leftAnchor.constraintEqualToAnchor(self.contentView.leftAnchor, constant: edgeInsets.left)
                let rightSpaceConstraint = self.contentView.rightAnchor.constraintEqualToAnchor(genericContentView.rightAnchor, constant: edgeInsets.right)

                self.contentView.addConstraints([topSpaceConstraint, bottomSpaceConstraint, leftSpaceConstraint, rightSpaceConstraint])
                self.contentView.setNeedsUpdateConstraints()

                // Assign to instance
                self.genericContentView = genericContentView
                self.topSpaceConstraint = topSpaceConstraint
                self.bottomSpaceConstraint = bottomSpaceConstraint
                self.leftSpaceConstraint = leftSpaceConstraint
                self.rightSpaceConstraint = rightSpaceConstraint
            }
        } else {
            clearContentViewAndConstraints()
        }

    }

    private func clearContentViewAndConstraints() {
        genericContentView?.removeFromSuperview()
        genericContentView = nil

        topSpaceConstraint = nil
        bottomSpaceConstraint = nil
        leftSpaceConstraint = nil
        rightSpaceConstraint = nil
    }

}

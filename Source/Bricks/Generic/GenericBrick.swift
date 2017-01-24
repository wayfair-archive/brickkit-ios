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
}

public class GenericBrick<T: UIView>: Brick, ViewGenerator {
    public typealias ConfigureView = (view: T, cell: GenericBrickCell) -> Void

    public var configureView: ConfigureView

    public init(_ identifier: String = "", size: BrickSize, backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, configureView: ConfigureView) {
        self.configureView = configureView
        super.init(identifier, size: size, backgroundColor: backgroundColor, backgroundView: backgroundView)
    }

    /// Class variable: Default nib name to be used for this brick's cell
    // If not overriden, it uses the same as the Brick class
    public override class var nibName: String {
        let generic = NSStringFromClass(T.self).componentsSeparatedByString(".").last!
        return "Generic[\(generic)]"
    }

    public class override var cellClass: UICollectionViewCell.Type? {
        return GenericBrickCell.self
    }

    public func generateView(frame: CGRect, in cell: GenericBrickCell) -> UIView {
        let view = T(frame: frame)

        self.configureView(view: view, cell: cell)

        return view
    }

}

public class GenericBrickCell: BrickCell {

    var genericContentView: UIView?

    public override func updateContent() {
        super.updateContent()

        clearContentViewAndConstraints()

        if let generic = self._brick as? ViewGenerator {
            let genericContentView = generic.generateView(self.frame, in: self)
            genericContentView.translatesAutoresizingMaskIntoConstraints = false

            self.contentView.addSubview(genericContentView)

            let topSpaceConstraint = NSLayoutConstraint(item: genericContentView, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1, constant: edgeInsets.top)
            let bottomSpaceConstraint = NSLayoutConstraint(item: self.contentView, attribute: .Bottom, relatedBy: .Equal, toItem: genericContentView, attribute: .Bottom, multiplier: 1, constant: edgeInsets.bottom)
            let leftSpaceConstraint = NSLayoutConstraint(item: genericContentView, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1, constant: edgeInsets.left)
            let rightSpaceConstraint = NSLayoutConstraint(item: self.contentView, attribute: .Right, relatedBy: .Equal, toItem: genericContentView, attribute: .Right, multiplier: 1, constant: edgeInsets.right)

            self.contentView.addConstraints([topSpaceConstraint, bottomSpaceConstraint, leftSpaceConstraint, rightSpaceConstraint])
            self.contentView.setNeedsUpdateConstraints()

            // Assign to instance
            self.genericContentView = genericContentView
            self.topSpaceConstraint = topSpaceConstraint
            self.bottomSpaceConstraint = bottomSpaceConstraint
            self.leftSpaceConstraint = leftSpaceConstraint
            self.rightSpaceConstraint = rightSpaceConstraint
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

//
//  NiblessBrick.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 10/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

typealias ConfigureNiblessCellBlock = ((cell: NiblessBrickCell) -> Void)

class NiblessBrick: Brick {
    var text: String
    var image: UIImage
    var configureCell: ConfigureNiblessCellBlock

    override class var cellClass: UICollectionViewCell.Type? {
        return NiblessBrickCell.self
    }

    init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, text: String, image: UIImage, configureCell: ConfigureNiblessCellBlock) {
        self.text = text
        self.image = image
        self.configureCell = configureCell
        super.init(identifier, width: width, height: height, backgroundColor:backgroundColor, backgroundView:backgroundView)
    }

}

class NiblessBrickCell: BrickCell, Bricklike {
    typealias BrickType = NiblessBrick

    var label: UILabel = UILabel()
    var imageView: UIImageView = UIImageView()
    var heightConstraint: NSLayoutConstraint!

    var inset: CGFloat = 5

    override init(frame: CGRect) {
        super.init(frame: frame)
        initComponents()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initComponents()
    }

    private func initComponents() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(label)
        contentView.addSubview(imageView)

        // Image Constraints
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: inset))
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: inset))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: inset))

        // Label Constraints
        contentView.addConstraint(NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: imageView, attribute: .Right, multiplier: 1, constant: inset))
        contentView.addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: inset))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: label, attribute: .Bottom, multiplier: 1, constant: inset))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Right, relatedBy: .Equal, toItem: label, attribute: .Right, multiplier: 1, constant: inset))
    }

    override func updateContent() {
        super.updateContent()

        label.text = brick.text
        imageView.image = brick.image

        brick.configureCell(cell: self)
    }

}

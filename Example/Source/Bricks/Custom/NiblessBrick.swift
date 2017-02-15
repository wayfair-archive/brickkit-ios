//
//  NiblessBrick.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 10/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

typealias ConfigureNiblessCellBlock = ((_ cell: NiblessBrickCell) -> Void)

class NiblessBrick: Brick {
    var text: String
    var image: UIImage
    var configureCell: ConfigureNiblessCellBlock

    override class var cellClass: UICollectionViewCell.Type? {
        return NiblessBrickCell.self
    }

    init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, text: String, image: UIImage, configureCell: @escaping ConfigureNiblessCellBlock) {
        self.text = text
        self.image = image
        self.configureCell = configureCell
        super.init(identifier, size: BrickSize(width: width, height: height), backgroundColor:backgroundColor, backgroundView:backgroundView)
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
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: inset))
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: inset))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: inset))

        // Label Constraints
        contentView.addConstraint(NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: imageView, attribute: .right, multiplier: 1, constant: inset))
        contentView.addConstraint(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: inset))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1, constant: inset))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: label, attribute: .right, multiplier: 1, constant: inset))
    }

    override func updateContent() {
        super.updateContent()

        label.text = brick.text
        imageView.image = brick.image

        brick.configureCell(self)
    }

}

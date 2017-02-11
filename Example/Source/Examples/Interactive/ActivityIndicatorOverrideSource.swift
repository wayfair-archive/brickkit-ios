//
//  ActivityIndici.swift
//  BrickKit-Example
//
//  Created by Stephen Tam on 1/6/17.
//  Copyright © 2017 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit


class ActivityIndicatorOverrideSource: OverrideContentSource {
    var shouldOverride: Bool = false

    func overrideContent(for brickCell: BrickCell) {
        if shouldOverride {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            indicator.tag = 1
            indicator.backgroundColor = brickCell.contentView.backgroundColor
            indicator.translatesAutoresizingMaskIntoConstraints = false
            brickCell.contentView.addSubview(indicator)

            brickCell.contentView.addConstraints([
                NSLayoutConstraint(item: indicator, attribute: .left, relatedBy: .equal, toItem: brickCell.contentView, attribute: .left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: indicator, attribute: .top, relatedBy: .equal, toItem: brickCell.contentView, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: indicator, attribute: .right, relatedBy: .equal, toItem: brickCell.contentView, attribute: .right, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: indicator, attribute: .bottom, relatedBy: .equal, toItem: brickCell.contentView, attribute: .bottom, multiplier: 1, constant: 0)
                ])
            
            indicator.startAnimating()
        }
    }

    func resetContent(for brickCell: BrickCell) {
        if let view = brickCell.contentView.viewWithTag(1) {
            view.removeFromSuperview()
            if let indicator = view as? UIActivityIndicatorView {
                indicator.stopAnimating()
            }
        }
    }
}

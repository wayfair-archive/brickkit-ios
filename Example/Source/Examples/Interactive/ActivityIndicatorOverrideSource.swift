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
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
            indicator.tag = 1
            indicator.backgroundColor = brickCell.contentView.backgroundColor
            indicator.translatesAutoresizingMaskIntoConstraints = false
            brickCell.contentView.addSubview(indicator)

            brickCell.contentView.addConstraints([
                NSLayoutConstraint(item: indicator, attribute: .Left, relatedBy: .Equal, toItem: brickCell.contentView, attribute: .Left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: indicator, attribute: .Top, relatedBy: .Equal, toItem: brickCell.contentView, attribute: .Top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: indicator, attribute: .Right, relatedBy: .Equal, toItem: brickCell.contentView, attribute: .Right, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: indicator, attribute: .Bottom, relatedBy: .Equal, toItem: brickCell.contentView, attribute: .Bottom, multiplier: 1, constant: 0)
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

//
//  TwoLabelView.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 5/28/17.
//  Copyright © 2017 Wayfair LLC. All rights reserved.
//

import UIKit

class TwoLabelView: UIView {
    var label: UILabel = UILabel()
    var subLabel: UILabel = UILabel()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        subLabel.numberOfLines = 2

        #if os(tvOS)
            subLabel.font = UIFont.brickLightFont(size: 25)
        #else
            subLabel.font = UIFont.brickLightFont(size: 15)
        #endif

        label.translatesAutoresizingMaskIntoConstraints = false
        subLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(label)
        self.addSubview(subLabel)

        self.addConstraints([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.rightAnchor.constraint(equalTo: label.rightAnchor),
            subLabel.topAnchor.constraint(equalTo: label.bottomAnchor),
            subLabel.leftAnchor.constraint(equalTo: label.leftAnchor),
            subLabel.rightAnchor.constraint(equalTo: label.rightAnchor),
            subLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])
    }

}

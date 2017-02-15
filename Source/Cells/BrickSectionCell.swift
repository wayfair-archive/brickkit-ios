//
//  BrickSectionCell.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit

class BrickSectionCell: BaseBrickCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.isUserInteractionEnabled = false
        self.contentView.isUserInteractionEnabled = false
    }
}

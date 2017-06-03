//
//  SimpleRepeatFixedWidthViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/12/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class SimpleRepeatFixedWidthViewController: BaseRepeatBrickViewController, HasTitle {

    class var brickTitle: String {
        return "Fixed Width"
    }
    class var subTitle: String {
        return "Example how to setup bricks using a fixed width"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        repeatLabel.width = .fixed(size: 80)
        repeatLabel.height = .auto(estimate: .fixed(size: 38.0))
        brickCollectionView.section.alignment = BrickAlignment(horizontal: .justified, vertical: .top)
    }

}

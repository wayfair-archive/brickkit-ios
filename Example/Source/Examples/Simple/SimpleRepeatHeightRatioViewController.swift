//
//  SimpleRepeatFixedWidthViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/12/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

class SimpleRepeatHeightRatioViewController: BaseRepeatBrickViewController, HasTitle {
    
    class var brickTitle: String {
        return "Height Ratio"
    }

    class var subTitle: String {
        return "Example how to setup bricks using a height ratio"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        repeatLabel.width = .ratio(ratio: 1 / 4)
        repeatLabel.height = .ratio(ratio: 1)
    }

}

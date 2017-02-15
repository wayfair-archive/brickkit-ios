//
//  SimpleRepeatFixedWidthViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/12/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

class SimpleRepeatFixedHeightViewController: BaseRepeatBrickViewController {

    override class var title: String {
        return "Fixed Height"
    }
    override class var subTitle: String {
        return "Example how to setup bricks using a fixed height"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        repeatLabel.width = .ratio(ratio: 1/4)
        repeatLabel.height = .fixed(size: 80)
    }

}

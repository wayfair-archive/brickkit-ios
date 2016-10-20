//
//  SimpleRepeatFixedWidthViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/12/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

class SimpleRepeatFixedWidthViewController: BaseRepeatBrickViewController {

    override class var title: String {
        return "Fixed Width"
    }
    override class var subTitle: String {
        return "Example how to setup bricks using a fixed width"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        repeatLabel.width = .Fixed(size: 80)
        repeatLabel.height = .Auto(estimate: .Fixed(size: 38.0))
    }

}

//
//  TestBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class TestBrickViewController: BrickViewController, BrickRegistrationDataSource {

    var brickRegistered = false
    
    func registerBricks() {
        brickRegistered = true
    }

    deinit {
        NSNotificationCenter.defaultCenter().postNotificationName("BrickViewController.deinit", object: nil)
    }
}

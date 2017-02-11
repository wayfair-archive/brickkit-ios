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
    var labelTest = false
    
    func registerBricks() {
        brickRegistered = true
        
        if labelTest {
            self.brickCollectionView.registerBrickClass(LabelBrick.self)
            self.brickCollectionView.setSection(BrickSection(bricks: [LabelBrick(text: "This is a Test")]))
        }
    }

    deinit {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BrickViewController.deinit"), object: nil)
    }
}

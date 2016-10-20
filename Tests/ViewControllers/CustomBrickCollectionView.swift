//
//  CustomBrickCollectionView.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/19/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

class CustomBrickCollectionView: BrickCollectionView {
    deinit {
        NSNotificationCenter.defaultCenter().postNotificationName("CustomBrickCollectionView.deinit", object: nil)
    }
}

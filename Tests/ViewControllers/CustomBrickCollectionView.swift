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
        NotificationCenter.default.post(name: Notification.Name(rawValue: "CustomBrickCollectionView.deinit"), object: nil)
    }
}

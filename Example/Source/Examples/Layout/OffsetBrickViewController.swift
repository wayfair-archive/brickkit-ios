//
//  OffsetBrickViewController.swift
//  BrickKit
//
//  Created by Justin Shiiba on 6/8/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class OffsetBrickViewController: BaseRepeatBrickViewController, HasTitle {
    class var brickTitle: String {
        return "Offset Behavior"
    }
    class var subTitle: String {
        return "Shows how an offset behavior can be used"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        behavior = OffsetLayoutBehavior(dataSource: self)
    }
}

extension OffsetBrickViewController: OffsetLayoutBehaviorDataSource {
    func offsetLayoutBehaviorWithOrigin(_ behavior: OffsetLayoutBehavior, originOffsetForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize? {
        if identifier == BrickIdentifiers.titleLabel {
            return CGSize(width: 20, height: -50)
        } else {
            return nil
        }
    }

    func offsetLayoutBehavior(_ behavior: OffsetLayoutBehavior, sizeOffsetForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize? {
        if identifier == BrickIdentifiers.titleLabel {
            return CGSize(width: 0, height: 80)
        } else {
            return nil
        }
    }
}

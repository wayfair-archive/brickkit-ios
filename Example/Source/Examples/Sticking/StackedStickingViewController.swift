//
//  StackedStickingViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class StackedStickingViewController: BaseRepeatBrickViewController, HasTitle {
    class var brickTitle: String {
        return "Stacked Headers"
    }
    class var subTitle: String {
        return "Example how headers stack while scrolling"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        repeatLabel.width = .ratio(ratio: 1)
        titleLabelModel.text = "All uneven bricks should stick"

        behavior = StickyLayoutBehavior(dataSource: self)
    }
}

extension StackedStickingViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(_ stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return identifier != BrickIdentifiers.titleLabel && indexPath.row % 2 != 0
    }
}

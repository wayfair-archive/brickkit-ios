//
//  BasicStickingViewController.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/31/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

class BasicStickingViewController: BaseRepeatBrickViewController, HasTitle {
    class var brickTitle: String {
        return "Sticky Header"
    }
    class var subTitle: String {
        return "Sticking headers"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        behavior = StickyLayoutBehavior(dataSource: self, delegate: self)
    }

}

extension BasicStickingViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(_ stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return identifier == BrickIdentifiers.titleLabel
    }
}

extension BasicStickingViewController: StickyLayoutBehaviorDelegate {
    func stickyLayoutBehavior(_ behavior: StickyLayoutBehavior, brickIsStickingWithPercentage percentage: CGFloat, forItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        let format = String(format: "%.3f", Double(percentage))
        titleLabelModel.text = "\(format)%"
        self.reloadBricksWithIdentifiers([BrickIdentifiers.titleLabel])
    }
}

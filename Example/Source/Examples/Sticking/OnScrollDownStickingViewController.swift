//
//  OnScrollDownStickingViewController.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/31/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

class OnScrollDownStickingViewController: BaseSectionBrickViewController, HasTitle {

    class var brickTitle: String {
        return "On Scroll Down"
    }
    class var subTitle: String {
        return "Reveal the sticky header on scroll down"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        behavior = OnScrollDownStickyLayoutBehavior(dataSource: self)
    }

}

extension OnScrollDownStickingViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(_ behavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return identifier == BrickIdentifiers.titleLabel
    }
}

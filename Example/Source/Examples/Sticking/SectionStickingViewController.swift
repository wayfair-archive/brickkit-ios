//
//  SectionStickingViewController.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/31/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//
import UIKit
import BrickKit

class SectionStickingViewController: BaseSectionBrickViewController, HasTitle {

    class var brickTitle: String {
        return "Sticking Section"
    }
    class var subTitle: String {
        return "Example of a Sticking Section"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        behavior = StickyLayoutBehavior(dataSource: self)
    }
}

extension SectionStickingViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(_ stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return identifier == BrickIdentifiers.titleLabel
    }
}

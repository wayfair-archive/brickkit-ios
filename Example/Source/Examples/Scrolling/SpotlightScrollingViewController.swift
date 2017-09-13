//
//  SpotlightScrollingViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/4/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

class SpotlightScrollingViewController: BaseScrollingViewController, HasTitle {
    class var brickTitle: String {
        return "Spotlight"
    }
    class var subTitle: String {
        return "Have a brick in the spotlight"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        behavior = SpotlightLayoutBehavior(dataSource: self)
    }
}

extension SpotlightScrollingViewController: SpotlightLayoutBehaviorDataSource {
    func spotlightLayoutBehavior(_ behavior: SpotlightLayoutBehavior, smallHeightForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGFloat? {
        return identifier == BrickIdentifiers.repeatLabel ? 50 : nil
    }
}

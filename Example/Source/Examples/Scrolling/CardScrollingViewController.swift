//
//  CardScrollingViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/5/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

class CardScrollingViewController: BaseScrollingViewController {
    override class var title: String {
        return "Cards"
    }
    override class var subTitle: String {
        return "Scroll bricks like cards"
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        layout.zIndexBehavior = .bottomUp
        behavior = CardLayoutBehavior(dataSource: self)
    }

}

extension CardScrollingViewController: CardLayoutBehaviorDataSource {
    func cardLayoutBehavior(_ behavior: CardLayoutBehavior, smallHeightForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGFloat? {
        return identifier == BrickIdentifiers.repeatLabel ? 50 : nil
    }
}

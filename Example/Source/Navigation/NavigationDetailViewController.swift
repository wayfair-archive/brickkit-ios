//
//  NavigationDetailViewController.swift
//  BrickKit iOS Example
//
//  Created by Ruben Cagnie on 10/17/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

/// View Controller that shows the viewcontrollers of a NavigationItem
class NavigationDetailViewController: BrickViewController {

    /// Reference to the item that is selected
    var navItem: NavigationItem!

    /// Flag that indicates if the items should be shown or not
    var showSubItems: Bool = false

    // Mark: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup title
        self.navigationItem.title = navItem.title.uppercaseString
        #if os(iOS)
            // On iOS (not tvOS), hide the back title
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        #endif

        // Setup background
        self.view.backgroundColor = .whiteColor()
        collectionView?.backgroundColor = .brickPattern

        // Setup appear behavior
        brickCollectionView.layout.appearBehavior = BrickAppearTopBehavior()

        // Register Bricks
        registerBrickClass(TwoLabelBrick.self)

        let labelBrick = TwoLabelBrick(NavigationIdentifiers.subItemBrick, width: .Ratio(ratio: 1), height: .Fixed(size: Constants.brickHeight), backgroundColor: .whiteColor(), dataSource: self)
        labelBrick.brickCellTapDelegate = self

        let section = BrickSection(NavigationIdentifiers.subItemSection, bricks: [
            labelBrick
            ], inset: 1, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))

        section.repeatCountDataSource = self

        setSection(section)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Call layout subviews to invoke the bricks for the first time, so that the repeat count is 0
        self.brickCollectionView.layoutSubviews()

        // Set the navigation bar to purple
        Theme.setupNavigationBarForSecondaryUse(self.navigationController!.navigationBar)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // Set the navigation bar to gray
        Theme.setupNavigationBarForPrimaryUse(self.navigationController!.navigationBar)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // If the transition didn't call to show the bricks, do it now
        if !showSubItems {
            self.setBricksHidden(false, completion: nil)
        }

    }

    // Show or hide the label bricks
    func setBricksHidden(hidden: Bool, completion: ((completed: Bool) -> Void)?) {
        showSubItems = !hidden

        // Set the content offset back to top
        self.brickCollectionView.contentOffset = CGPoint(x: brickCollectionView.contentInset.left, y: -brickCollectionView.contentInset.top)

        self.brickCollectionView.invalidateRepeatCounts(false) { (completed, insertedIndexPaths, deletedIndexPaths) in
            completion?(completed: completed)
        }
    }
}

// Mark: - BrickCellTapDelegate
extension NavigationDetailViewController: BrickCellTapDelegate {

    func didTapBrickCell(brickCell: BrickCell) {
        let index = brickCell.index
        let detail = navItem.viewControllers[index].init()
        detail.title = navItem.viewControllers[index].title.uppercaseString
        self.navigationController?.pushViewController(detail, animated: true)
    }

}

// MARK: - LabelBrickCellDataSource
extension NavigationDetailViewController: LabelBrickCellDataSource {

    func configureLabelBrickCell(cell: LabelBrickCell) {
        guard let twoLabel = cell as? TwoLabelBrickCell else {
            return
        }

        #if os(tvOS)
            twoLabel.label.font = UIFont.brickSemiBoldFont(25)
        #else
            twoLabel.label.font = UIFont.brickSemiBoldFont(15)
        #endif
        twoLabel.label.text = navItem.viewControllers[cell.index].title
        twoLabel.label.textColor = .brickPurple1

        twoLabel.subLabel.text = navItem.viewControllers[cell.index].subTitle
    }

}

// MARK: - BrickRepeatCountDataSource
extension NavigationDetailViewController: BrickRepeatCountDataSource {

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        switch identifier {
        case NavigationIdentifiers.subItemBrick:
            return showSubItems ? navItem.viewControllers.count : 0
        default: return 1
        }
    }

}

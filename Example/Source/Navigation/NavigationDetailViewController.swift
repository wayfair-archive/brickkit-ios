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
        self.navigationItem.title = navItem.title.uppercased()
        #if os(iOS)
            // On iOS (not tvOS), hide the back title
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        #endif

        // Setup background
        self.view.backgroundColor = UIColor.white
        collectionView?.backgroundColor = .brickPattern

        // Setup appear behavior
        brickCollectionView.layout.appearBehavior = BrickAppearTopBehavior()

        // Define brick
        let labelBrick = GenericBrick<TwoLabelView>(NavigationIdentifiers.subItemBrick, width: .ratio(ratio: 1), height: .fixed(size: Constants.brickHeight), backgroundColor: UIColor.white) { [weak self] twoLabel, cell in
            self?.configure(twoLabel: twoLabel, cell: cell)
        }
        labelBrick.brickCellTapDelegate = self

        let section = BrickSection(NavigationIdentifiers.subItemSection, bricks: [
            labelBrick
            ], inset: 1, edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))

        section.repeatCountDataSource = self

        setSection(section)
    }

    fileprivate func configure(twoLabel: TwoLabelView, cell: GenericBrickCell) {
        cell.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        #if os(tvOS)
            twoLabel.label.font = UIFont.brickSemiBoldFont(size: 25)
        #else
            twoLabel.label.font = UIFont.brickSemiBoldFont(size: 15)
        #endif
        if let titledControllerType = navItem.viewControllers[cell.index] as? HasTitle.Type {
            twoLabel.label.text = titledControllerType.brickTitle
            twoLabel.subLabel.text = titledControllerType.subTitle
        }

        twoLabel.label.textColor = .brickPurple1

        // Only set accessory once if needed
        if cell.accessoryView == nil {
            let image = UIImage(named: "chevron", in: LabelBrick.bundle, compatibleWith: nil)
            let imageView = UIImageView(image: image!)
            cell.accessoryView = imageView
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Call layout subviews to invoke the bricks for the first time, so that the repeat count is 0
        self.brickCollectionView.layoutSubviews()

        // Set the navigation bar to purple
        Theme.setupNavigationBarForSecondaryUse(navigationBar: self.navigationController!.navigationBar)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Set the navigation bar to gray
        Theme.setupNavigationBarForPrimaryUse(navigationBar: self.navigationController!.navigationBar)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // If the transition didn't call to show the bricks, do it now
        if !showSubItems {
            self.setBricksHidden(hidden: false, completion: nil)
        }

    }

    // Show or hide the label bricks
    func setBricksHidden(hidden: Bool, completion: ((_ completed: Bool) -> Void)?) {
        showSubItems = !hidden

        // Set the content offset back to top
        self.brickCollectionView.contentOffset = CGPoint(x: brickCollectionView.contentInset.left, y: -brickCollectionView.contentInset.top)

        self.brickCollectionView.invalidateRepeatCounts { (completed, insertedIndexPaths, deletedIndexPaths) in
            completion?(completed)
        }
    }
}

// Mark: - BrickCellTapDelegate
extension NavigationDetailViewController: BrickCellTapDelegate {

    func didTapBrickCell(_ brickCell: BrickCell) {
        let index = brickCell.index
        let detailType = navItem.viewControllers[index]
        let detail = detailType.init()
        detail.navigationItem.title = (detailType as? HasTitle.Type)?.brickTitle.uppercased()
        self.navigationController?.pushViewController(detail, animated: true)
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

//
//  NavigationViewController.swift
//  BrickKit iOS Example
//
//  Created by Ruben Cagnie on 10/17/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit

/// Main navigation controller that holds the dataSource and is responsible for animating from Master > Detail and back
class NavigationViewController: UINavigationController {

    /// DataSource that holds the navigation items that need to be shown
    lazy var dataSource = NavigationDataSource()

    // Transition
    lazy fileprivate var navigationTransition = NavigationTransition()

    // Mark: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}

// MARK: - UINavigationControllerDelegate
extension NavigationViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if fromVC is NavigationMasterViewController && toVC is NavigationDetailViewController {
            navigationTransition.presenting = true
            return navigationTransition
        } else if fromVC is NavigationDetailViewController && toVC is NavigationMasterViewController {
            navigationTransition.presenting = false
            return navigationTransition
        }

        return nil
    }

}

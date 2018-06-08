//
//  NavigationTransition.swift
//  BrickKit iOS Example
//
//  Created by Ruben Cagnie on 10/17/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit

/// Transition object to show/hide details in an animated way
class NavigationTransition: NSObject {

    /// Flag that indicates if we are presenting or dismissing
    var presenting: Bool = true

    /// The current content offset when going from Master > Detail
    /// Used for going back from Detail > Master
    fileprivate var masterContentOffset: CGPoint!

}

// MARK: - UIViewControllerAnimatedTransitioning
extension NavigationTransition: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animationDuration = transitionDuration(using: transitionContext)

        if presenting {
            // Verify if we have the correct viewcontrollers
            guard
                let masterVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? NavigationMasterViewController,
                let detailVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? NavigationDetailViewController else {

                    transitionContext.completeTransition(false)
                    return
            }

            self.presentDetail(masterVC: masterVC, detailVC: detailVC, containerView: transitionContext.containerView, animationDuration: animationDuration) { completed in
                transitionContext.completeTransition(true)
            }
        } else {
            // Verify if we have the correct viewcontrollers
            guard
                let masterVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? NavigationMasterViewController,
                let detailVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? NavigationDetailViewController else {

                    transitionContext.completeTransition(false)
                    return
            }

            self.popDetail(masterVC: masterVC, detailVC: detailVC, containerView: transitionContext.containerView, animationDuration: animationDuration) { completed in
                transitionContext.completeTransition(true)
            }
        }
    }

    /// Present the details of a navigation item
    func presentDetail(masterVC: NavigationMasterViewController, detailVC: NavigationDetailViewController, containerView: UIView?, animationDuration: TimeInterval, completion: @escaping (_ completed: Bool) -> Void) {


        masterContentOffset = masterVC.brickCollectionView.contentOffset

        // Content offset when scrolled all the way to the top
        let topContentOffset = CGPoint(
            x: masterVC.brickCollectionView.contentInset.left,
            y: -masterVC.brickCollectionView.contentInset.top
        )

        UIView.animate(withDuration: animationDuration / 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {

            // Scroll to top
            masterVC.brickCollectionView.contentOffset = topContentOffset

            // Animate the detail brick to go to the top and the other hide
            masterVC.indexOfSelectedBrick = masterVC.dataSource.selectedIndex
            masterVC.brickCollectionView.invalidateBricks(false) { completed in
                if let containerView = containerView {
                    // Add/remove viewcontroller views
                    masterVC.view.removeFromSuperview()
                    containerView.addSubview(detailVC.view)
                }

                // Show the brick from the top
                UIView.animate(withDuration: animationDuration / 2, animations: {
                    detailVC.setBricksHidden(hidden: false, completion: nil)
                    }, completion: completion)
            }

            }, completion: nil)

    }

    /// Pop back to the master viewcontroller
    func popDetail(masterVC: NavigationMasterViewController, detailVC: NavigationDetailViewController, containerView: UIView?, animationDuration: TimeInterval, completion: @escaping (_ completed: Bool) -> Void) {

        UIView.animate(withDuration: animationDuration / 2, animations: {

            // Hide the bricks from the top
            detailVC.setBricksHidden(hidden: true){ completed in

                if let containerView = containerView {
                    // Add/remove viewcontroller views
                    detailVC.view.removeFromSuperview()
                    containerView.addSubview(masterVC.view)
                }

                UIView.animate(withDuration: animationDuration / 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {

                    // Set back the content offset from before showing the detail
                    masterVC.brickCollectionView.contentOffset = self.masterContentOffset

                    // Invalidate the selected brick
                    masterVC.indexOfSelectedBrick = nil

                    // Invalidate bricks, so they animate back
                    masterVC.brickCollectionView.invalidateBricks(false, completion: completion)
                    
                    }, completion: nil)
            }
            
        })
    }
    
}


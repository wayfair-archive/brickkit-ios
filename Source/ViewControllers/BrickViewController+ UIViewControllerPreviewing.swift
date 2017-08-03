//
//  BrickViewController+ UIViewControllerPreviewing.swift
//  BrickKit
//
//  Created by Aaron Sky on 8/2/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import UIKit

#if os(iOS)
extension BrickViewController: UIViewControllerPreviewingDelegate {
    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = brickCollectionView.indexPathForItem(at: location) else {
            return nil
        }
        let brick = brickCollectionView.brick(at: indexPath)
        let viewController = brick.previewingDelegate?.previewViewController
        return viewController
    }
    
    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // TODO: Handling pop should be on the brick's previewing delegate, and the implementation of pop should be more implementation-blind
        show(viewControllerToCommit, sender: self)
    }
}
#endif

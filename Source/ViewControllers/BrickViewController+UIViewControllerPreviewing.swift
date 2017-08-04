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
        if let previewing = viewController as? BrickViewControllerPreviewing {
            previewing.sourceBrick = brick
        }
        return viewController
    }
    
    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let previewViewController = viewControllerToCommit as? BrickViewControllerPreviewing else {
            return
        }
        let sourceBrick = previewViewController.sourceBrick
        let previewingDelegate = sourceBrick?.previewingDelegate
        previewingDelegate?.commit(viewController: viewControllerToCommit)
    }
}
#endif

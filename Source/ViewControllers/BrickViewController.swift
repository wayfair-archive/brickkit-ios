//
//  BrickViewController.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit

/**
 Conform to this delegate on your preview view controller in order to enable UIKit Pop.
 */
public protocol BrickViewControllerPreviewing: class {
    var sourceBrick: Brick { get set }
}

/// A BrickViewController is a UIViewController that contains a BrickCollectionView
open class BrickViewController: UIViewController, UICollectionViewDelegate {

    // MARK: - Public members

    open var layout: BrickFlowLayout {
        guard let flowlayout = collectionViewLayout as? BrickFlowLayout else {
            fatalError("collectionViewLayout is not BrickFlowLayout, is \(type(of: collectionViewLayout))")
        }
        return flowlayout
    }

    open var collectionViewLayout: UICollectionViewLayout {
        return brickCollectionView.collectionViewLayout
    }

    open var collectionView: UICollectionView?

    open var brickCollectionView: BrickCollectionView {
        guard let collectionView = self.collectionView as? BrickCollectionView else {
            fatalError("collectionView is not BrickCollectionView, is \(type(of: self.collectionView))")
        }
        return collectionView
    }
    
    /// Previewing context, retained for unregistration in the event of a capability change
    open internal(set) var previewingContext: UIViewControllerPreviewing?
    
    #if os(iOS)
    // MARK: - Internal members

    /// Refresh control, if added
    open internal(set) var refreshControl: UIRefreshControl?

    /// Refresh action, if added
    open internal(set) var refreshAction: ((_ refreshControl: UIRefreshControl) -> Void)?
    #endif

    // MARK: - Initializers

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - UIViewController overrides

    open override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
        
        if let registrationDataSource = self as? BrickRegistrationDataSource {
            registrationDataSource.registerBricks()
        }
    }
    
    /// Registration/unregistration happens here because the user can disable force touch in their system settings
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        handleTraitCollectionChange(traitCollection, previousTraitCollection)
    }

    // MARK: - Private Methods

    fileprivate func initializeComponents() {
        autoreleasepool { // This would result in not releasing the BrickCollectionView even when its being set to nil
            let collectionView = BrickCollectionView(frame: self.view.bounds, collectionViewLayout: BrickFlowLayout())
            collectionView.backgroundColor = UIColor.clear
            collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            self.view.addSubview(collectionView)

            self.collectionView = collectionView
            self.collectionView?.delegate = self
        }
    }
    
    /// On tvOS, this method accomplishes nothing, despite UIViewControllerPreviewing and its delegate protocol being available
    func handleTraitCollectionChange(_ traitCollection: UITraitCollection, _ previousTraitCollection: UITraitCollection?) {
        if previewingContext == nil && traitCollection.forceTouchCapability == .available {
            // We use brickCollectionView as the sourceView for the previewingContext, otherwise the coordinates returned
            // in UIViewControllerPreviewing#previewingContext(_:, viewControllerForLocation:) are not in the right system
            previewingContext = registerForPreviewing(with: self, sourceView: brickCollectionView)
        } else if let previewingContext = previewingContext,
            previousTraitCollection?.forceTouchCapability == .available {
            unregisterForPreviewing(withContext: previewingContext)
            self.previewingContext = nil
        }
    }

// MARK: - Convenience methods
    open func setSection(_ section: BrickSection) {
        brickCollectionView.setSection(section)
    }

    open func registerBrickClass(_ brickClass: Brick.Type, nib: UINib? = nil) {
        brickCollectionView.registerBrickClass(brickClass, nib: nib)
    }

    open func registerNib(_ nib: UINib, forBrickWithIdentifier identifier: String) {
        brickCollectionView.registerNib(nib, forBrickWithIdentifier: identifier)
    }

    open func reloadBricksWithIdentifiers(_ identifiers: [String], shouldReloadCell: Bool = false, completion: ((Bool) -> Void)? = nil) {
        brickCollectionView.reloadBricksWithIdentifiers(identifiers, shouldReloadCell: shouldReloadCell, completion: completion)
    }

    open func invalidateLayout() {
        brickCollectionView.invalidateBricks()
    }
}

// MARK: - UIViewControllerPreviewingDelegate
extension BrickViewController: UIViewControllerPreviewingDelegate {
    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = brickCollectionView.indexPathForItem(at: location) else {
            return nil
        }
        let brick = brickCollectionView.brick(at: indexPath)
        return brick.previewingDelegate?.previewViewController(for: brick)
    }
    
    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let previewViewController = viewControllerToCommit as? BrickViewControllerPreviewing else {
            return
        }
        previewViewController.sourceBrick.previewingDelegate?.commit(viewController: viewControllerToCommit)
    }
}

#if os(iOS)
// MARK: - UIRefreshControl
extension BrickViewController {

    /// Add a refresh control to the BrickViewController
    ///
    /// - parameter refreshControl: refreshControl
    /// - parameter action:         action
    public func addRefreshControl(_ refreshControl: UIRefreshControl, action:@escaping ((_ refreshControl: UIRefreshControl) -> Void)) {
        self.refreshControl = refreshControl
        self.refreshAction = action
        self.refreshControl!.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
        self.brickCollectionView.addSubview(self.refreshControl!)
    }
    
    /// This method needs to be called then ever you are do refreshing so it can be brought back to the the top
    public func resetRefreshControl() {
        if refreshControl?.isRefreshing == true {
            refreshControl?.layer.zPosition = (brickCollectionView.backgroundView?.layer.zPosition ?? 0) + 1
        }
    }
    
    @objc internal func refreshControlAction() {
        refreshControl?.layer.zPosition = (brickCollectionView.backgroundView?.layer.zPosition ?? 0) - 1
        if let refreshControl = self.refreshControl {
            self.refreshAction?(refreshControl)
        }
    }
}
#endif

#if os(tvOS)
extension BrickViewController {

    open func collectionViewShouldUpdateFocusIn(context: UICollectionViewFocusUpdateContext) -> Bool {
        
        guard let nextIndex = context.nextFocusedIndexPath else {
            return false
        }
        
        if let lastIndex = context.previouslyFocusedIndexPath, let cell = brickCollectionView.cellForItem(at: lastIndex) as? FocusableBrickCell {
            if !cell.willUnfocus() {
                return false
            }
        }
        
        if let cell = brickCollectionView.cellForItem(at: nextIndex) as? FocusableBrickCell {
            return cell.willFocus()
        }
        
        return false
    }
    
    public func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: IndexPath) -> Bool {
        let cell = brickCollectionView.cellForItem(at: indexPath) as? BrickCell
        return cell is FocusableBrickCell && cell?.allowsFocus == true
    }
}

#endif

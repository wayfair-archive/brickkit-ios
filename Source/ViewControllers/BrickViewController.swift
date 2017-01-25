//
//  BrickViewController.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit

/// A BrickViewController is a UIViewController that contains a BrickCollectionView
public class BrickViewController: UIViewController, UICollectionViewDelegate {

    // MARK: - Public members

    public var layout: BrickFlowLayout {
        return collectionViewLayout as! BrickFlowLayout
    }

    public var collectionViewLayout: UICollectionViewLayout {
        return brickCollectionView.collectionViewLayout
    }

    public var collectionView: UICollectionView?

    public var brickCollectionView: BrickCollectionView {
        return self.collectionView as! BrickCollectionView
    }

    #if os(iOS)
    // MARK: - Internal members

    /// Refresh control, if added
    public internal(set) var refreshControl: UIRefreshControl?

    /// Refresh action, if added
    public internal(set) var refreshAction: ((refreshControl: UIRefreshControl) -> Void)?

    #endif

    // MARK: - Initializers

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public override init(nibName: String?, bundle: NSBundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - UIViewController overrides

    public override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
        
        if let registrationDataSource = self as? BrickRegistrationDataSource {
            registrationDataSource.registerBricks()
        }
    }

    // MARK: - Private Methods

    private func initializeComponents() {
        autoreleasepool { // This would result in not releasing the BrickCollectionView even when its being set to nil
            let collectionView = BrickCollectionView(frame: self.view.bounds, collectionViewLayout: BrickFlowLayout())
            collectionView.backgroundColor = .clearColor()
            collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

            self.view.addSubview(collectionView)

            self.collectionView = collectionView
            self.collectionView?.delegate = self
        }
    }

// MARK: - Convenience methods
    public func setSection(section: BrickSection) {
        brickCollectionView.setSection(section)
    }

    public func registerBrickClass(brickClass: Brick.Type, nib: UINib? = nil) {
        brickCollectionView.registerBrickClass(brickClass, nib: nib)
    }

    public func registerNib(nib: UINib, forBrickWithIdentifier identifier: String) {
        brickCollectionView.registerNib(nib, forBrickWithIdentifier: identifier)
    }

    public func reloadBricksWithIdentifiers(identifiers: [String], shouldReloadCell: Bool = false, completion: ((Bool) -> Void)? = nil) {
        brickCollectionView.reloadBricksWithIdentifiers(identifiers, shouldReloadCell: shouldReloadCell, completion: completion)
    }

    public func invalidateLayout() {
        brickCollectionView.invalidateBricks()
    }

}

#if os(iOS)
// MARK: - UIRefreshControl
extension BrickViewController {

    /// Add a refresh control to the BrickViewController
    ///
    /// - parameter refreshControl: refreshControl
    /// - parameter action:         action
    public func addRefreshControl(refreshControl: UIRefreshControl, action:((refreshControl: UIRefreshControl) -> Void)) {
        self.refreshControl = refreshControl
        self.refreshAction = action
        self.refreshControl!.addTarget(self, action: #selector(refreshControlAction), forControlEvents: .ValueChanged)
        self.brickCollectionView.addSubview(self.refreshControl!)
    }
    
    /// This method needs to be called then ever you are do refreshing so it can be brought back to the the top
    public func resetRefreshControl() {
        if refreshControl?.refreshing == true {
            refreshControl?.layer.zPosition = (brickCollectionView.backgroundView?.layer.zPosition ?? 0) + 1
        }
    }
    
    @objc internal func refreshControlAction() {
        refreshControl?.layer.zPosition = (brickCollectionView.backgroundView?.layer.zPosition ?? 0) - 1
        if let refreshControl = self.refreshControl {
            self.refreshAction?(refreshControl: refreshControl)
        }
    }
}
#endif

#if os(tvOS)
extension BrickViewController {
    
    public func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
        
        guard let nextIndex = context.nextFocusedIndexPath else {
            return false
        }
        
        if let lastIndex = context.previouslyFocusedIndexPath, let cell = brickCollectionView.cellForItemAtIndexPath(lastIndex) as? FocusableBrickCell {
            if !cell.willUnfocus() {
                return false
            }
        }
        
        if let cell = brickCollectionView.cellForItemAtIndexPath(nextIndex) as? FocusableBrickCell {
            return cell.willFocus()
        }
        
        return false
    }
    
    public func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = brickCollectionView.cellForItemAtIndexPath(indexPath) as? BrickCell
        return cell is FocusableBrickCell && cell?.allowsFocus == true
    }
}

#endif

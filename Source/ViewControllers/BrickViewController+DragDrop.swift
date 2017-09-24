//
//  File.swift
//  BrickKit
//
//  Created by Aaron Sky on 9/24/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
extension BrickViewController: UICollectionViewDragDelegate {
    @available(iOS 11.0, *)
    public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let collectionView = collectionView as? BrickCollectionView,
            indexPath.section != 0,
            let brickDragDelegate = collectionView.brick(at: indexPath).dragDropDelegate else {
            return []
        }
        return brickDragDelegate.dragItems(for: session, at: indexPath)
    }

    @available(iOS 11.0, *)
    public func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        guard let collectionView = collectionView as? BrickCollectionView,
            indexPath.section != 0,
            let brickDragDelegate = collectionView.brick(at: indexPath).dragDropDelegate else {
            return []
        }
        return brickDragDelegate.dragItems(for: session, at: indexPath)
    }
    
    @available(iOS 11.0, *)
    public func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let collectionView = collectionView as? BrickCollectionView,
            indexPath.section != 0,
            let brickDragDelegate = collectionView.brick(at: indexPath).dragDropDelegate,
            let view = collectionView.cellForItem(at: indexPath) else {
            return nil
        }
        return brickDragDelegate.previewParameters(for: view, at: indexPath)
    }
    
    @available(iOS 11.0, *)
    public func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        // no-op
    }
    
    @available(iOS 11.0, *)
    public func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        // no-op
    }
}

@available(iOS 11.0, *)
extension BrickViewController: UICollectionViewDropDelegate {
    @available(iOS 11.0, *)
    public func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        guard let collectionView = collectionView as? BrickCollectionView else {
            return false
        }
        return collectionView.section.canBricksHandle(session)
    }
    
    @available(iOS 11.0, *)
    public func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if destinationIndexPath?.section == 0 {
            return UICollectionViewDropProposal(operation: .cancel)
        } else if session.localDragSession != nil {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
    }
    
    @available(iOS 11.0, *)
    public func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath, indexPath.section != 0 {
            destinationIndexPath = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section) - 1
            destinationIndexPath = IndexPath(row: row, section: section)
            if destinationIndexPath.section <= 0 {
                return
            }
        }
        
        if coordinator.proposal.operation == .copy {
            self.loadAndInsertItems(at: destinationIndexPath, with: coordinator)
        } else if coordinator.proposal.operation == .move {
            let items = coordinator.items
            if items.contains(where: { $0.sourceIndexPath != nil }) && items.count == 1,
                let item = items.first {
                // Reordering a single item from this collection view.
                self.reorder(item, to: destinationIndexPath, with: coordinator)
            } else {
                // Moving items from somewhere else in this app.
                self.moveItems(to: destinationIndexPath, with: coordinator)
            }
        }
    }

    @available(iOS 11.0, *)
    public func collectionView(_ collectionView: UICollectionView, dropPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let collectionView = collectionView as? BrickCollectionView,
            let brickDragDelegate = collectionView.brick(at: indexPath).dragDropDelegate,
            let view = collectionView.cellForItem(at: indexPath) else {
                return nil
        }
        return brickDragDelegate.previewParameters(for: view, at: indexPath)
    }
    
    @available(iOS 11.0, *)
    private func loadAndInsertItems(at destinationIndexPath: IndexPath, with coordinator: UICollectionViewDropCoordinator) {
        guard let brick = Optional.some(self.brickCollectionView.brick(at: destinationIndexPath)),
            let delegate = brick.dragDropDelegate else {
                return
        }
        coordinator.items.forEach { dropItem in
            let dragItem = dropItem.dragItem
            let itemProvider = dragItem.itemProvider
            guard itemProvider.canLoadObject(ofClass: delegate.itemProviderType) else {
                return
            }

            var placeholderContext: UICollectionViewDropPlaceholderContext? = nil
            // Do I need [weak self] here?
            let progress = itemProvider.loadObject(ofClass: delegate.itemProviderType) { optionalObject, error in
                DispatchQueue.main.async {
                    guard let item = optionalObject,
                        delegate.willDrop(item) else {
                        placeholderContext?.deletePlaceholder()
                        return
                    }
                    placeholderContext?.commitInsertion { insertionIndexPath in
                        delegate.drop(item, to: insertionIndexPath.item, from: nil)
                    }
                }
            }
            let placeholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: brick.identifier)
            placeholder.cellUpdateHandler = { cell in
                guard let placeholderCell = cell as? BrickPlaceholderCell else {
                    return
                }
                placeholderCell.configure(with: progress)
            }
            placeholderContext = coordinator.drop(dragItem, to: placeholder)
        }
        coordinator.session.progressIndicatorStyle = .none
    }

    @available(iOS 11.0, *)
    private func reorder(_ item: UICollectionViewDropItem, to destinationIndexPath: IndexPath, with coordinator: UICollectionViewDropCoordinator) {
        guard let collectionView = collectionView as? BrickCollectionView,
            let delegate = collectionView.brick(at: destinationIndexPath).dragDropDelegate,
            let sourceIndexPath = item.sourceIndexPath else {
                return
        }
        collectionView.performBatchUpdates({
            delegate.drop(item.dragItem.localObject, to: destinationIndexPath.item, from: sourceIndexPath.item)
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
        })
        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
    }

    @available(iOS 11.0, *)
    private func moveItems(to destinationIndexPath: IndexPath, with coordinator: UICollectionViewDropCoordinator) {
        guard let collectionView = collectionView as? BrickCollectionView,
            let delegate = collectionView.brick(at: destinationIndexPath).dragDropDelegate else {
            return
        }
        var skipped = 0
        for (offset, dropItem) in coordinator.items.enumerated() {
            guard let item = dropItem.dragItem.localObject, delegate.willDrop(item) else {
                skipped += 1
                continue
            }
            let insertionIndexPath = IndexPath(item: destinationIndexPath.item + offset - skipped, section: destinationIndexPath.section)
            collectionView.performBatchUpdates({
                delegate.drop(item, to: insertionIndexPath.item, from: nil)
                collectionView.insertItems(at: [insertionIndexPath])
            })
            coordinator.drop(dropItem.dragItem, toItemAt: insertionIndexPath)
        }
    }
}

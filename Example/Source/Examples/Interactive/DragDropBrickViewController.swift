//
//  DragDropBrickViewController.swift
//  BrickApp-iOS
//
//  Created by Aaron Sky on 9/24/17.
//  Copyright © 2017 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit
import MobileCoreServices

extension DragDropBrickViewController: HasTitle {
    class var brickTitle: String {
        return "Drag and Drop"
    }
    
    class var subTitle: String {
        return "Demonstrates UIKit Drag and Drop with bricks"
    }
}

class DragDropBrickViewController: BrickViewController {
    var data = ["dog", "horse", "john", "daniel", "wafer"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .brickBackground
        self.layout.zIndexBehavior = .bottomUp
        self.setSection(buildLayout())
    }
    
    func buildLayout() -> BrickSection {
        let brick = GenericBrick<UILabel>(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 0.5), height: .fixed(size: 50), backgroundColor: .brickGray1)
        { label, cell in
            label.font = .brickLightFont(size: 16)
            label.configure(textColor: UIColor.brickGray1.complemetaryColor)
            label.textAlignment = .center
            cell.edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            if #available(iOS 11.0, *) {
                label.text = self.data[cell.index]
            } else {
                label.text = "iOS 11 is required for this demo"
            }
        }
        if #available(iOS 11.0, *) {
            brick.repeatCount = self.data.count
            brick.dragDropDelegate = self
        } else {
            brick.repeatCount = 1
        }
        let section = BrickSection(bricks: [brick],
                                   inset: Constants.brickInset,
                                   edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                                   alignment: BrickAlignment(horizontal: .center, vertical: .top))
        return section
    }
}

@available(iOS 11.0, *)
extension DragDropBrickViewController: BrickDragDropDelegate {
    var itemProviderType: NSItemProviderReading.Type {
        return NSString.self
    }
    
    func dragItems(for session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dataElement = self.data[indexPath.row]
        let dataBinary = dataElement.data(using: .utf8)
        let itemProvider = NSItemProvider()
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            completion(dataBinary, nil)
            return nil
        }
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = dataElement
        return [dragItem]
    }

    func previewParameters(for view: UICollectionViewCell, at indexPath: IndexPath) -> UIDragPreviewParameters? {
        return nil
    }

    func canHandle(_ session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: NSString.readableTypeIdentifiersForItemProvider)
    }
    
    func willDrop(_ item: Any?) -> Bool {
        guard let item = item as? String, !self.data.contains(item) else {
            return false
        }
        return true
    }

    func drop(_ item: Any?, to destinationIndex: Int, from sourceIndex: Int?) {
        guard let item = item as? String else {
            return
        }
        if let sourceIndex = sourceIndex {
            self.data.remove(at: sourceIndex)
        }
        self.data.insert(item, at: destinationIndex)
    }
}


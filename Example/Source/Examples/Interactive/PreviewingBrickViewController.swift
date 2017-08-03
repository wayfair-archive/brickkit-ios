//
//  BasicInteractiveViewController.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/26/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

extension PreviewingBrickViewController: HasTitle {
    class var brickTitle: String {
        return "Previewing (3D Touch)"
    }
    
    class var subTitle: String {
        return "Demonstrates UIKit Peek and Pop with bricks"
    }
}

class PreviewingBrickViewController: BrickViewController {
    
    let brickCount = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground
        self.brickCollectionView.registerBrickClass(LabelBrick.self)

        self.layout.zIndexBehavior = .bottomUp
        
        let section = buildLayout()
        self.setSection(section)
    }
    
    func buildLayout() -> BrickSection {
        let brick = LabelBrick(BrickIdentifiers.repeatLabel,
                              width: .ratio(ratio: 0.5),
                              backgroundColor: .brickGray1,
                              dataSource: self)
        brick.previewingDelegate = self
        let section = BrickSection(bricks: [brick], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        section.repeatCountDataSource = self
        return section
    }
    
    /**
     This view controller is presented during a peek/pop, known in UIKit as a "preview". In order to support UIKit Pop, the
     preview view controller must conform to the BrickViewControllerPreviewing delegate.
     */
    fileprivate class PreviewedViewController: BrickViewController, BrickViewControllerPreviewing {
        
        weak var sourceBrick: Brick?
        
        /// Here is an example of setting the preview actions available while previewing this view controller.
        override var previewActionItems: [UIPreviewActionItem] {
            let action1 = UIPreviewAction(title: "Default Action", style: .default) { _,_ in
                print("This is the default action!")
            }
            let action2 = UIPreviewAction(title: "Scary Action", style: .destructive) { _,_ in
                print("This is the scary action!")
            }
            let actions = [action1, action2]
            return actions
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.view.backgroundColor = .brickGray4
            self.brickCollectionView.registerBrickClass(LabelBrick.self)
            self.layout.zIndexBehavior = .bottomUp
            
            let labelText: String
            if let brick = sourceBrick {
                labelText = "Peek-a-boo from \(brick.identifier)!"
            } else {
                labelText = "Peek-a-boo!"
            }
            
            let section = BrickSection(bricks: [
                LabelBrick(backgroundColor: .brickGray1,
                           text: labelText,
                           configureCellBlock: LabelBrickCell.configure)
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
            self.setSection(section)
        }
    }
}

extension PreviewingBrickViewController: BrickPreviewingDelegate {
    weak var previewViewController: UIViewController? {
        return PreviewedViewController()
    }
    
    func commit(viewController: UIViewController) {
        show(viewController, sender: self)
    }
}

extension PreviewingBrickViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        cell.label.text = "Brick \(cell.index)"
        cell.configure()
    }
}

extension PreviewingBrickViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        guard identifier == BrickIdentifiers.repeatLabel else {
            return 1
        }
        return brickCount
    }
}

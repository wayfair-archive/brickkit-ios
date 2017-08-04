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
        
        self.layout.zIndexBehavior = .bottomUp
        
        self.setSection(buildLayout())
    }
    
    func buildLayout() -> BrickSection {
        let brick = GenericBrick<UILabel>(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 0.5), height: .fixed(size: 50), backgroundColor: .brickGray1)
        { label, cell in
            label.text = "BRICK \(cell.index)"
            label.font = .brickLightFont(size: 16)
            label.configure(textColor: UIColor.brickGray1.complemetaryColor)
            label.textAlignment = .center
            cell.edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        brick.previewingDelegate = self
        brick.repeatCount = brickCount
        return BrickSection(bricks: [brick], inset: Constants.brickInset, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), alignment: BrickAlignment(horizontal: .center, vertical: .top))
    }
    
    /**
     This view controller is presented during a peek/pop, known in UIKit as a "preview". In order to support UIKit Pop, the
     preview view controller must conform to the BrickViewControllerPreviewing delegate.
     */
    fileprivate class PreviewedViewController: BrickViewController, BrickViewControllerPreviewing {
        
        var sourceBrick: Brick
        
        /// Here is an example of setting the preview actions available while previewing this view controller.
        override var previewActionItems: [UIPreviewActionItem] {
            let action1 = UIPreviewAction(title: "Default Action", style: .default) { _, _ in
                print("This is the default action!")
            }
            let action2 = UIPreviewAction(title: "Scary Action", style: .destructive) { _, _ in
                print("This is the scary action!")
            }
            return [action1, action2]
        }
        
        required init(with source: Brick) {
            sourceBrick = source
            super.init()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.view.backgroundColor = .brickGray4
            self.layout.zIndexBehavior = .bottomUp
            
            self.setSection(buildLayout())
        }
        
        func buildLayout() -> BrickSection {
            let brick = GenericBrick<UILabel>(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 1), height: .fixed(size: 50), backgroundColor: .brickGray1) { label, cell in
                label.text = "Peek-a-boo!"
                label.font = .brickLightFont(size: 16)
                label.configure(textColor: UIColor.brickGray1.complemetaryColor)
                label.textAlignment = .center
                cell.edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            }
            
            return BrickSection(bricks: [brick], inset: Constants.brickInset, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), alignment: BrickAlignment(horizontal: .center, vertical: .top))
        }
    }
}

extension PreviewingBrickViewController: BrickPreviewingDelegate {
    func previewViewController(for brick: Brick) -> UIViewController? {
        return PreviewedViewController(with: brick)
    }
    
    func commit(viewController: UIViewController) {
        show(viewController, sender: self)
    }
}

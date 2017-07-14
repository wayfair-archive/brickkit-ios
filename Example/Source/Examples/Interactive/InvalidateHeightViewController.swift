//
//  InvalidateHeightViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/13/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class InvalidateHeightViewController: BrickViewController, HasTitle {

    class var brickTitle: String {
        return "Invalidate Height"
    }

    class var subTitle: String {
        return "Change height dynamically"
    }
    
    var brick: LabelBrick!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.brickCollectionView.layout.cacheThings = true
        self.registerBrickClass(LabelBrick.self)

        brick = LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "BRICK") { cell in
            cell.configure()
            })

        let section = BrickSection(backgroundColor: .orange, bricks: [
            brick,
//            LabelBrick(BrickIdentifiers.repeatLabel, backgroundColor: .brickGray2, dataSource: LabelBrickCellModel(text: "BRICK", configureCellBlock: LabelBrickCell.configure)),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

        self.setSection(section)

        self.updateNavigationItem()

    }

    func updateNavigationItem() {
        let title: String
        switch brick.height {
        case .fixed(_): title = "Auto"
        default: title = "Fixed Height"
        }

        let selector: Selector = #selector(InvalidateHeightViewController.toggleHeights)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: selector)
    }

    @objc func toggleHeights() {
        switch brick.height {
        case .fixed(_):
            brickCollectionView.section.bricks[0].height = .auto(estimate: .fixed(size: 100))
//            brickCollectionView.section.bricks[1].height = .auto(estimate: .fixed(size: 100))
        default:
            brickCollectionView.section.bricks[0].height = .fixed(size: 200)
//            brickCollectionView.section.bricks[1].height = .fixed(size: 200)
        }

        let indexPath = brickCollectionView.indexPathsForBricksWithIdentifier(BrickIdentifiers.titleLabel).first!
        if let brickCell = brickCollectionView.cellForItem(at: indexPath) as? BrickCell {
            UIView.animate(withDuration: 2) {
                self.brickCollectionView.performResize(cell: brickCell, completion: nil)
            }

        }




//        self.brickCollectionView.invalidateBricks(false)
//        self.updateNavigationItem()
    }

}

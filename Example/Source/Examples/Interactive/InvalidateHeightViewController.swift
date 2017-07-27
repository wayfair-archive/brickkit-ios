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

        brick = LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "BRICK") { cell in
            cell.configure()
            })

        let section = BrickSection(bricks: [
            brick,
            LabelBrick(BrickIdentifiers.repeatLabel, backgroundColor: .brickGray2, dataSource: LabelBrickCellModel(text: "BRICK", configureCellBlock: LabelBrickCell.configure)),
            brick,
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
        let newHeight: BrickDimension
        switch brick.height {
        case .fixed(_):
            newHeight = .auto(estimate: .fixed(size: 100))
        default:
            newHeight = .fixed(size: 200)
        }
        
        let size = BrickSize(width: .ratio(ratio: 1), height: newHeight)
        brick.size = size
        
        UIView.animate(withDuration: 2) {
            self.brickCollectionView.invalidateBricks(false)
        }
        
        self.updateNavigationItem()
    }

}

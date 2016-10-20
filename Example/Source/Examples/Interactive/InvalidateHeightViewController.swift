//
//  InvalidateHeightViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/13/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class InvalidateHeightViewController: BrickViewController {

    override class var title: String {
        return "Invalidate Height"
    }

    override class var subTitle: String {
        return "Change height dynamically"
    }
    
    var brick: LabelBrick!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.registerBrickClass(LabelBrick.self)

        brick = LabelBrick(BrickIdentifiers.repeatLabel, backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "BRICK") { cell in
            cell.configure()
            })

        let section = BrickSection(bricks: [
            brick
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

        self.setSection(section)

        self.updateNavigationItem()

    }

    func updateNavigationItem() {
        let title: String
        switch brick.height {
        case .Fixed(_): title = "Auto"
        default: title = "Fixed Height"
        }

        let selector: Selector = #selector(InvalidateHeightViewController.toggleHeights)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: selector)
    }

    func toggleHeights() {
        switch brick.height {
        case .Fixed(_): brick.height = .Auto(estimate: .Fixed(size: 100))
        default: brick.height = .Fixed(size: 200)
        }

        self.brickCollectionView.invalidateBricks()
        self.updateNavigationItem()
    }

}

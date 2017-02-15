//
//  SizeClassesBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class SizeClassesBrickViewController: BrickViewController {

    override class var title: String {
        return "Size Classes"
    }

    override class var subTitle: String {
        return "Example for size classes"
    }

    var sizeClassFull: SizeClassBrick!
    var sizeClassHalf: SizeClassBrick!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.registerBrickClass(SizeClassBrick.self)
        self.registerBrickClass(TestBrick.self)

        sizeClassFull = SizeClassBrick("Full", width: .ratio(ratio: 1), backgroundColor: .brickSection)
        sizeClassFull.color = .brickGray3
        sizeClassFull.text = "Should be 100px Height"

        sizeClassHalf = SizeClassBrick("Half", width: .ratio(ratio: 0.5), backgroundColor: .brickSection)
        sizeClassHalf.color = .brickGray5

        let section = BrickSection("Size Classes", bricks: [
            sizeClassFull,
            sizeClassHalf
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

        self.setSection(section)

        updateLabels()

    }

    func updateLabels() {
        let isCompact = self.traitCollection.horizontalSizeClass == .compact
        if isCompact {
            sizeClassFull.text = "COMPACT - SHOULD BE 100px"
            sizeClassHalf.text = "COMPACT - SHOULD BE 100px"
        } else {
            sizeClassFull.text = "REGULAR - SHOULD BE 150px"
            sizeClassHalf.text = "REGULAR - SHOULD BE 150px"
        }
    }

}

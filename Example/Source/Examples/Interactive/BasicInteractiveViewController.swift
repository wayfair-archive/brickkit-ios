//
//  BasicInteractiveViewController.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/26/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

private let RepeatSection = "RepeatSection"
private let Stepper = "Stepper"
private let Section = "Section"

class BasicInteractiveViewController: BrickViewController, LabelBrickCellDataSource, BrickRepeatCountDataSource, HasTitle {

    class var brickTitle: String {
        return "Basic Interaction"
    }

    class var subTitle: String {
        return "Shows how to add and remove bricks in an interactive way"
    }

    var stepperModel = StepperBrickModel(count: 1)
    
    var titleModel = LabelBrickCellModel(text: "There are no values".uppercased()) { cell in
        cell.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground


        self.brickCollectionView.registerBrickClass(LabelBrick.self)
        self.brickCollectionView.registerBrickClass(StepperBrick.self)
        self.brickCollectionView.registerBrickClass(SegmentHeaderBrick.self)

        self.layout.zIndexBehavior = .bottomUp

        let stickyBehavior = StickyFooterLayoutBehavior(dataSource: self)
        self.layout.behaviors.insert(stickyBehavior)
        
        let section = BrickSection(Section, bricks: [
            StepperBrick(Stepper, height: .auto(estimate: .fixed(size: 50)), backgroundColor: .brickGray1, dataSource: stepperModel, delegate: self),
            BrickSection(RepeatSection, bricks: [
                LabelBrick(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 0.5), height: .auto(estimate: .fixed(size: 50)), backgroundColor: .brickGray3, dataSource: self)
                ]),
            LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray5, dataSource: titleModel),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        
        
        section.repeatCountDataSource = self
        
        self.setSection(section)
        updateTitle()

    }

    func updateTitle() {
            titleModel.text = "There are \(stepperModel.count) label(s)".uppercased()
        self.brickCollectionView.reloadBricksWithIdentifiers([BrickIdentifiers.titleLabel])
    }

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return Int(stepperModel.count)
        } else {
            return 1
        }
    }

    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        let text = "BRICK \(cell.index + 1)"
        cell.label.text = text
        cell.configure()
    }
}

extension BasicInteractiveViewController: StepperBrickCellDelegate {

    func stepperBrickCellDidUpdateStepper(cell: StepperBrickCell) {
        stepperModel.count = Int(cell.stepper.value)
        updateTitle()

        self.brickCollectionView.reloadBricksWithIdentifiers([Stepper, BrickIdentifiers.titleLabel], shouldReloadCell: false)
        self.brickCollectionView.invalidateRepeatCounts()
//        self.brickCollectionView.reloadBricksWithIdentifiers([RepeatSection, Section], shouldReloadCell: true)
    }

}

extension BasicInteractiveViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(_ stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return identifier == BrickIdentifiers.titleLabel
    }
}



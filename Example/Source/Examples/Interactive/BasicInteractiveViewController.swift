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

class BasicInteractiveViewController: BrickViewController, LabelBrickCellDataSource, BrickRepeatCountDataSource {

    override class var title: String {
        return "Basic Interaction"
    }

    override class var subTitle: String {
        return "Shows how to add and remove bricks in an interactive way"
    }

    var stepperModel = StepperBrickModel(count: 1)
    
    var titleModel = LabelBrickCellModel(text: "There are no values".uppercaseString) { cell in
        cell.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground


        self.brickCollectionView.registerBrickClass(LabelBrick.self)
        self.brickCollectionView.registerBrickClass(StepperBrick.self)
        self.brickCollectionView.registerBrickClass(SegmentHeaderBrick.self)

        self.layout.zIndexBehavior = .BottomUp

        let stickyBehavior = StickyFooterLayoutBehavior(dataSource: self)
        self.layout.behaviors.insert(stickyBehavior)
        
        let section = BrickSection(Section, bricks: [
            StepperBrick(Stepper, height: .Auto(estimate: .Fixed(size: 50)), backgroundColor: .brickGray1, dataSource: stepperModel, delegate: self),
            BrickSection(RepeatSection, bricks: [
                LabelBrick(BrickIdentifiers.repeatLabel, width: .Ratio(ratio: 0.5), height: .Auto(estimate: .Fixed(size: 50)), backgroundColor: .brickGray3, dataSource: self)
                ]),
            LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray5, dataSource: titleModel),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        
        
        section.repeatCountDataSource = self
        
        self.setSection(section)
        updateTitle()

    }

    func updateTitle() {
            titleModel.text = "There are \(stepperModel.count) label(s)".uppercaseString
        self.brickCollectionView.reloadBricksWithIdentifiers([BrickIdentifiers.titleLabel])
    }

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return Int(stepperModel.count)
        } else {
            return 1
        }
    }

    func configureLabelBrickCell(cell: LabelBrickCell) {
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
    func stickyLayoutBehavior(stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return identifier == BrickIdentifiers.titleLabel
    }
}



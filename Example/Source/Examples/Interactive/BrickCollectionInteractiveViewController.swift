//
//  BrickCollectionInteractiveViewController.swift
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

private let FooterTitleLabel = "FooterTitleLabel"
private let FooterSection = "FooterSection"

private let RepeatTitleLabel = "RepeatTitleLabel"
private let RepeatLabel1 = "RepeatLabel1"
private let RepeatLabel2 = "RepeatLabel2"

class BrickCollectionInteractiveViewController: BrickViewController, HasTitle {

    class var brickTitle: String {
        return "CollectionBrick"
    }
    
    class var subTitle: String {
        return "Shows how to add and remove CollectionBricks in an interactive way"
    }

    #if os(iOS)
    var stepperModel = StepperBrickModel(count: 1)
    #endif
    
    var footerModel = LabelBrickCellModel(text: "There are no values")

    var repeatSection: BrickSection!

    var dataSources: [BrickCollectionViewDataSource] = []

    var even = true

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = self.brickCollectionView.layout
        layout.zIndexBehavior = .bottomUp

        self.registerBrickClass(LabelBrick.self)
        self.registerBrickClass(CollectionBrick.self)
        
        #if os(iOS)
        self.registerBrickClass(StepperBrick.self)
        #endif
        
        self.brickCollectionView.backgroundColor = .brickBackground

        repeatSection = BrickSection(RepeatSection, bricks: [
            LabelBrick(RepeatTitleLabel, backgroundColor: .brickGray1, dataSource: self),
            LabelBrick(RepeatLabel1, width: .ratio(ratio: 0.5), backgroundColor: .brickGray2, dataSource: self),
            LabelBrick(RepeatLabel2, width: .ratio(ratio: 0.5), backgroundColor: .brickGray4, dataSource: self),
            ])

        let footerSection = BrickSection(FooterSection, backgroundColor: UIColor.darkGray, bricks: [
            LabelBrick(FooterTitleLabel, backgroundColor: .brickGray1, dataSource: footerModel),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        
        let bricksTypes: [Brick.Type] = [LabelBrick.self, CollectionBrick.self]
        
        #if os(iOS)
            let section = BrickSection(Section, bricks: [
                LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "Tap here to change the collections".uppercased()) { cell in
                    cell.configure()
                    }),
                
                StepperBrick(Stepper, backgroundColor: .brickGray1, dataSource: stepperModel, delegate: self),
                
                BrickSection(RepeatSection, bricks: [
                    CollectionBrick(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 0.5), backgroundColor: .brickGray5, dataSource: self, brickTypes: bricksTypes)
                    ], inset: 5),
                footerSection
                ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        #else
            let section = BrickSection(Section, bricks: [
                LabelBrick(BrickIdentifiers.titleLabel, backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "Tap here to change the collections".uppercased()) { cell in
                    cell.configure()
                    }),
                BrickSection(RepeatSection, bricks: [
                    CollectionBrick(BrickIdentifiers.repeatLabel, width: .ratio(ratio: 0.5), backgroundColor: .brickGray5, dataSource: self, brickTypes: bricksTypes)
                    ], inset: 5),
                footerSection
                ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        #endif
        section.repeatCountDataSource = self

        let stickyBehavior = StickyFooterLayoutBehavior(dataSource: self)
        self.layout.behaviors.insert(stickyBehavior)

        updateDataSources()


        self.setSection(section)
        self.layout.hideBehaviorDataSource = self

        updateTitle()

    }

    var currentCount: Int {
        #if os(iOS)
            return stepperModel.count
        #else
            return 1
        #endif
    }

    func updateDataSources() {
        dataSources = []

        for _ in 0..<currentCount {
            let dataSource = BrickCollectionViewDataSource()
            dataSource.setSection(repeatSection)
            dataSources.append(dataSource)
        }
    }

    func updateTitle() {
        footerModel.text = "There are \(1) label(s)"
        reloadBricksWithIdentifiers([FooterTitleLabel])
    }
}

extension BrickCollectionInteractiveViewController {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let brickInfo = brickCollectionView.brickInfo(at:indexPath)
        if brickInfo.brick.identifier == BrickIdentifiers.titleLabel {
            even = !even
            UIView.performWithoutAnimation({
                self.reloadBricksWithIdentifiers([BrickIdentifiers.repeatLabel, RepeatSection], shouldReloadCell: true)
            })
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension BrickCollectionInteractiveViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        if cell.brick.identifier == RepeatTitleLabel {
            cell.label.text = "Title \(cell.collectionIndex + 1)"
        }

        cell.label.text = "Label \(cell.collectionIndex + 1)"
    }
}

extension BrickCollectionInteractiveViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return currentCount
        } else {
            return 1
        }
    }
}

#if os(iOS)
extension BrickCollectionInteractiveViewController: StepperBrickCellDelegate {
    func stepperBrickCellDidUpdateStepper(cell: StepperBrickCell) {
        stepperModel.count = Int(cell.stepper.value)
        updateTitle()
        updateDataSources()
        UIView.animate(withDuration: 0.5, animations: {
            self.brickCollectionView.invalidateRepeatCounts()
            self.reloadBricksWithIdentifiers([RepeatSection, Stepper, FooterSection])
            })
    }
}
#endif

extension BrickCollectionInteractiveViewController: CollectionBrickCellDataSource {
    func registerBricks(for cell: CollectionBrickCell) {
        #if os(iOS)
            cell.brickCollectionView.registerBrickClass(StepperBrick.self)
        #endif
    }
    
    func configure(for cell: CollectionBrickCell) {
        let layout = cell.brickCollectionView.layout
        layout.hideBehaviorDataSource = self
    }

    func dataSourceForCollectionBrickCell(_ cell: CollectionBrickCell) -> BrickCollectionViewDataSource {
        return dataSources[cell.index]
    }
}

extension BrickCollectionInteractiveViewController: HideBehaviorDataSource {

    func hideBehaviorDataSource(shouldHideItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        guard let brickCollectionView = collectionViewLayout.collectionView as? BrickCollectionView else {
            return false
        }
        let brickInfo = brickCollectionView.brickInfo(at:indexPath)

        if identifier == FooterTitleLabel {
            return true
        } else if identifier == RepeatTitleLabel && (brickInfo.collectionIndex % 2 == 0) == even {
            return true
        }

        return false
    }
}

extension BrickCollectionInteractiveViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(_ stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return identifier == FooterSection
    }
}


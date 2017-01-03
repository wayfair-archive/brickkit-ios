//
//  ChangeNibBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/25/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

private let Buttons = "Buttons"
private let Button1 = "Button1"
private let Button2 = "Button2"
private let ChangeButton = "Change"

private let nib1 = LabelBrickNibs.Default
private let nib2 = UINib(nibName: "CustomLabel", bundle: nil)

class ChangeNibBrickViewController: BrickViewController, LabelBrickCellDataSource, BrickRepeatCountDataSource {

    override class var title: String {
        return "Change Nib"
    }

    override class var subTitle: String {
        return "Change nibs interactively"
    }
    
    let numberOfLabels = 20

    var nib = nib1
    var repeatBrick: LabelBrick!

    var widthRatio: CGFloat = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        let behavior = StickyLayoutBehavior(dataSource: self)
        self.layout.behaviors.insert(behavior)

        registerBrickClass(ButtonBrick.self)
        registerBrickClass(LabelBrick.self)
        registerNib(nib, forBrickWithIdentifier: BrickIdentifiers.repeatLabel)

        let configureButton: ConfigureButtonBlock = { cell in
            cell.configure()
        }

        repeatBrick = LabelBrick(BrickIdentifiers.repeatLabel, width: .Ratio(ratio: widthRatio), height: .Auto(estimate: .Fixed(size: 50)), backgroundColor: .brickGray5, dataSource: self)

        let section = BrickSection(bricks: [
            BrickSection(Buttons, backgroundColor: .whiteColor(), bricks: [
                LabelBrick(ChangeButton, backgroundColor: .brickGray3, text: "Change".uppercaseString, configureCellBlock: LabelBrickCell.configure),
                ButtonBrick(Button2, width: .Ratio(ratio: 1/3), backgroundColor: .brickGray1, title: "Width".uppercaseString, configureButtonBlock: configureButton, onButtonTappedHandler:{_ in
                    self.changeWidth()
                }),
                ButtonBrick(Button1, width: .Ratio(ratio: 1/3), backgroundColor: .brickGray1, title: "Nib".uppercaseString, configureButtonBlock: configureButton, onButtonTappedHandler:{_ in
                    self.changeNib()
                }),
                ButtonBrick(Button2, width: .Ratio(ratio: 1/3), backgroundColor: .brickGray1, title: "Nib + Width".uppercaseString, configureButtonBlock: configureButton, onButtonTappedHandler:{_ in
                    self.changeNibAndWidth()
                }),
                ]),
            repeatBrick
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        section.repeatCountDataSource = self

        self.setSection(section)
    }

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return numberOfLabels
        } else {
            return 1
        }
    }

    func configureLabelBrickCell(cell: LabelBrickCell) {
        cell.label.text = "BRICK \(cell.index + 1)"
        cell.configure()
    }


    func changeNib(reload: Bool = true) {
        nib = (nib == nib1 ? nib2 : nib1)
        brickCollectionView.registerNib(nib, forBrickWithIdentifier: BrickIdentifiers.repeatLabel)

        if reload {
            brickCollectionView.reloadData()
        }
    }

    func changeWidth(reload: Bool = true) {
        widthRatio = widthRatio == 1 ? 0.5 : 1
        repeatBrick.width = .Ratio(ratio: widthRatio)

        if reload {
            brickCollectionView.invalidateBricks(false)
        }
    }
    
    func changeNibAndWidth() {
        changeWidth(false)
        changeNib(false)
        brickCollectionView.reloadData()
    }

}

extension ChangeNibBrickViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return identifier == Buttons
    }
}

//
//  DynamicContentViewController.swift
//  BrickKit
//
//  Created by Victor Wu on 9/26/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

private let AllSections = "AllSections"


class DynamicContentViewController: BrickViewController {

    struct Identifiers {
        static let HideableSectionContentImage = "HideableSectionContentImage"
    }

    override class var title: String {
        return "Dynamic Resizing Content"
    }

    override class var subTitle: String {
        return "Resizing content after loading a section"
    }

    //To fully check if this is fixed, check with hidden = true on startup and hidden = false
    var hidden: Bool = false
    var reload: Bool = false

    var imageURLs: [NSURL] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.registerBrickClass(LabelBrick.self)
        self.registerBrickClass(ImageBrick.self)

        let section = BrickSection(bricks: [
            hideSectionNested(),
            hideableSection(),
            shownSectionLabel(),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        section.repeatCountDataSource = self

        self.setSection(section)

        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(DynamicContentViewController.timerFired), userInfo: nil, repeats: false)
    }

    func timerFired() {
        for _ in 1...5 {
            self.imageURLs.append(NSURL(string:"https://secure.img2.wfrcdn.com/lf/8/hash/2664/10628031/1/custom_image.jpg")!)
        }

        self.brickCollectionView.invalidateRepeatCounts()
    }

    func hideSectionNested() -> BrickSection {
        let sectionLabelBrick = LabelBrick(backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "Section 0".uppercaseString, configureCellBlock: LabelBrickCell.configure))
        let section = BrickSection(backgroundColor: .brickSection, bricks: [
            sectionLabelBrick
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20))

        return section
    }

    func hideableSection() -> BrickSection {
        let brick = LabelBrick(height: .Auto(estimate: .Fixed(size:30)), backgroundColor: .brickGray3, text: "Section 1 Label 0".uppercaseString, configureCellBlock: LabelBrickCell.configure)
        let imageBrick = ImageBrick(DynamicContentViewController.Identifiers.HideableSectionContentImage, height: .Auto(estimate: .Fixed(size:100)), backgroundColor: .brickGray3, dataSource: self)
        let brick0 = LabelBrick(height: .Auto(estimate: .Fixed(size:30)), backgroundColor: .brickGray3, text: "Section 1 Label 1".uppercaseString, configureCellBlock: LabelBrickCell.configure)

        let section = BrickSection(backgroundColor: .brickSection, bricks: [
            brick0,
            imageBrick,
            brick
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        return section
    }

    func shownSectionLabel() -> BrickSection {
        let brick = LabelBrick(backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "Section 2 Label 1".uppercaseString))

        let section = BrickSection(backgroundColor: .brickSection, bricks: [
            brick
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

        return section
    }

}

extension DynamicContentViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        switch identifier {
        case DynamicContentViewController.Identifiers.HideableSectionContentImage:
            return imageURLs.count
        default:
            return 1
        }
    }
}

extension DynamicContentViewController: ImageBrickDataSource {

    func imageURLForImageBrickCell(imageBrickCell: ImageBrickCell) -> NSURL? {
        return imageURLs[imageBrickCell.index]
    }

    func contentModeForImageBrickCell(imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return .ScaleAspectFit
    }
}

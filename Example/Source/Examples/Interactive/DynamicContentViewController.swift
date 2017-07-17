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


class DynamicContentViewController: BrickViewController, HasTitle {

    struct Identifiers {
        static let HideableSectionContentImage = "HideableSectionContentImage"
    }

    class var brickTitle: String {
        return "Dynamic Resizing Content"
    }

    class var subTitle: String {
        return "Resizing content after loading a section"
    }

    //To fully check if this is fixed, check with hidden = true on startup and hidden = false
    var hidden: Bool = false
    var reload: Bool = false

    var imageURLs: [URL]?
    let placeholderCount = 5
    let overrideContentSource = ActivityIndicatorOverrideSource()
    
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

        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(DynamicContentViewController.timerFired), userInfo: nil, repeats: false)
        self.overrideContentSource.shouldOverride = true
    }

    @objc func timerFired() {
        self.overrideContentSource.shouldOverride = false
        imageURLs = []
        for _ in 1...5 {
            self.imageURLs?.append(URL(string:"https://secure.img2.wfrcdn.com/lf/8/hash/2664/10628031/1/custom_image.jpg")!)
        }
        self.brickCollectionView.reloadBricksWithIdentifiers([DynamicContentViewController.Identifiers.HideableSectionContentImage])
    }

    func hideSectionNested() -> BrickSection {
        let sectionLabelBrick = LabelBrick(backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "Section 0".uppercased(), configureCellBlock: LabelBrickCell.configure))
        let section = BrickSection(backgroundColor: .brickSection, bricks: [
            sectionLabelBrick
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20))

        return section
    }

    func hideableSection() -> BrickSection {
        let brick = LabelBrick(height: .auto(estimate: .fixed(size:30)), backgroundColor: .brickGray3, text: "Section 1 Label 0".uppercased(), configureCellBlock: LabelBrickCell.configure)
        let imageBrick = ImageBrick(DynamicContentViewController.Identifiers.HideableSectionContentImage, height: .auto(estimate: .fixed(size:100)), backgroundColor: .brickGray3, dataSource: self)
        imageBrick.overrideContentSource = self.overrideContentSource
        let brick0 = LabelBrick(height: .auto(estimate: .fixed(size:30)), backgroundColor: .brickGray3, text: "Section 1 Label 1".uppercased(), configureCellBlock: LabelBrickCell.configure)

        let section = BrickSection(backgroundColor: .brickSection, bricks: [
            brick0,
            imageBrick,
            brick
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        return section
    }

    func shownSectionLabel() -> BrickSection {
        let brick = LabelBrick(backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "Section 2 Label 1".uppercased()))

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
            guard let imageURLs = imageURLs else {
                return placeholderCount
            }
            return imageURLs.count
        default:
            return 1
        }
    }
}

extension DynamicContentViewController: ImageBrickDataSource {

    func imageURLForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> URL? {
        return imageURLs?[imageBrickCell.index]
    }

    func contentModeForImageBrickCell(_ imageBrickCell: ImageBrickCell) -> UIViewContentMode {
        return .scaleAspectFit
    }
}

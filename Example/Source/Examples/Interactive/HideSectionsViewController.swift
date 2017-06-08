//
//  HideSectionsViewController.swift
//  BrickKit
//
//  Created by Victor Wu on 9/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class HideSectionsViewController: BrickViewController, HasTitle {
    class var brickTitle: String {
        return "Hiding Sections"
    }
    class var subTitle: String {
        return "Showing the power of the hide section layout behavior"
    }

    //To fully check if this is fixed, check with hidden = true on startup and hidden = false
    var hidden: Bool = false

    struct Identifiers {
        static let HideableSectionLabelSection = "HideableSectionLabelSection"
        static let HideableSectionContentSection = "HideableSectionContentSection"
        static let HideableNestedSection = "HideableNestedSection"
        static let HideableSectionLabelNestedContent = "HideableSectionLabelNestedContent"
        static let HideableSectionContent = "HideableSectionContent"
        static let ShownSectionContent = "ShownSectionContent"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.registerBrickClass(LabelBrick.self)

        let section = BrickSection(backgroundColor: .brickGray5, bricks: [
            hideSectionNested(),
            hideableSectionLabel(),
            hideableSection(),
            shownSectionLabel(),
            shownSection()
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        section.repeatCountDataSource = self

        self.setSection(section)
        self.layout.hideBehaviorDataSource = self
        self.updateNavigationItem()
    }

    func hideSectionNested() -> BrickSection {
        let sectionLabelBrick = LabelBrick(backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "Section 0 Label 1"))
        let nestedContentBrick = LabelBrick(HideSectionsViewController.Identifiers.HideableSectionLabelNestedContent, backgroundColor: .brickGray3, dataSource: LabelBrickCellModel(text: "Section 0 Label 2"))

        let nestedSection = BrickSection(backgroundColor: .brickGray5, bricks: [
            nestedContentBrick
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20))

        let section = BrickSection(HideSectionsViewController.Identifiers.HideableNestedSection , backgroundColor: .brickGray1, bricks: [
            sectionLabelBrick, nestedSection
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20))

        return section
    }

    func hideableSectionLabel() -> BrickSection {
        let brick = LabelBrick(backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "Section 1 Label 1"))

        let section = BrickSection(HideSectionsViewController.Identifiers.HideableSectionLabelSection , backgroundColor: .brickGray1, bricks: [
            brick
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

        return section
    }

    func hideableSection() -> BrickSection {
        let brick = LabelBrick(HideSectionsViewController.Identifiers.HideableSectionContent, backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "Section 1 Content"))

        let section = BrickSection(HideSectionsViewController.Identifiers.HideableSectionContentSection , backgroundColor: .brickGray3, bricks: [
            brick
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        return section
    }

    func shownSectionLabel() -> BrickSection {
        let brick = LabelBrick(backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "Section 2 Label 1"))

        let section = BrickSection(backgroundColor: .brickGray3, bricks: [
            brick
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

        return section
    }

    func shownSection() -> BrickSection {
        let brick = LabelBrick(HideSectionsViewController.Identifiers.ShownSectionContent, backgroundColor: .brickGray1, dataSource: LabelBrickCellModel(text: "Section 2 Content"))

        let section = BrickSection(backgroundColor: .brickGray3, bricks: [
            brick
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))

        return section
    }

    func updateNavigationItem() {
        let title: String
        switch hidden {
        case false: title = "Hide"
        default: title = "Show"
        }

        let selector: Selector = #selector(HideSectionsViewController.toggleHidden)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: selector)
    }

    @objc func toggleHidden() {
        self.hidden = !self.hidden
        updateNavigationItem()

        self.brickCollectionView.invalidateVisibility()
    }
}

extension HideSectionsViewController: HideBehaviorDataSource {
    func hideBehaviorDataSource(shouldHideItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        guard let _ = collectionViewLayout.collectionView as? BrickCollectionView else {
            return false
        }

        switch identifier {
        case HideSectionsViewController.Identifiers.HideableSectionLabelSection, HideSectionsViewController.Identifiers.HideableSectionContentSection, HideSectionsViewController.Identifiers.HideableNestedSection:
            return hidden
        default:
            return false
        }
    }
}

extension HideSectionsViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        switch identifier {
        case HideSectionsViewController.Identifiers.HideableSectionLabelNestedContent:
            return 5
        case HideSectionsViewController.Identifiers.HideableSectionContent:
            return 5
        case HideSectionsViewController.Identifiers.ShownSectionContent:
            return 5
        default:
            return 1
        }
    }
}

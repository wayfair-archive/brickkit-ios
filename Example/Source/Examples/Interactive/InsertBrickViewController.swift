//
//  InsertBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 8/5/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

private let Section = "Section"
private let AppearSegmentHeaderBrick = "AppearSegmentHeaderBrick"
private let InsertSegmentHeaderBrick = "InsertSegmentHeaderBrick"

class InsertBrickViewController: BrickApp.BaseBrickController, HasTitle {

    var data: [String] = ["BRICK 1"]

    class var brickTitle: String {
        return "Insert Brick"
    }

    class var subTitle: String {
        return "Shows different ways of inserting a brick"
    }

    var selectedAppearSegmentIndex: Int = 0 {
        didSet {
            let appearBehavior: BrickAppearBehavior?
            switch selectedAppearSegmentIndex {
            case 1: appearBehavior = BrickAppearTopBehavior()
            case 2: appearBehavior = BrickAppearBottomBehavior()
            case 3: appearBehavior = BrickAppearScaleBehavior()
            default: appearBehavior = nil
            }
            self.layout.appearBehavior = appearBehavior
        }
    }

    var appearTitles: [String] {
        return ["None", "Above", "Below", "Scale"]
    }

    var insertToIndex: Int {
        switch selectedInsertSegmentIndex {
        case 1: return data.count / 2
        case 2: return data.count
        default: return 0
        }
    }

    var selectedInsertSegmentIndex: Int = 0

    var insertTitles: [String] {
        return ["On top", "In the middle", "At the bottom"]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground
        self.brickCollectionView.registerBrickClass(LabelBrick.self)
        self.brickCollectionView.registerBrickClass(SegmentHeaderBrick.self)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(InsertBrickViewController.insertBrick))

        let appearSegmentedBrick = GenericBrick<UISegmentedControl>(AppearSegmentHeaderBrick) { [weak self] view, cell in
            guard let titles = self?.appearTitles else {
                return
            }

            self?.configureSegmentedControl(view: view, titles: titles, identifier: cell.identifier)
        }

        let insertSegmentedBrick = GenericBrick<UISegmentedControl>(InsertSegmentHeaderBrick) { [weak self] view, cell in
            guard let titles = self?.insertTitles else {
                return
            }

            self?.configureSegmentedControl(view: view, titles: titles, identifier: cell.identifier)
        }

        let section = BrickSection(Section, bricks: [
            BrickSection(bricks: [
                        appearSegmentedBrick,
                        insertSegmentedBrick], inset: 10),
            LabelBrick(BrickIdentifiers.repeatLabel, height: .fixed(size: 37), backgroundColor: UIColor.lightGray, dataSource: self)
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        section.repeatCountDataSource = self

        self.setSection(section)
    }

    @objc func insertBrick() {
        let newElement = "BRICK \(data.count + 1)"
        let index = insertToIndex
        if selectedInsertSegmentIndex == 2 {
            data.append(newElement)
        } else {
            data.insert(newElement, at: index)
        }

        UIView.animate(withDuration: 0.5, animations: {
            self.brickCollectionView.insertItems(at: index, for: BrickIdentifiers.repeatLabel, itemCount: 1)
        })
    }

    func removeBrick(indexPath: IndexPath) {
        let index = indexPath.item - 1
        data.remove(at: index)

        UIView.animate(withDuration: 0.5, animations: {
            self.brickCollectionView.deleteItems(at: index, for: BrickIdentifiers.repeatLabel, itemCount: 1)
        })
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let brickInfo = self.brickCollectionView.brickInfo(at: indexPath)
        if brickInfo.brick.identifier == BrickIdentifiers.repeatLabel {
            removeBrick(indexPath: indexPath)
        }
    }

    func configureSegmentedControl(view: UISegmentedControl, titles: [String], identifier: String) {
        for (index, title) in titles.enumerated() {
            view.insertSegment(withTitle: title, at: index, animated: false)
        }
        view.selectedSegmentIndex = 0
        switch identifier {
        case AppearSegmentHeaderBrick:
            view.addTarget(self, action: #selector(setAppearIndex), for: .valueChanged)
        case InsertSegmentHeaderBrick:
            view.addTarget(self, action: #selector(setInsertIndex), for: .valueChanged)
        default: break
        }
    }

    @objc func setAppearIndex(sender: UISegmentedControl) {
        self.selectedAppearSegmentIndex = sender.selectedSegmentIndex
    }

    @objc func setInsertIndex(sender: UISegmentedControl) {
        self.selectedInsertSegmentIndex = sender.selectedSegmentIndex
    }
}


extension InsertBrickViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == BrickIdentifiers.repeatLabel {
            return data.count
        } else {
            return 1
        }
    }
}

extension InsertBrickViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(_ cell: LabelBrickCell) {
        cell.label.text = data[cell.index]
        cell.configure()
    }
}

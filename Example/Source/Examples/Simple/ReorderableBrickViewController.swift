//
//  ReorderableBrickViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 6/30/17.
//  Copyright © 2017 Wayfair LLC. All rights reserved.
//

import Foundation
import BrickKit

fileprivate let repeatCount: Int = 5

class ReorderableBrickViewController: BrickViewController, HasTitle {
    class var brickTitle: String {
        return "Reorderable Section"
    }

    class var subTitle: String {
        return "Reorderable Sections allow you to specify your own way of ordering bricks within a section"
    }

    let label1 = GenericBrick<UILabel>("Label1", backgroundColor: .brickGray1) { label, cell in
        cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        label.text = "Label1 - \(cell.index)"
        label.configure(textColor: UIColor.brickGray1.complemetaryColor)
    }

    let label2 = GenericBrick<UILabel>("Label2", backgroundColor: .brickGray3) { label, cell in
        cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        label.text = "Label2 - \(cell.index)"
        label.configure(textColor: UIColor.brickGray3.complemetaryColor)
    }

    var reorderSection1: BrickSection!
    var reorderSection2: BrickSection!
    var reorderSection3: BrickSection!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        label1.repeatCount = repeatCount
        label2.repeatCount = repeatCount

        reorderSection1 = BrickSection(bricks: [
            label1,
            label2
            ], inset: 5)
        reorderSection1.orderDataSource = self

        reorderSection2 = BrickSection(bricks: [
            label1,
            label2
            ], inset: 5)
        reorderSection2.orderDataSource = self

        reorderSection3 = BrickSection(bricks: [
            label1,
            label2
            ], inset: 5)
        reorderSection3.orderDataSource = self

        let section = BrickSection(bricks: [
            BrickSection(backgroundColor: .brickGray2, bricks: [
                GenericBrick<UILabel>(backgroundColor: .brickGray5) { label, cell in
                    cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

                    label.text = "Normal "
                    label.configure(textColor: UIColor.brickGray5.complemetaryColor)
                },
                reorderSection1,
                ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)),
            BrickSection(backgroundColor: .brickGray2, bricks: [
                GenericBrick<UILabel>(backgroundColor: .brickGray5) { label, cell in
                    cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

                    label.text = "Staggered"
                    label.configure(textColor: UIColor.brickGray5.complemetaryColor)
                },
                reorderSection2,
                ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)),
            BrickSection(backgroundColor: .brickGray2, bricks: [
                GenericBrick<UILabel>(backgroundColor: .brickGray5) { label, cell in
                    cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

                    label.text = "Advanced"
                    label.configure(textColor: UIColor.brickGray5.complemetaryColor)
                },
                reorderSection3
                ], inset: 10, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
            ], inset: 20, edgeInsets: UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10))

        self.setSection(section)
    }
}

extension ReorderableBrickViewController: BrickSectionOrderDataSource {

    func brickAndIndex(atIndex brickIndex: Int, section: BrickSection) -> (Brick, Int)? {
        if section === reorderSection2 {
            let actualIndex = brickIndex / 2
            if brickIndex % 2 == 0 {
                return (section.bricks[0], actualIndex)
            } else {
                return (section.bricks[1], actualIndex)
            }
        } else if section === reorderSection3 {
            let advancedRepeat = [
                [0, 1, 2, 5, 8],
                [3, 4, 6, 7, 9]
            ]
            let actualIndex: Int
            let brick: Brick
            if advancedRepeat[0].contains(brickIndex) {
                actualIndex = advancedRepeat[0].index(of: brickIndex)!
                brick = section.bricks[0]
            } else {
                actualIndex = advancedRepeat[1].index(of: brickIndex)!
                brick = section.bricks[1]
            }
            return (brick, actualIndex)
        } else {
            return nil
        }
    }
    
}

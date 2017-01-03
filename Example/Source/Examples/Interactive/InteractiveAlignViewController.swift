//
//  InteractiveAlignViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 12/9/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class ScaleAppearBehavior: BrickAppearBehavior {
    let scale: CGFloat

    init(scale: CGFloat) {
        self.scale = scale
    }

    func configureAttributesForAppearing(attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        attributes.transform = CGAffineTransformMakeScale(scale, scale)
        attributes.alpha = 0
    }

    func configureAttributesForDisappearing(attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        attributes.transform = CGAffineTransformMakeScale(scale, scale)
        attributes.alpha = 0
    }

}

class InteractiveAlignViewController: BrickViewController {

    override class var title: String {
        return "Interactive Align"
    }

    override class var subTitle: String {
        return "Change height dynamically"
    }


    var numberOfItems: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(InteractiveAlignViewController.add))

        self.registerBrickClass(LabelBrick.self)
        self.brickCollectionView.layout.appearBehavior = ScaleAppearBehavior(scale: 0.5)

        let labelBrick = LabelBrick("Label", width: .Ratio(ratio: 1/3), height: .Fixed(size: 100), backgroundColor: UIColor.lightGrayColor().colorWithAlphaComponent(0.3), dataSource: self)

        let section = BrickSection(bricks: [
            labelBrick,
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), alignment: .Center)
        section.repeatCountDataSource = self
        setSection(section)
    }

    func add() {
        numberOfItems += 1
        updateCounts()
    }

    func remove(indexPath: NSIndexPath) {
        numberOfItems -= 1
        updateCounts([indexPath])
    }

    func updateCounts(fixedDeletedIndexPaths: [NSIndexPath]? = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseIn, animations: {
            self.brickCollectionView.invalidateRepeatCounts(reloadAllSections: false)
            }, completion: nil)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        remove(indexPath)
    }

}

extension InteractiveAlignViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(cell: LabelBrickCell) {
        cell.label.text = "BRICK \(cell.index)"
        cell.configure()
    }
}

extension InteractiveAlignViewController: BrickRepeatCountDataSource {

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == "Label" {
            return numberOfItems
        } else {
            return 1
        }
    }
    
}

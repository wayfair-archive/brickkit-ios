
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

    func configureAttributesForAppearing(_ attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        attributes.alpha = 0
    }

    func configureAttributesForDisappearing(_ attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        attributes.alpha = 0
    }

}

class InteractiveAlignViewController: BrickViewController, HasTitle {

    class var brickTitle: String {
        return "Interactive Align"
    }

    class var subTitle: String {
        return "Change height dynamically"
    }


    var numberOfItems: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(InteractiveAlignViewController.add))

        self.brickCollectionView.layout.appearBehavior = ScaleAppearBehavior(scale: 0.5)

        let labelBrick = GenericBrick<UILabel>("Label", width: .ratio(ratio: 1), /*height: .fixed(size: 100),*/ backgroundColor: .brickGray1) { label, cell in
            label.text = "BRICK \(cell.index)"
            label.configure(textColor: UIColor.brickGray1.complemetaryColor)
            cell.edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }

        let section = BrickSection(bricks: [
            labelBrick,
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), alignment: BrickAlignment(horizontal: .center, vertical: .top))
        section.repeatCountDataSource = self
        setSection(section)
    }

    @objc func add() {
        numberOfItems += 1
        updateCounts()
    }

    func remove(indexPath: IndexPath) {
        numberOfItems -= 1
        updateCounts(fixedDeletedIndexPaths: [indexPath])
    }

    func updateCounts(fixedDeletedIndexPaths: [IndexPath]? = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            self.brickCollectionView.invalidateRepeatCounts(reloadAllSections: false)
            }, completion: nil)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        remove(indexPath: indexPath)
    }

}

extension InteractiveAlignViewController: LabelBrickCellDataSource {
    func configureLabelBrickCell(_ cell: LabelBrickCell) {
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

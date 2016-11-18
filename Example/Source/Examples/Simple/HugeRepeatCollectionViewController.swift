//
//  HugeRepeatCollectionViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 11/17/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

private let reuseIdentifier = "Cell"

class PrintableFlowLayout: UICollectionViewFlowLayout {
    override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayoutWithContext(context)

        print("context.contentOffsetAdjustment: \(context.contentOffsetAdjustment)")
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        print("layoutAttributesForElementsInRect: \(rect)")
        return super.layoutAttributesForElementsInRect(rect)
    }
}

class HugeRepeatCollectionViewController: UICollectionViewController, LabelBrickCellDataSource {

    override class var title: String {
        return "Huge Repeat CollectionView"
    }
    override class var subTitle: String {
        return "Example how to repeat a huge amount of bricks"
    }

    let numberOfLabels = 100000

    init() {
        let flow = PrintableFlowLayout()
        let width = (UIScreen.mainScreen().bounds.width - 20) / 2
        flow.estimatedItemSize = CGSize(width: width, height: 50)
        flow.minimumLineSpacing = 10
        flow.minimumInteritemSpacing = 10
        flow.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        super.init(collectionViewLayout: flow)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .brickBackground
        self.collectionView!.backgroundColor = .clearColor()
        self.collectionView!.registerNib(LabelBrickNibs.Default, forCellWithReuseIdentifier: reuseIdentifier)
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfLabels
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LabelBrickCell

        let brick = LabelBrick(backgroundColor: .brickGray1, dataSource: self)
        cell.setContent(brick, index: indexPath.item, collectionIndex: 0, collectionIdentifier: nil)
        cell.contentView.backgroundColor = .brickGray1

        return cell
    }

    func configureLabelBrickCell(cell: LabelBrickCell) {
        var text = ""

        for _ in 0...cell.index {
            if !text.isEmpty {
                text += " "
            }
            text += "BRICK \(cell.index)"
        }
        cell.label.text = text
        cell.configure()
    }

}

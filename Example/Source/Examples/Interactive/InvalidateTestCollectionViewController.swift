//
//  InvalidateTestCollectionViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 7/8/17.
//  Copyright © 2017 Wayfair LLC. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class TestCollectionView: UICollectionView {

    override func layoutSubviews() {
        print("before COLLECTIONVIEW layoutSubviews: \(self.subviews.map({$0.frame.height}))")
        super.layoutSubviews()
        print("after COLLECTIONVIEW layoutSubviews: \(self.subviews.map({$0.frame.height}))")
    }
}

class TestCell: UICollectionViewCell {
    open override var frame: CGRect {
        didSet {
            print(frame)
        }
    }

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        print("apply for \(layoutAttributes.indexPath.item): \(layoutAttributes.frame.height)")
        print("before apply for \(layoutAttributes.indexPath.item): \(frame.height)")
        super.apply(layoutAttributes)
        print("after apply for \(layoutAttributes.indexPath.item): \(frame.height)")
    }
    
    open override func layoutSubviews() {
        print("before layoutSubviews: \(frame.height)")
        super.layoutSubviews()
        print("after layoutSubviews: \(frame.height)")

    }

    open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        self.layoutIfNeeded()
        return super.preferredLayoutAttributesFitting(layoutAttributes)
    }

}

class TestLayout: UICollectionViewLayout {
    static let numberOfCells: Int = 2
    var height: CGFloat = 0
    var layoutAttributes: [UICollectionViewLayoutAttributes] = []

    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView!.frame.width, height: height)
    }

    override init() {
        super.init()

        layoutAttributes = []

        for i in 0..<TestLayout.numberOfCells {
            let a = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
            a.frame = CGRect(x: 0, y: 50 * CGFloat(i), width: 0, height: 50)
            layoutAttributes.append(a)
        }

        height = layoutAttributes.last!.frame.maxY

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()
        for (index, layoutAttribute) in layoutAttributes.enumerated() {
            layoutAttribute.frame.size.width = self.collectionView!.frame.width
            if index != 0 {
                layoutAttribute.frame.origin.y = layoutAttributes[index-1].frame.maxY
            }
        }
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        print("invalidateLayout \(context)")
        print("  - invalidateEverything \(context.invalidateEverything)")
        print("  - invalidatedItemIndexPaths \(context.invalidatedItemIndexPaths)")
        print("  - invalidateDataSourceCounts \(context.invalidateDataSourceCounts)")
        super.invalidateLayout(with: context)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        print("layoutAttributesForElements: \(layoutAttributes.map({$0.indexPath.item}))")
        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("layoutAttributesForItem: \(indexPath.item)")
        return layoutAttributes[indexPath.item]
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        attributes?.alpha = 1
        return attributes
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        attributes?.alpha = 1
        return attributes
    }

}

class InvalidateTestCollectionViewController: UIViewController, UICollectionViewDataSource {
    let layout = TestLayout()
    open var collectionView: TestCollectionView?

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeComponents()
        self.collectionView?.backgroundColor = .white
        self.view.backgroundColor = .white
        self.collectionView?.register(TestCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(test))
    }

    fileprivate func initializeComponents() {
        autoreleasepool { // This would result in not releasing the BrickCollectionView even when its being set to nil
            let collectionView = TestCollectionView(frame: self.view.bounds, collectionViewLayout: layout)
            collectionView.backgroundColor = UIColor.clear
            collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            self.view.addSubview(collectionView)

            self.collectionView = collectionView
            self.collectionView?.dataSource = self
        }
    }


    func test() {
        UIView.animate(withDuration: 2) {
            self.collectionView?.performBatchUpdates({
                var frame = self.layout.layoutAttributes[0].frame
                frame.size.height = frame.height == 50 ? 100 : 50
                self.layout.layoutAttributes[0].frame = frame
                self.layout.height = self.layout.layoutAttributes.last!.frame.maxY

//                self.layout.invalidateLayout()
            }, completion: nil)
        }
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TestLayout.numberOfCells
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        switch indexPath.item {
        case 0: cell.backgroundColor = .black
        case 1: cell.backgroundColor = .yellow
        case 2: cell.backgroundColor = .red
        case 3: cell.backgroundColor = .orange
        default: cell.backgroundColor = .purple
        }
    
        return cell
    }
}

//
//  BrickSelfsizingFlowLayout.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 8/29/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest

class BrickSelfsizingFlowLayoutTests: XCTestCase {

    let frame = CGRect(x: 0, y: 0, width: 320, height: 480)

    var collectionView: UICollectionView!
    
    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: 20, height: 20)
        flowLayout.itemSize = frame.size
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0

        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }

    fileprivate func framesForCollectionView() -> [CGRect] {
        collectionView.layoutSubviews()
        let frames = collectionView.subviews.map { $0.frame }
        return frames
    }

}

extension BrickSelfsizingFlowLayoutTests: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }
}

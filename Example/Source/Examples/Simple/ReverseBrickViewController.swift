//
//  ReverseBrickViewController.swift
//  BrickKit-Example
//
//  Created by Ruben Cagnie on 7/6/17.
//  Copyright © 2017 Wayfair LLC. All rights reserved.
//

import Foundation
import BrickKit

class ReverseBrickViewController: BrickViewController, HasTitle {
    class var brickTitle: String {
        return "Reverse Bricks"
    }

    class var subTitle: String {
        return "Bricks going from bottom to top"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        let label = GenericBrick<UILabel>("Label1", height: .auto(estimate: .fixed(size: 50)), backgroundColor: .brickGray1) { label, cell in
            cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

            var text = "Label \(cell.index)"
            for _ in 0..<(cell.index % 10) {
                text += "\nrepeat"
            }
            label.text = text
            label.configure(textColor: UIColor.brickGray1.complemetaryColor)
        }
        label.repeatCount = 5000

        let section = BrickSection(bricks: [
            label
            ], inset: 20, edgeInsets: UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10))

        self.setSection(section)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToBottom()
    }

    func scrollToBottom() {
        brickCollectionView.layoutSubviews()

        let contentHeight = self.brickCollectionView.contentSize.height
        let bottomOffset = CGPoint(x: 0, y: contentHeight - brickCollectionView.frame.height)
        brickCollectionView.setContentOffset(bottomOffset, animated: false)

        brickCollectionView.layoutSubviews()

        if self.brickCollectionView.contentSize.height != contentHeight {
            scrollToBottom()
        }
    }

}

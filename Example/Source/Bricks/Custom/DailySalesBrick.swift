
//
//  DailySalesBrick.swift
//  BrickKit
//
//  Created by Yusheng Yang on 9/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation
import BrickKit

class DailySalesBrick: Brick {
    weak var dataSource: DailySalesBrickDataSource?

    convenience init(_ identifier: String, width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, dataSource: DailySalesBrickDataSource) {
        self.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView, dataSource: dataSource)
    }

    init(_ identifier: String, size: BrickSize, backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, dataSource: DailySalesBrickDataSource) {
        self.dataSource = dataSource
        super.init(identifier, size: size, backgroundColor: backgroundColor, backgroundView: backgroundView)
    }
}


class DailySalesBrickCell: BrickCell, Bricklike {
    typealias BrickType = DailySalesBrick
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameButton: UIButton!
    
    override func updateContent() {
        super.updateContent()
        
        guard let dataSource = brick.dataSource else {
            return
        }
        
        imageView.image = dataSource.image(cell: self)
        nameButton.setTitle(dataSource.buttonTitle(cell: self), for: .normal)
    }
}

protocol DailySalesBrickDataSource: class {
    func image(cell: DailySalesBrickCell) -> UIImage
    func buttonTitle(cell: DailySalesBrickCell) -> String
}


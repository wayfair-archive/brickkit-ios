//
//  HeaderAndFooter.swift
//  BrickKit
//
//  Created by Yusheng Yang on 9/20/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation
import BrickKit

class HeaderAndFooterBrick: Brick {
    weak var dataSource: HeaderAndFooterBrickModel?
    
    init(_ identifier: String, width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, dataSource: ((HeaderAndFooterBrickCell) -> Void)) {
        self.dataSource = HeaderAndFooterBrickModel(configureCell: dataSource)
        super.init(identifier, width: width, height: height, backgroundColor: backgroundColor, backgroundView: backgroundView)
    }
}

protocol HeaderAndFooterBrickDataSource {
    func text(cell: HeaderAndFooterBrickCell)
}

class HeaderAndFooterBrickModel: HeaderAndFooterBrickDataSource {
    let configureCell: (HeaderAndFooterBrickCell) ->Void
    
    init(configureCell: ((HeaderAndFooterBrickCell) ->Void)) {
        self.configureCell = configureCell
    }
    
     func text(cell: HeaderAndFooterBrickCell) {
        configureCell(cell)
    }
}

class HeaderAndFooterBrickCell: BrickCell, Bricklike {
    typealias BrickType = HeaderAndFooterBrick
    
    @IBOutlet var textLabel: UILabel!
    
    override func updateContent() {
        super.updateContent()
        brick.dataSource?.text(self)
    }
    
}


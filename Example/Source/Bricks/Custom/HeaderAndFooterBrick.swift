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
    
    init(_ identifier: String, width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, dataSource: @escaping ((HeaderAndFooterBrickCell) -> Void)) {
        self.dataSource = HeaderAndFooterBrickModel(configureCell: dataSource)
        super.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView)
    }
}

protocol HeaderAndFooterBrickDataSource {
    func text(cell: HeaderAndFooterBrickCell)
}

class HeaderAndFooterBrickModel: HeaderAndFooterBrickDataSource {
    let configureCell: (HeaderAndFooterBrickCell) ->Void
    
    init(configureCell: @escaping ((HeaderAndFooterBrickCell) ->Void)) {
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
        brick.dataSource?.text(cell: self)
    }
    
}


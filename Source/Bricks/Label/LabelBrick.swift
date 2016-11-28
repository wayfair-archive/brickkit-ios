//
//  LabelBrickCell.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit

public typealias ConfigureLabelBlock = ((cell: LabelBrickCell) -> Void)

// MARK: - Nibs

public struct LabelBrickNibs {
    public static let Default = UINib(nibName: LabelBrick.nibName, bundle: LabelBrick.bundle)
    public static let Chevron = UINib(nibName: "LabelBrickChevron", bundle: LabelBrick.bundle)
    public static let Image = UINib(nibName: "LabelBrickImage", bundle: LabelBrick.bundle)
    public static let Button = UINib(nibName: "LabelBrickButton", bundle: LabelBrick.bundle)
}

// MARK: - Brick

public class LabelBrick: Brick {
    weak var dataSource: LabelBrickCellDataSource?
    weak var delegate: LabelBrickCellDelegate?


    public var text: String? {
        set {
            if let model = dataSource as? LabelBrickCellModel {
                model.text = newValue ?? ""
            } else {
                fatalError("Can't set `text` of a LabelBrick where its dataSource is not a LabelBrickCellModel")
            }
        }
        get {
            if let model = dataSource as? LabelBrickCellModel {
                return model.text
            } else {
                fatalError("Can't get `text` of a LabelBrick where its dataSource is not a LabelBrickCellModel")
            }
        }
    }

    public var configureCellBlock: ConfigureLabelBlock? {
        set {
            if let model = dataSource as? LabelBrickCellModel {
                model.configureCellBlock = newValue
            } else {
                fatalError("Can't set `configureCellBlock` of a LabelBrick where its dataSource is not a LabelBrickCellModel")
            }
        }
        get {
            if let model = dataSource as? LabelBrickCellModel {
                return model.configureCellBlock
            } else {
                fatalError("Can't get `configureCellBlock` of a LabelBrick where its dataSource is not a LabelBrickCellModel")
            }
        }
    }
    
    private var dataSourceModel: LabelBrickCellModel?
    private var delegateModel: LabelBrickCellModel?
    
    convenience public init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = UIColor.clearColor(), backgroundView: UIView? = nil, text: String, configureCellBlock: ConfigureLabelBlock? = nil) {
        let model = LabelBrickCellModel(text: text, configureCellBlock: configureCellBlock)
        self.init(identifier, width: width, height: height, backgroundColor: backgroundColor, backgroundView: backgroundView, dataSource: model)
    }

    public init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = UIColor.clearColor(), backgroundView: UIView? = nil, dataSource: LabelBrickCellDataSource, delegate: LabelBrickCellDelegate? = nil) {
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(identifier, width: width, height: height, backgroundColor: backgroundColor, backgroundView: backgroundView)
        
        if let delegateModel = delegate as? LabelBrickCellModel {
            self.delegateModel = delegateModel
        }
        
        if let dataSourceModel = dataSource as? LabelBrickCellModel where delegate !== dataSource {
            self.dataSourceModel = dataSourceModel
        }

    }
    
}

// MARK: - DataSource

/// An object that adopts the `LabelBrickCellDataSource` protocol is responsible for providing the data required by a `LabelBrick`.
public protocol LabelBrickCellDataSource: class {
    func configureLabelBrickCell(cell: LabelBrickCell)
}

// MARK: - Delegate

public protocol LabelBrickCellDelegate: class {
    func buttonTouchedForLabelBrickCell(cell: LabelBrickCell)
}

// MARK: - Models

public class LabelBrickCellModel: LabelBrickCellDataSource {
    public var text: String
    public var configureCellBlock: ConfigureLabelBlock?
    public var textColor: UIColor?

    public init(text:String, textColor:UIColor? = nil, configureCellBlock: ConfigureLabelBlock? = nil){
        self.text = text
        self.textColor = textColor
        self.configureCellBlock = configureCellBlock
    }

    public func configureLabelBrickCell(cell: LabelBrickCell) {
        let label = cell.label
        label.text = text
        if let color = textColor {
            label.textColor = color
        }
        configureCellBlock?(cell: cell)

    }
}

public class LabelWithDecorationImageBrickCellModel: LabelBrickCellModel {
    public var image: UIImage

    public init(text:String, textColor:UIColor? = nil, image:UIImage, configureCellBlock: ConfigureLabelBlock? = nil) {
        self.image = image
        super.init(text: text, textColor: textColor, configureCellBlock: configureCellBlock)
    }

    override public func configureLabelBrickCell(cell: LabelBrickCell) {
        if let imageView = cell.imageView {
            imageView.image = image
        }
        super.configureLabelBrickCell(cell)
    }

}

// MARK: - Cell

public class LabelBrickCell: BrickCell, Bricklike {
    public typealias BrickType = LabelBrick

    @IBOutlet weak public var label: UILabel!
    @IBOutlet weak public var button: UIButton?
    @IBOutlet weak public var horizontalRuleLeft: UIView?
    @IBOutlet weak public var horizontalRuleRight: UIView?
    @IBOutlet weak public var imageView: UIImageView?

    override public func updateContent() {
        horizontalRuleLeft?.hidden = true
        horizontalRuleRight?.hidden = true
        brick.dataSource?.configureLabelBrickCell(self)
        super.updateContent()
    }

    @IBAction func buttonTapped(sender: UIButton) {
        brick.delegate?.buttonTouchedForLabelBrickCell(self)
    }
}

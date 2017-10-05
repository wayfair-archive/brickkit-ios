//
//  LabelBrickCell.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit

public typealias ConfigureLabelBlock = ((_ cell: LabelBrickCell) -> Void)

// MARK: - Nibs

public struct LabelBrickNibs {
    public static let Default = UINib(nibName: LabelBrick.nibName, bundle: LabelBrick.bundle)
    public static let Chevron = UINib(nibName: "LabelBrickChevron", bundle: LabelBrick.bundle)
    public static let Image = UINib(nibName: "LabelBrickImage", bundle: LabelBrick.bundle)
    public static let Button = UINib(nibName: "LabelBrickButton", bundle: LabelBrick.bundle)
}

// MARK: - Brick

open class LabelBrick: GenericBrick<UILabel> {
    weak var dataSource: LabelBrickCellDataSource?
    weak var delegate: LabelBrickCellDelegate?

    open override class var internalIdentifier: String {
        return self.nibName
    }

    open override class var cellClass: UICollectionViewCell.Type? {
        return LabelBrickCell.self
    }

    open override class var bundle: Bundle {
        return Bundle(for: Brick.self)
    }

    open var text: String? {
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

    open var configureCellBlock: ConfigureLabelBlock? {
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
    
    fileprivate var dataSourceModel: LabelBrickCellModel?
    fileprivate var delegateModel: LabelBrickCellModel?
    
    public convenience init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, text: String, configureCellBlock: ConfigureLabelBlock? = nil) {
        let model = LabelBrickCellModel(text: text, configureCellBlock: configureCellBlock)
        self.init(identifier, width: width, height: height, backgroundColor: backgroundColor, backgroundView: backgroundView, dataSource: model)
    }

    public convenience init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, dataSource: LabelBrickCellDataSource, delegate: LabelBrickCellDelegate? = nil) {
        self.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView, dataSource: dataSource, delegate: delegate)
    }
    
    public convenience init(_ identifier: String = "", size: BrickSize, backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, text: String, configureCellBlock: ConfigureLabelBlock? = nil) {
        let model = LabelBrickCellModel(text: text, configureCellBlock: configureCellBlock)
        self.init(identifier, size: size, backgroundColor: backgroundColor, backgroundView: backgroundView, dataSource: model)
    }

    public init(_ identifier: String = "", size: BrickSize, backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, dataSource: LabelBrickCellDataSource, delegate: LabelBrickCellDelegate? = nil) {

    
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(identifier, size: size, backgroundColor: backgroundColor, backgroundView: backgroundView, configureView: { (label: UILabel, cell: BrickCell) in
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 14)
        })

        if let delegateModel = delegate as? LabelBrickCellModel {
            self.delegateModel = delegateModel
        }
        
        if let dataSourceModel = dataSource as? LabelBrickCellModel , delegate !== dataSource {
            self.dataSourceModel = dataSourceModel
        }

    }
    
}

// MARK: - DataSource

/// An object that adopts the `LabelBrickCellDataSource` protocol is responsible for providing the data required by a `LabelBrick`.
public protocol LabelBrickCellDataSource: class {
    func configureLabelBrickCell(_ cell: LabelBrickCell)
}

// MARK: - Delegate

public protocol LabelBrickCellDelegate: class {
    func buttonTouchedForLabelBrickCell(_ cell: LabelBrickCell)
}

// MARK: - Models

open class LabelBrickCellModel: LabelBrickCellDataSource {
    open var text: String
    open var configureCellBlock: ConfigureLabelBlock?
    open var textColor: UIColor?

    public init(text:String, textColor:UIColor? = nil, configureCellBlock: ConfigureLabelBlock? = nil){
        self.text = text
        self.textColor = textColor
        self.configureCellBlock = configureCellBlock
    }

    open func configureLabelBrickCell(_ cell: LabelBrickCell) {
        let label = cell.label
        label?.text = text
        if let color = textColor {
            label?.textColor = color
        }
        configureCellBlock?(cell)

    }
}

open class LabelWithDecorationImageBrickCellModel: LabelBrickCellModel {
    open var image: UIImage

    public init(text:String, textColor:UIColor? = nil, image:UIImage, configureCellBlock: ConfigureLabelBlock? = nil) {
        self.image = image
        super.init(text: text, textColor: textColor, configureCellBlock: configureCellBlock)
    }

    override open func configureLabelBrickCell(_ cell: LabelBrickCell) {
        if let imageView = cell.imageView {
            imageView.image = image
        }
        super.configureLabelBrickCell(cell)
    }

}

// MARK: - Cell

open class LabelBrickCell: GenericBrickCell, Bricklike {
    public typealias BrickType = LabelBrick

    @IBOutlet weak open var label: UILabel!
    @IBOutlet weak open var button: UIButton?
    @IBOutlet weak open var horizontalRuleLeft: UIView?
    @IBOutlet weak open var horizontalRuleRight: UIView?
    @IBOutlet weak open var imageView: UIImageView?

    override open func updateContent() {
        horizontalRuleLeft?.isHidden = true
        horizontalRuleRight?.isHidden = true

        super.updateContent()

        if !fromNib {
            self.label = self.genericContentView as! UILabel
        }
        brick.dataSource?.configureLabelBrickCell(self)
    }

    override open func prepareForReuse() {
        super.prepareForReuse()
        self.backgroundColor = .clear
        self.backgroundView = nil
        self.isHidden = false
        self.edgeInsets = UIEdgeInsets.zero
        self.accessoryView = nil

        self.label.text = nil
        self.label.attributedText = nil
        self.label.textAlignment = .natural
        self.label.numberOfLines = 0
        self.label.textColor = .black
        self.label.isHidden = false
        self.label.backgroundColor = .clear

        self.horizontalRuleLeft = nil
        self.horizontalRuleRight = nil

        if !fromNib {
            self.button = nil
            self.imageView?.image = nil
        }
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        brick.delegate?.buttonTouchedForLabelBrickCell(self)
    }

#if os(tvOS)
    override public var allowsFocus: Bool {
        get {
            return true
        }
        set {
            super.allowsFocus = true
        }
    }
#endif

}

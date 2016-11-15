//
//  ButtonBrick.swift
//  BrickKit
//
//  Created by Kevin Lopez on 6/2/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

public typealias ConfigureButtonBlock = ((cell: ButtonBrickCell) -> Void)
public typealias ButtonTappedBlock = ((cell: ButtonBrickCell) -> Void)

// MARK: - Nibs

public struct ButtonBrickNibs {
    public static let Chevron = UINib(nibName: "ButtonBrickWithChevron", bundle: ButtonBrick.bundle)
}

// MARK: - Brick

public class ButtonBrick: Brick {
    public weak var dataSource: ButtonBrickCellDataSource?
    public weak var delegate: ButtonBrickCellDelegate?

    public var title: String? {
        set {
            if let model = dataSource as? ButtonBrickCellModel {
                model.title = newValue ?? ""
            } else {
                fatalError("Can't set `title` of a ButtonBrick where its dataSource is not a ButtonBrickCellModel")
            }
        }
        get {
            if let model = dataSource as? ButtonBrickCellModel {
                return model.title
            } else {
                fatalError("Can't get `title` of a ButtonBrick where its dataSource is not a ButtonBrickCellModel")
            }
        }
    }

    public var configureButtonBlock: ConfigureButtonBlock? {
        set {
            if let model = dataSource as? ButtonBrickCellModel {
                model.configureButtonBlock = newValue
            } else {
                fatalError("Can't set `configureButtonBlock` of a ButtonBrick where its dataSource is not a ButtonBrickCellModel")
            }
        }
        get {
            if let model = dataSource as? ButtonBrickCellModel {
                return model.configureButtonBlock
            } else {
                fatalError("Can't get `configureButtonBlock` of a ButtonBrick where its dataSource is not a ButtonBrickCellModel")
            }
        }
    }

    private var dataSourceModel: ButtonBrickCellModel?
    private var delegateModel: ButtonBrickCellModel?

    convenience public init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = UIColor.clearColor(), backgroundView: UIView? = nil, title: String, configureButtonBlock: ConfigureButtonBlock? = nil, onButtonTappedHandler: ButtonTappedBlock? = nil) {
        let model = ButtonBrickCellModel(title: title, configureButtonBlock: configureButtonBlock, onButtonTappedHandler: onButtonTappedHandler)
        self.init(identifier, width: width, height: height, backgroundColor: backgroundColor, backgroundView: backgroundView, dataSource: model, delegate: model)
    }

    public init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, dataSource: ButtonBrickCellDataSource, delegate: ButtonBrickCellDelegate? = nil) {
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(identifier, width: width, height: height, backgroundColor:backgroundColor, backgroundView:backgroundView)
        
        if let delegateModel = delegate as? ButtonBrickCellModel {
            self.delegateModel = delegateModel
        }

        if let dataSourceModel = dataSource as? ButtonBrickCellModel where delegate !== dataSource {
            self.dataSourceModel = dataSourceModel
        }
    }
}

// MARK: - DataSource

public protocol ButtonBrickCellDataSource: class {
    func configureButtonBrick(cell: ButtonBrickCell)
}

// MARK: - Delegate

public protocol ButtonBrickCellDelegate: class {
    func didTapOnButtonForButtonBrickCell(cell: ButtonBrickCell)
}

// MARK: - Models

public class ButtonBrickCellModel: ButtonBrickCellDataSource, ButtonBrickCellDelegate {
    public var title: String
    public var configureButtonBlock: ConfigureButtonBlock?
    public var onButtonTappedHandler: ButtonTappedBlock?

    public init(title: String, configureButtonBlock: ConfigureButtonBlock? = nil, onButtonTappedHandler: ButtonTappedBlock? = nil){
        self.title = title
        self.configureButtonBlock = configureButtonBlock
        self.onButtonTappedHandler = onButtonTappedHandler
    }

    public func configureButtonBrick(cell: ButtonBrickCell) {
        cell.button.setTitle(title, forState: .Normal)
        configureButtonBlock?(cell: cell)
    }

    public func didTapOnButtonForButtonBrickCell(cell: ButtonBrickCell) {
        onButtonTappedHandler?(cell: cell)
    }
}

// MARK: - Cell

public class ButtonBrickCell: BrickCell, Bricklike {
    public typealias BrickType = ButtonBrick

    @IBOutlet weak public var button: UIButton!
    @IBOutlet weak public var rightImage: UIImageView?

    override public func updateContent() {
        super.updateContent()
        brick.dataSource?.configureButtonBrick(self)
    }

    @IBAction public func didTapButton(sender: AnyObject) {
        brick.delegate?.didTapOnButtonForButtonBrickCell(self)
    }
}


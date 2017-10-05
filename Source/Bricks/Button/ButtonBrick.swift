//
//  ButtonBrick.swift
//  BrickKit
//
//  Created by Kevin Lopez on 6/2/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

public typealias ConfigureButtonBlock = ((_ cell: ButtonBrickCell) -> Void)
public typealias ButtonTappedBlock = ((_ cell: ButtonBrickCell) -> Void)

// MARK: - Nibs

public struct ButtonBrickNibs {
    public static let Chevron = UINib(nibName: "ButtonBrickWithChevron", bundle: ButtonBrick.bundle)
}

// MARK: - Brick

open class ButtonBrick: GenericBrick<UIButton> {
    open weak var dataSource: ButtonBrickCellDataSource?
    open weak var delegate: ButtonBrickCellDelegate?

    open override class var internalIdentifier: String {
        return self.nibName
    }

    open override class var cellClass: UICollectionViewCell.Type? {
        return ButtonBrickCell.self
    }

    open override class var bundle: Bundle {
        return Bundle(for: Brick.self)
    }

    open var title: String? {
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

    open var configureButtonBlock: ConfigureButtonBlock? {
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

    fileprivate var dataSourceModel: ButtonBrickCellModel?
    fileprivate var delegateModel: ButtonBrickCellModel?

    public convenience init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, title: String, configureButtonBlock: ConfigureButtonBlock? = nil, onButtonTappedHandler: ButtonTappedBlock? = nil) {
        let model = ButtonBrickCellModel(title: title, configureButtonBlock: configureButtonBlock, onButtonTappedHandler: onButtonTappedHandler)
        self.init(identifier, width: width, height: height, backgroundColor: backgroundColor, backgroundView: backgroundView, dataSource: model, delegate: model)
    }

    public convenience init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, dataSource: ButtonBrickCellDataSource, delegate: ButtonBrickCellDelegate? = nil) {
        self.init(identifier, size: BrickSize(width: width, height: height), backgroundColor:backgroundColor, backgroundView:backgroundView, dataSource: dataSource, delegate: delegate)
    }
    
    public convenience init(_ identifier: String, size: BrickSize, backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, title: String, configureButtonBlock: ConfigureButtonBlock? = nil, onButtonTappedHandler: ButtonTappedBlock? = nil) {
        let model = ButtonBrickCellModel(title: title, configureButtonBlock: configureButtonBlock, onButtonTappedHandler: onButtonTappedHandler)
        self.init(identifier, size: size, backgroundColor: backgroundColor, backgroundView: backgroundView, dataSource: model, delegate: model)
    }
    
    public init(_ identifier: String, size: BrickSize, backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, dataSource: ButtonBrickCellDataSource, delegate: ButtonBrickCellDelegate? = nil) {
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(identifier, size: size, backgroundColor:backgroundColor, backgroundView:backgroundView, configureView: { (button, cell) in
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        })
        
        if let delegateModel = delegate as? ButtonBrickCellModel {
            self.delegateModel = delegateModel
        }
        
        if let dataSourceModel = dataSource as? ButtonBrickCellModel , delegate !== dataSource {
            self.dataSourceModel = dataSourceModel
        }
    }

}

// MARK: - DataSource

public protocol ButtonBrickCellDataSource: class {
    func configureButtonBrick(_ cell: ButtonBrickCell)
}

// MARK: - Delegate

public protocol ButtonBrickCellDelegate: class {
    func didTapOnButtonForButtonBrickCell(_ cell: ButtonBrickCell)
}

// MARK: - Models

open class ButtonBrickCellModel: ButtonBrickCellDataSource, ButtonBrickCellDelegate {
    open var title: String
    open var configureButtonBlock: ConfigureButtonBlock?
    open var onButtonTappedHandler: ButtonTappedBlock?

    public init(title: String, configureButtonBlock: ConfigureButtonBlock? = nil, onButtonTappedHandler: ButtonTappedBlock? = nil){
        self.title = title
        self.configureButtonBlock = configureButtonBlock
        self.onButtonTappedHandler = onButtonTappedHandler
    }

    open func configureButtonBrick(_ cell: ButtonBrickCell) {
        cell.button.setTitle(title, for: UIControlState())
        configureButtonBlock?(cell)
    }

    open func didTapOnButtonForButtonBrickCell(_ cell: ButtonBrickCell) {
        onButtonTappedHandler?(cell)
    }
}

// MARK: - Cell

open class ButtonBrickCell: GenericBrickCell, Bricklike {
    public typealias BrickType = ButtonBrick

    @IBOutlet weak open var button: UIButton!
    @IBOutlet weak open var rightImage: UIImageView?

    override open func updateContent() {
        super.updateContent()

        if !fromNib {
            self.button = self.genericContentView as! UIButton
            self.button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        }

        brick.dataSource?.configureButtonBrick(self)
    }

    override open func prepareForReuse() {
        super.prepareForReuse()

        self.isHidden = false
        self.accessoryView = nil
        self.backgroundView = nil
        self.backgroundColor = .clear

        self.button.isHidden = false
        self.button.setImage(nil, for: .normal)
        self.button.setTitle(nil, for: .normal)
        self.button.setTitleColor(.black, for: .normal)
        self.button.setBackgroundImage(nil, for: .normal)
        self.button.titleLabel?.attributedText = nil
        self.button.titleLabel?.textAlignment = .natural
        self.button.titleLabel?.numberOfLines = 0
        self.button.titleLabel?.backgroundColor = nil

        if !fromNib {
            rightImage?.image = nil
        }
    }

    @IBAction open func didTapButton(_ sender: AnyObject) {
        brick.delegate?.didTapOnButtonForButtonBrickCell(self)
    }
}

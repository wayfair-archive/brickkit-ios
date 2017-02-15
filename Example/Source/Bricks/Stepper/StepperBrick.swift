//
//  ExampleStepperBrick.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/26/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

public class StepperBrick: Brick {
    public let dataSource: StepperBrickCellDataSource
    public let delegate: StepperBrickCellDelegate

    public init(_ identifier: String, width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 50)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, dataSource: StepperBrickCellDataSource, delegate: StepperBrickCellDelegate) {
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView)
    }

}

public class StepperBrickModel: StepperBrickCellDataSource {
    public var count: Int

    public init(count: Int){
        self.count = count
    }

    public func countForExampleStepperBrickCell(cell: StepperBrickCell) -> Int {
        return count
    }
}

public protocol StepperBrickCellDataSource {
    func countForExampleStepperBrickCell(cell: StepperBrickCell) -> Int
}

public protocol StepperBrickCellDelegate {
    func stepperBrickCellDidUpdateStepper(cell: StepperBrickCell)
}

public class StepperBrickCell: BrickCell, Bricklike {
    public typealias BrickType = StepperBrick

    @IBOutlet weak public var label: UILabel!
    @IBOutlet weak public var stepper: UIStepper!

    override public func updateContent() {
        super.updateContent()
        
        let count = brick.dataSource.countForExampleStepperBrickCell(cell: self)
        label.text = String(count)
        stepper.value = Double(count)
    }

    @IBAction func stepperDidUpdate(_ sender: UIStepper) {
        brick.delegate.stepperBrickCellDidUpdateStepper(cell: self)
    }
}

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

    public init(_ identifier: String, width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 50)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, dataSource: StepperBrickCellDataSource, delegate: StepperBrickCellDelegate) {
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(identifier, width: width, height: height, backgroundColor: backgroundColor, backgroundView: backgroundView)
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
        
        let count = brick.dataSource.countForExampleStepperBrickCell(self)
        label.text = String(count)
        stepper.value = Double(count)
    }

    @IBAction func stepperDidUpdate(sender: UIStepper) {
        brick.delegate.stepperBrickCellDidUpdateStepper(self)
    }
}

//
//  BaseBrickController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/4/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

/// Convenience class for the Sample Brick
class BaseBrickController: BrickViewController {

    var behavior: BrickLayoutBehavior?

    var isBehaviorEnabled = true {
        didSet {
            updateBehavior(false)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .brickBackground
        updateBehavior(true)

        if self.presentingViewController != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(BaseBrickController.close))
        }
    }

    func updateBehavior(onAppear: Bool) {
        guard let behavior = self.behavior else {
            return
        }
        let selector = #selector(BaseBrickController.toggleBehavior)
        if self.isBehaviorEnabled {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Disable", style: .Plain, target: self, action: selector)
            self.layout.behaviors.insert(behavior)
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Enable", style: .Plain, target: self, action: selector)
            self.layout.behaviors.remove(behavior)
        }
        if !onAppear {
            self.brickCollectionView.invalidateBricks()
        }
    }

    func toggleBehavior() {
        isBehaviorEnabled = !isBehaviorEnabled
    }

    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    static func configureCell(cell: LabelBrickCell) {
        cell.configure()
    }

}

extension LabelBrickCell {

    func configure() {
        label.textAlignment = .Center
        label.textColor = brick.backgroundColor.complemetaryColor
    }
}

extension ButtonBrickCell {

    func configure() {
        button.titleLabel?.textAlignment = .Center
        button.setTitleColor(brick.backgroundColor.complemetaryColor, forState: .Normal)
    }
}

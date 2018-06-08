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
            updateBehavior()
            self.brickCollectionView.invalidateBricks()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .brickBackground
        updateBehavior()

        if self.presentingViewController != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(BaseBrickController.close))
        }
    }

    func updateBehavior() {
        guard let behavior = self.behavior else {
            return
        }
        let selector = #selector(BaseBrickController.toggleBehavior)
        if self.isBehaviorEnabled {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Disable", style: .plain, target: self, action: selector)
            self.layout.behaviors.insert(behavior)
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Enable", style: .plain, target: self, action: selector)
            self.layout.behaviors.remove(behavior)
        }
    }

    @objc func toggleBehavior() {
        isBehaviorEnabled = !isBehaviorEnabled
    }

    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UILabel {

    func configure(textColor: UIColor?) {
        self.textAlignment = .center
        self.textColor = textColor
        self.numberOfLines = 0
    }

}

extension LabelBrickCell {

    static func configure(cell: LabelBrickCell) {
        cell.configure()
    }

    func configure() {
        label.configure(textColor: brick.backgroundColor.complemetaryColor)
    }
}

extension ButtonBrickCell {

    func configure() {
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(brick.backgroundColor.complemetaryColor, for: .normal)
    }
}

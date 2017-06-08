//
//  PopoverBrickViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/28/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

class PopoverBrickViewController: UIViewController, HasTitle {

    class var brickTitle: String {
        return "Popover"
    }

    class var subTitle: String {
        return "Example for size classes"
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .brickBackground

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Popover", style: .plain, target: self, action: #selector(PopoverBrickViewController.showPopover))

    }

    @objc func showPopover(sender: UIBarButtonItem) {
        let brickController = SimpleRepeatBrickViewController()

        brickController.modalPresentationStyle = .popover
        self.present(brickController, animated: true, completion: nil)
        
        let popoverController = brickController.popoverPresentationController
        popoverController?.permittedArrowDirections = .any
        popoverController?.barButtonItem = sender
    }

}

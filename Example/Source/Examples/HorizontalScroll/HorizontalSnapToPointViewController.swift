
//
//  HorizontalSnapToPointViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/13/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

class HorizontalSnapToPointViewController: SimpleHorizontalScrollBrickViewController {
    override class var brickTitle: String {
        return "Horizontal Snap-To-Point"
    }
    override class var subTitle: String {
        return "Combine the horizontal scroll with the SnapToPointLayoutBehavior"
    }

    var snapToPointBehavior = SnapToPointLayoutBehavior(scrollDirection: .horizontal(.center))

    override func viewDidLoad() {
        super.viewDidLoad()

        self.layout.behaviors.insert(snapToPointBehavior)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Location", style: .plain, target: self, action: #selector(HorizontalSnapToPointViewController.changeLocation))
    }

    @objc func changeLocation() {
        let alert = UIAlertController(title: "Change location", message: "Change the location of the snap to point", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Left", style: .default, handler: { (action) in
            self.updateScrollDirection(scrollDirection: .horizontal(.left))
        }))
        alert.addAction(UIAlertAction(title: "Center", style: .default, handler: { (action) in
            self.updateScrollDirection(scrollDirection: .horizontal(.center))
        }))
        alert.addAction(UIAlertAction(title: "Right", style: .default, handler: { (action) in
            self.updateScrollDirection(scrollDirection: .horizontal(.right))
        }))

        self.present(alert, animated: true, completion: nil)
    }

    func updateScrollDirection(scrollDirection: SnapToPointScrollDirection) {
        snapToPointBehavior.scrollDirection = scrollDirection
        self.layout.invalidateLayout()
    }
    
}

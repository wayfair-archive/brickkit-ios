//
//  HorizontalSnapToPointViewController.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/13/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import BrickKit

class HorizontalSnapToPointViewController: SimpleHorizontalScrollBrickViewController {
    override class var title: String {
        return "Horizontal Snap-To-Point"
    }
    override class var subTitle: String {
        return "Combine the horizontal scroll with the SnapToPointLayoutBehavior"
    }

    var snapToPointBehavior = SnapToPointLayoutBehavior(scrollDirection: .Horizontal(.Center))

    override func viewDidLoad() {
        super.viewDidLoad()

        self.layout.behaviors.insert(snapToPointBehavior)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Location", style: .Plain, target: self, action: #selector(HorizontalSnapToPointViewController.changeLocation))
    }

    func changeLocation() {
        let alert = UIAlertController(title: "Change location", message: "Change the location of the snap to point", preferredStyle: .ActionSheet)

        alert.addAction(UIAlertAction(title: "Left", style: .Default, handler: { (action) in
            self.updateScrollDirection(.Horizontal(.Left))
        }))
        alert.addAction(UIAlertAction(title: "Center", style: .Default, handler: { (action) in
            self.updateScrollDirection(.Horizontal(.Center))
        }))
        alert.addAction(UIAlertAction(title: "Right", style: .Default, handler: { (action) in
            self.updateScrollDirection(.Horizontal(.Right))
        }))

        self.present(alert, animated: true, completion: nil)
    }

    func updateScrollDirection(scrollDirection: SnapToPointScrollDirection) {
        snapToPointBehavior.scrollDirection = scrollDirection
        self.layout.invalidateLayout()
    }
    
}

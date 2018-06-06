//
//  ViewController.swift
//  BrickKit tvOS Example
//
//  Created by Justin Anderson on 10/12/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

#if swift(>=4.2)
//TODO: Remove this, hack for Xcode 10
import UIKit.UIGeometry
extension UIEdgeInsets {
    internal static let zero = UIEdgeInsets()
}
#endif


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


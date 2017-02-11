    //
//  AppDelegate.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/20/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import UIKit
import BrickKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        Theme.applyTheme()

        return true
    }

}


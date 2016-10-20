//
//  BrickDataSource.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

public class BrickCollectionViewDataSource: NSObject {

    /// Section model. Starts with an empty brick section
    public private(set) var section: BrickSection = BrickSection(bricks: [])

    /// Set the section of the datasource
    ///
    /// - parameter section: section
    public func setSection(section: BrickSection) {
        self.section = section
    }
}

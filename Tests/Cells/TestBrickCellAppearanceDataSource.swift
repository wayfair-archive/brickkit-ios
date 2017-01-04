//
//  TestBrickCellAppearanceDataSource.swift
//  BrickKit
//
//  Created by Nicholas LoBue on 12/19/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import BrickKit

class TestBrickCellAppearanceDataSource: BrickCellAppearanceDataSource {
    func viewForLoadingAppearance(with identifier: String) -> UIView? {
        let loadingView = UIView()
        loadingView.backgroundColor = .grayColor()
        loadingView.tag = 24
        return loadingView
    }
    func viewForLoadedAppearance(with identifier: String) -> UIView? {
        return nil
    }
    func viewForErrorAppearance(with identifier: String) -> UIView? {
        let errorView = UIView()
        errorView.backgroundColor = .redColor()
        errorView.tag = 25
        return errorView
    }
}

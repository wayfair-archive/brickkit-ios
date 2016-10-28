//
//  RootNavigationDataSource.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/14/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit


// Mark: - Navigation Item
struct NavigationItem: Equatable {
    let title: String
    let subTitle: String
    var viewControllers: [UIViewController.Type]
}

func ==(lhs: NavigationItem, rhs: NavigationItem) -> Bool {
    return lhs.title == rhs.title && lhs.subTitle == rhs.subTitle
}

/// NavigationDataSource: DataSource for the navigation objects
class NavigationDataSource {
    #if os(iOS)
        var layoutNavigationItem = NavigationItem(title: "Layout", subTitle: "Examples of different layout behaviors", viewControllers: [
        OffsetBrickViewController.self,
        SizeClassesBrickViewController.self
        ])
    #else
    var layoutNavigationItem = NavigationItem(title: "Layout", subTitle: "Examples of different layout behaviors", viewControllers: [
        OffsetBrickViewController.self
        ])
    #endif
    
    var selectedItem: NavigationItem?
    var selectedIndex: Int? {
        guard let selectedItem = self.selectedItem else {
            return nil
        }
        return sections.indexOf(selectedItem)
    }

    lazy var sections: [ NavigationItem ] = [
        NavigationItem(title: "Simple", subTitle: "Simple Examples", viewControllers: [
            SimpleBrickViewController.self,
            SimpleRepeatBrickViewController.self,
            NibLessViewController.self,
            SimpleRepeatFixedWidthViewController.self,
            SimpleRepeatFixedHeightViewController.self,
            SimpleRepeatHeightRatioViewController.self,
            MultiSectionBrickViewController.self,
            MultiDimensionBrickViewController.self,
            ]),
        self.InteractiveExamples,
        NavigationItem(title: "Sticky", subTitle: "Examples of different sticky behaviors", viewControllers: [
            BasicStickingViewController.self,
            StackedStickingViewController.self,
            SectionStickingViewController.self,
            StickingSectionsViewController.self,
            OnScrollDownStickingViewController.self,
            StickingFooterBaseViewController.self,
            StickingFooterSectionsViewController.self,
            StackingFooterViewController.self
            ]),
        NavigationItem(title: "Scrolling", subTitle: "Examples of different scrolling behaviors", viewControllers: [
            SpotlightScrollingViewController.self,
            EmbeddedSpotlightSnapScrollingViewController.self,
            CardScrollingViewController.self,
            CoverFlowScrollingViewController.self,
            ]),
        self.layoutNavigationItem,
        NavigationItem(title: "CollectionBrick", subTitle: "Examples of how to use CollectionBrick", viewControllers: [
            SimpleCollectionBrickViewController.self,
            RepeatCollectionBrickViewController.self,
            HorizontalScrollSectionBrickViewController.self
            ]),
        NavigationItem(title: "Horizontal", subTitle: "Examples of how to use horizontal scroll", viewControllers: [
            SimpleHorizontalScrollBrickViewController.self,
            HorizontalSnapToPointViewController.self,
            BlockHorizontalViewController.self,
            HorizontalCollectionViewController.self
            ]),
        NavigationItem(title: "Images", subTitle: "Examples of how to use images", viewControllers: [
            ImageViewBrickViewController.self,
            ImageURLBrickViewController.self,
            ImagesInCollectionBrickViewController.self,
            ImagesInCollectionBrickHorizontalViewController.self
            ]),
        NavigationItem(title: "Demo", subTitle: "Example Of Using BrickKit in Real Case", viewControllers: [
            MockTwitterViewController.self,
            MockFlickrViewController.self])
        ]


    var numberOfItems: Int {
        return sections.count
    }

    func item(for index: Int) -> NavigationItem {
        return sections[index]
    }
    
    #if os(iOS)
    var InteractiveExamples = NavigationItem(title: "Interactive", subTitle: "Interactive Examples", viewControllers: [
        BasicInteractiveViewController.self,
        BrickCollectionInteractiveViewController.self,
        HideBrickViewController.self,
        AdvancedRepeatViewController.self,
        InsertBrickViewController.self,
        ChangeNibBrickViewController.self,
        HideSectionsViewController.self,
        DynamicContentViewController.self,
        InvalidateHeightViewController.self
        ])
    #else
    var InteractiveExamples = NavigationItem(title: "Interactive", subTitle: "Interactive Examples", viewControllers: [
        BrickCollectionInteractiveViewController.self,
        HideBrickViewController.self,
        AdvancedRepeatViewController.self,
        InsertBrickViewController.self,
        ChangeNibBrickViewController.self,
        HideSectionsViewController.self,
        DynamicContentViewController.self,
        InvalidateHeightViewController.self
        ])
    #endif
}

// Mark: - NavigationIdentifiers
struct NavigationIdentifiers {
    static let titleSection = "TitleSection"
    static let titleBrick = "TitleBrick"

    static let navItemSection = "NavItemSection"
    static let navItemBrick = "NavItemBrick"

    static let subItemSection = "SubItemSection"
    static let subItemBrick = "SubItemBrick"
}


// MARK: - title / subTitle extension
extension UIViewController {

    class var title: String {
        return "Title"
    }
    class var subTitle: String {
        return "Sub Title"
    }

}


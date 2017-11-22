//
//  Theme.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/22/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class Theme {
    class func applyTheme() {

        //Tint Color
        UIApplication.shared.windows.first?.tintColor = .brickPurple1

        // UILabel
        #if os(tvOS)
            UILabel.appearance().font = UIFont.brickLightFont(size: 25)
        #else
            UILabel.appearance().font = UIFont.brickLightFont(size: 15)
        #endif

        // Navigation
        UINavigationBar.appearance().barTintColor = .brickBackground
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: Theme.textColorForNavigationTitle,
            .font: Theme.fontForNavigationTitle
        ]

        // EdgeInsets
        LabelBrickCell.appearance().edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        ButtonBrickCell.appearance().edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        SegmentHeaderBrickCell.appearance().edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    }

    class var textColorForNavigationTitle: UIColor {
        return UIColor.white
    }

    class var fontForNavigationTitle: UIFont {
        #if os(tvOS)
            return UIFont.brickSemiBoldFont(size: 25)
        #else
            return UIFont.brickSemiBoldFont(size: 15)
        #endif
    }

    class func setupNavigationBarForPrimaryUse(navigationBar: UINavigationBar) {
        #if os(iOS) // Only change the colors for iOS because on tvOS it should be a solid color
            navigationBar.barTintColor = .brickBackground
            navigationBar.tintColor = .brickPurple1
            navigationBar.titleTextAttributes = [
                .foregroundColor: Theme.textColorForNavigationTitle,
                .font: Theme.fontForNavigationTitle
            ]
        #endif
    }

    class func setupNavigationBarForSecondaryUse(navigationBar: UINavigationBar) {
        #if os(iOS) // Only change the colors for iOS because on tvOS it should be a solid color
            navigationBar.barTintColor = .brickPurple3
            navigationBar.tintColor = .brickGray1
            navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.brickGray1,
                .font: Theme.fontForNavigationTitle
            ]
        #endif
    }
}

//MARK: - Constants

enum DeviceType {
    case iPhone320 // iPhone 5, 5S, 5C
    case iPhone375 // iPhone 6, 6S, 7
    case iPhone414 // iPhone 6Plus, 6SPlus, 7Plus
    case iPad // iPad
    case AppleTV
    case Unknown

    var brickWidth: CGFloat {
        switch self {
        case .iPhone375: return 208
        case .AppleTV: return 400
        default: return 184
        }
    }

    var brickHeight: CGFloat {
        switch self {
        case .iPhone375: return 70
        case .AppleTV: return 100
        default: return 60
        }
    }
    var brickPatternEdgeInsets: UIEdgeInsets {
        return UIEdgeInsets(top: (brickHeight / 2) + brickInset, left: (brickWidth / 2) + brickInset, bottom: (brickHeight / 2) + brickInset, right: 0)
    }
    var brickInset: CGFloat{
        switch self {
        case .iPhone375: return 5
        default: return 4
        }
    }

}

struct Constants {

    static var deviceType: DeviceType = {
        #if os(tvOS)
            return .AppleTV
        #else
        let size = UIDevice.current.orientation.isPortrait ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
        switch size {
        case 0...320: return .iPhone320
        case 321...375: return .iPhone375
        case 376...414: return .iPhone414
        case 415...768: return .iPad
        default: return .Unknown
        }
        #endif
    }()

    static var brickWidth: CGFloat {
        return deviceType.brickWidth
    }

    static var brickHeight: CGFloat {
        return deviceType.brickHeight
    }

    static var brickPatternEdgeInsets: UIEdgeInsets {
        return deviceType.brickPatternEdgeInsets
    }

    static var brickInset: CGFloat {
        return deviceType.brickInset
    }

    static var brickOffset: CGFloat {
        return -Constants.brickWidth / 4
    }

    static func numberOfBricksPerRow(for width: CGFloat) -> Int {
        return Int(floor((width - brickPatternEdgeInsets.left) / brickWidth))
    }

    static var inAppLogo: UIImage {
        return UIImage(named: "logo_inapp")!
    }

}

//MARK: - Fonts

private let SemiBoldFont = "AppleSDGothicNeo-SemiBold"
private let LightFont = "AppleSDGothicNeo-Light"

extension UIFont {
    static func brickSemiBoldFont(size: CGFloat) -> UIFont {
        return UIFont(name: SemiBoldFont, size: size)!
    }

    static func brickLightFont(size: CGFloat) -> UIFont {
        return UIFont(name: LightFont, size: size)!
    }
}

//MARK: - Images

/// Create the brick background pattern
private var brickPatternImage: UIImage = {
    let inset = Constants.brickInset
    let brickSize = CGSize(width: Constants.brickWidth, height: Constants.brickHeight)
    let frame = CGRect(x: 0, y: 0, width: (brickSize.width * 2) + (inset * 2), height: (brickSize.height * 2) + (inset * 2))
    let view = UIView(frame: frame)
    view.backgroundColor = UIColor.clear

    let startY = -brickSize.height / 2
    for i in 0..<9 {
        let row = floor(CGFloat(i) / CGFloat(3))
        let column = CGFloat(i % 3)

        let startX: CGFloat
        if Int(row) % 2 == 0 {
            startX = -brickSize.width * 3 / 4
        } else {
            startX = -brickSize.width / 2
        }

        let x = startX + (column * (brickSize.width + inset))
        let y = startY + (row * (brickSize.height + inset))

        let subview = UIView(frame: CGRect(origin: CGPoint(x: x, y: y), size: brickSize))
        subview.backgroundColor = UIColor(236, 236, 236)
        view.addSubview(subview)
    }

    UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image!
}()

//MARK: - Colors

private let RGBDivider: CGFloat = 255.0

extension UIColor {

    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) {
        self.init(red: r / RGBDivider, green: g / RGBDivider, blue: b / RGBDivider, alpha: a)
    }

    static var brickPattern: UIColor {
        return UIColor(patternImage: brickPatternImage)
    }

    static var brickPurple1: UIColor {
        return UIColor(170, 126, 157)
    }

    static var brickPurple2: UIColor {
        return UIColor(146, 113, 136)
    }

    static var brickPurple3: UIColor {
        return UIColor(122, 101, 117)
    }

    static var brickBackground: UIColor {
        return UIColor(77, 77, 79)
    }

    static var brickHeader: UIColor {
        return UIColor(219, 219, 219)
    }

    static var brickSection: UIColor {
        return UIColor(216, 216, 216)
    }

    static var brickGray1: UIColor {
        return UIColor(219, 219, 219)
    }

    static var brickGray2: UIColor {
        return UIColor(192, 192, 193)
    }

    static var brickGray3: UIColor {
        return UIColor(148, 148, 149)
    }

    static var brickGray4: UIColor {
        return UIColor(121, 121, 123)
    }

    static var brickGray5: UIColor {
        return UIColor(95, 95, 95)
    }

    var complemetaryColor: UIColor {
        switch self {
        case UIColor.brickGray1: return .brickGray5
        case UIColor.brickGray2: return .brickGray5
        case UIColor.brickGray3: return .brickGray1
        case UIColor.brickGray4: return .brickGray1
        case UIColor.brickGray5: return .brickGray1
        default: return UIColor.white
        }
    }
}



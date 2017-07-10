//: [Previous](@previous)

import UIKit
import BrickKit
import PlaygroundSupport

let brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
brickView.backgroundColor = UIColor.white

let configureBlock: ((LabelBrickCell) -> Void) = { cell in
    cell.label.textAlignment = .center
}

let section = BrickSection(backgroundColor: .lightGray, bricks: [
    LabelBrick(text: "LABEL BRICK", configureCellBlock: configureBlock)
    ], edgeInsets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))

brickView.setSection(section)

//Add the set the live view
PlaygroundPage.current.liveView = brickView

//: [Next](@next)
//: [Previous](@previous)

import UIKit
import BrickKit
import PlaygroundSupport

let brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
brickView.backgroundColor = UIColor.white

    //Add the set the live view
    PlaygroundPage.current.liveView = brickView

let labelBrick = GenericBrick<UILabel>(height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .minimumSize(size: .fixed(size: 100)))){ label, cell in
    cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    label.text = "BRICK MINIMUM 100"
}

let section = BrickSection(backgroundColor: .lightGray, bricks: [
    labelBrick
    ], inset: 8, edgeInsets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))

brickView.setSection(section)

//: [Next](@next)

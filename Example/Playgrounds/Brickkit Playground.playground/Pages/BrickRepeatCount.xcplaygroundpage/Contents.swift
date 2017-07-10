//: [Previous](@previous)

import UIKit
import BrickKit
import PlaygroundSupport

struct Fruit {
    let name: String
}

var fruits: [Fruit] = []

let brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
brickView.backgroundColor = .white

//Add the set the live view
PlaygroundPage.current.liveView = brickView

fruits.append(Fruit(name: "Apple"))
fruits.append(Fruit(name: "Banana"))
fruits.append(Fruit(name: "Cherry"))

let labelBrick = GenericBrick<UILabel>("FRUIT", configureView: { view, cell in
    view.text = fruits[cell.index].name
    view.textAlignment = .center
})

let section = BrickSection(backgroundColor: .lightGray, bricks: [
    labelBrick
    ], inset: 8, edgeInsets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))

labelBrick.repeatCount = fruits.count
brickView.setSection(section)

//: [Next](@next)

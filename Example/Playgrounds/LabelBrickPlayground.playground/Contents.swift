//: Playground - noun: a place where people can play

import UIKit
import BrickKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let brickViewContoller = BrickViewController()
brickViewContoller.view.backgroundColor = UIColor.white

//Add the set the live view
PlaygroundPage.current.liveView = brickViewContoller

let section = BrickSection(bricks: [
    LabelBrick(text: "BRICK 1"),
    LabelBrick(text: "MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK MULTI-LINE BRICK"),
    LabelBrick(width: .ratio(ratio: 1/2), text: "1/2 BRICK"),
    LabelBrick(width: .ratio(ratio: 1/2), text: "1/2 BRICK"),
    LabelBrick(width: .ratio(ratio: 1/3), text: "1/3 BRICK"),
    LabelBrick(width: .ratio(ratio: 1/3), text: "1/3 BRICK"),
    LabelBrick(width: .ratio(ratio: 1/3), text: "1/3 BRICK"),
    ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

brickViewContoller.setSection(section)
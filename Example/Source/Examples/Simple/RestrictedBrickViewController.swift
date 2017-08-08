//
//  RestrictedBrickViewController.swift
//  BrickKit-Example
//
//  Created by Peter Cheung on 7/31/17.
//  Copyright © 2017 Wayfair LLC. All rights reserved.
//

import Foundation
import BrickKit

class RestrictedBrickViewController: BrickViewController, HasTitle {
    
    class var brickTitle: String {
        return "Restricted Example"
    }
    
    class var subTitle: String {
        return "Basic example of using bricks with a restricted maximum and minimum height"
    }
    
    var labelText: String = "Press Me"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .brickBackground
        
        let section = BrickSection(bricks: [
            GenericBrick<UILabel>(height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .minimumSize(size: .fixed(size: 100))), backgroundColor: .brickGray3)     { label, cell in
                    cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                    label.text = "BRICK MINIMUM 100"
                    label.configure(textColor: UIColor.brickGray3.complemetaryColor)
            },
            GenericBrick<UILabel>(height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .minimumSize(size: .fixed(size: 100))), backgroundColor: .brickGray3)     { label, cell in
                cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                label.text = "BRICK MINIMUM 100 \n restricted\n restricted\n restricted\n restricted\n restricted\n restricted\n restricted\n restricted"
                label.configure(textColor: UIColor.brickGray3.complemetaryColor)
            },
            GenericBrick<UILabel>(height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .maximumSize(size: .fixed(size: 100))), backgroundColor: .brickGray3)     { label, cell in
                cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                label.text = "BRICK MAXIMUM 100"
                label.configure(textColor: UIColor.brickGray3.complemetaryColor)
            },
            GenericBrick<UILabel>(height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .maximumSize(size: .fixed(size: 100))), backgroundColor: .brickGray3)   { label, cell in
                cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                label.text = "BRICK MAXIMUM 100 \n restricted\n restricted\n restricted\n restricted\n restricted\n restricted\n restricted\n restricted"
                label.configure(textColor: UIColor.brickGray3.complemetaryColor)
            },
            GenericBrick<UILabel>("ResizeBrick", height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .minimumSize(size: .fixed(size: 100))), backgroundColor: .brickGray3)   { label, cell in
                cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                label.text = self.labelText
                label.configure(textColor: UIColor.brickGray3.complemetaryColor)
            },
            
            // Examples of indirect cases. Restricts maximum and minimum based off of orientation
            GenericBrick<UILabel>(height: .orientation(landscape: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .maximumSize(size: .fixed(size: 200))), portrait: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .maximumSize(size: .fixed(size: 100)))), backgroundColor: .brickGray3) { label, cell in
                cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                label.text = "MAX Portrait: 100, Landscape: 200\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM\n MAXIMUM"
                label.configure(textColor: UIColor.brickGray3.complemetaryColor)
            },
            GenericBrick<UILabel>(height: .restricted(size: .auto(estimate: .fixed(size: 100)), restrictedSize: .minimumSize(size: .orientation(landscape: .fixed(size: 200), portrait: .fixed(size: 100)))), backgroundColor: .brickGray3) { label, cell in
                cell.edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                label.text = "MIN Portrait: 100, Landscape: 200"
                label.configure(textColor: UIColor.brickGray3.complemetaryColor)
            }
            //BrickDimension.
            
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        
        self.setSection(section)
    }
}
extension RestrictedBrickViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let brickIdentifier = self.brickCollectionView.brick(at: indexPath).identifier
        if brickIdentifier == "ResizeBrick", let cell = brickCollectionView.cellForItem(at: indexPath) as? GenericBrickCell {
            let label = cell.genericContentView as? UILabel
            if label?.text == "Press Me" {
                labelText = "Here we have alot of text so the brick with resize. Here we have alot of text so the brick with resize. Here we have alot of text so the brick with resize. Here we have alot of text so the brick with resize. Here we have alot of text so the brick with resize. Here we have alot of text so the brick with resize. Here we have alot of text so the brick with resize. Here we have alot of text so the brick with resize. Here we have alot of text so the brick with resize. Here we have alot of text so the brick with resize. Here we have alot of text so the brick with resize. Here we have alot of text so the brick with resize. Here we have alot of text so the brick with resize."
            } else {
                labelText = "Press Me"
            }
            
            self.brickCollectionView.invalidateBricks()
        }
    }
}


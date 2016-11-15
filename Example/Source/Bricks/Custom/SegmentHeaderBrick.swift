
import UIKit
import BrickKit

class SegmentHeaderBrick: Brick {
    weak var dataSource: SegmentHeaderBrickDataSource?
    weak var delegate: SegmentHeaderBrickDelegate?

    init(_ identifier: String = "", width: BrickDimension = .Ratio(ratio: 1), height: BrickDimension = .Auto(estimate: .Fixed(size: 100)), backgroundColor: UIColor = .clearColor(), backgroundView: UIView? = nil, dataSource: SegmentHeaderBrickDataSource? = nil, delegate: SegmentHeaderBrickDelegate? = nil) {
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(identifier, width: width, height: height, backgroundColor: backgroundColor, backgroundView: backgroundView)
    }
}

class SegmentHeaderBrickCell: BrickCell, Bricklike {
    typealias BrickType = SegmentHeaderBrick
    
    @IBOutlet weak var segmentControl: UISegmentedControl!

    @IBAction func didSelectIndex(sender: AnyObject) {
        self.brick.delegate?.segementHeaderBrickCell(self, didSelectIndex: segmentControl.selectedSegmentIndex)
    }

    override func updateContent() {
        super.updateContent()

        guard let dataSource = self.brick.dataSource else {
            return
        }

        self.segmentControl.removeAllSegments()
        for (index, title) in dataSource.titles.enumerate() {
            self.segmentControl.insertSegmentWithTitle(title, atIndex: index, animated: false)
        }
        self.segmentControl.selectedSegmentIndex = dataSource.selectedSegmentIndex
    }
}

protocol SegmentHeaderBrickDataSource: class {
    var titles: [String] { get }
    var selectedSegmentIndex: Int { get }
}

protocol SegmentHeaderBrickDelegate: class {
    func segementHeaderBrickCell(cell: SegmentHeaderBrickCell, didSelectIndex index: Int)
}
